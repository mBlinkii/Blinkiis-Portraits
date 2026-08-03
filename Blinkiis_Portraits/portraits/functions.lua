-- upvalues (hot path: these are called on every event)
local _G = _G
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local InCombatLockdown = InCombatLockdown
local SetPortraitTexture = SetPortraitTexture
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsVisible = UnitIsVisible
local UnitLevel = UnitLevel
local UnitReaction = UnitReaction
local format = format
local gmatch = string.gmatch
local ipairs, type = ipairs, type
local select, tinsert = select, tinsert
local strfind, strsplit, strsub = strfind, strsplit, strsub
local tostring = tostring
local issecretvalue = issecretvalue

local mediaPortraits = BLINKIISPORTRAITS.media.portraits
local mediaExtra = BLINKIISPORTRAITS.media.extra
local mediaClass = BLINKIISPORTRAITS.media.class

local playerFaction = nil

-- default texcoords, shared to avoid per-call table allocations
local DEFAULT_COORDS = { 0, 1, 0, 1 }

--- Returns true if the given value is a secret value (WoW 12.x API), false otherwise.
function BLINKIISPORTRAITS:IsSecretValue(value)
	return (issecretvalue and issecretvalue(value)) or false
end

-- Returns the value unchanged, or nil if it is a secret value.
-- Secret values must never be compared, concatenated or branched on in addon code.
local function SafeValue(value)
	if issecretvalue and issecretvalue(value) then return nil end
	return value
end

-- reaction helper (shared by GetUnitColor and UpdateExtraTexture)
local function GetReactionType(unit)
	local reaction = (unit == "pet") and UnitReaction("player", unit) or UnitReaction(unit, "player")
	return (reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly")) or "enemy"
end

-- portrait texture update functions
local function GetCastIcon(unit)
	return select(3, UnitCastingInfo(unit)) or select(3, UnitChannelInfo(unit))
end

local function UpdatePortrait(portrait, unit)
	if portrait.isCasting then
		local castIcon = GetCastIcon(unit)
		if castIcon then
			portrait.portrait:SetTexture(castIcon)
			return
		else
			portrait.isCasting = false
		end
	end

	local forceDesaturate = BLINKIISPORTRAITS.db.profile.misc.desaturate

	if (portrait.useClassIcon and not portrait.db.ignoreClassIcons) and (portrait.isPlayer or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit or portrait.unit))) then
		portrait.unitClass = portrait.unitClass or select(2, UnitClass(unit or portrait.unit))
		portrait.texCoords = portrait.classIcons.texCoords[portrait.unitClass]
		portrait.portrait:SetTexture(portrait.classIcons.texture, "CLAMP", "CLAMP", "TRILINEAR")

		if BLINKIISPORTRAITS.DebugEnabled then
			BLINKIISPORTRAITS:Debug(format("  texture <- class icon | unit: %s | class: %s", tostring(unit or portrait.unit), tostring(portrait.unitClass)))
		end
	else
		SetPortraitTexture(portrait.portrait, unit or portrait.unit, true)

		-- a nil texture here means the client had no portrait data for the unit yet;
		-- UNIT_PORTRAIT_UPDATE / PORTRAITS_UPDATED must refresh it once it becomes available
		if BLINKIISPORTRAITS.DebugEnabled then
			BLINKIISPORTRAITS:Debug(format("  texture <- SetPortraitTexture | unit: %s | result: %s", tostring(unit or portrait.unit), tostring(portrait.portrait:GetTexture())))
		end
	end

	BLINKIISPORTRAITS:UpdateDesaturated(portrait, (forceDesaturate or portrait.isDead))

	BLINKIISPORTRAITS:Mirror(
		portrait.portrait,
		portrait.isPlayer and portrait.db.mirror,
		(portrait.isPlayer and (portrait.useClassIcon and not portrait.db.ignoreClassIcons)) and portrait.texCoords
	)
end

local function Update(portrait, event, eventUnit)
	if not portrait.unit then
		if BLINKIISPORTRAITS.DebugEnabled then BLINKIISPORTRAITS:Debug(format("%s | %s | SKIPPED, no unit resolved", tostring(portrait:GetName()), tostring(event))) end
		return
	end

	local unit = (portrait.demo and not UnitExists(portrait.unit)) and "player" or portrait.unit
	local guid = UnitGUID(unit)
	guid = BLINKIISPORTRAITS:IsSecretValue(guid) and " " or guid

	local isAvailable = UnitIsConnected(unit) and UnitIsVisible(unit)
	local hasStateChanged = ((event == "ForceUpdate") or (portrait.lastGUID ~= guid) or (portrait.state ~= isAvailable))

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(
			format(
				"%s | %s | unit: %s | exists: %s | available: %s | guidChanged: %s | changed: %s",
				tostring(portrait:GetName()),
				tostring(event),
				tostring(unit),
				tostring(UnitExists(unit) and true or false),
				tostring(isAvailable),
				tostring(portrait.lastGUID ~= guid),
				tostring(hasStateChanged)
			)
		)
	end

	if hasStateChanged then
		local class = select(2, UnitClass(unit))
		local isPlayer = UnitIsPlayer(unit) or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit))

		portrait.isPlayer = isPlayer
		portrait.unitClass = class
		portrait.lastGUID = guid
		portrait.state = isAvailable
		portrait.unit = unit
		portrait.isDead = UnitIsDead(unit)

		local color = BLINKIISPORTRAITS:GetUnitColor(unit, portrait.isDead, isPlayer, class)
		if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

		UpdatePortrait(portrait, unit)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.forceExtra)

		if portrait.clickable and not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
	end
end

local function CastStart(portrait, _, unit)
	-- without an icon there is nothing to show, so the casting state must not be set either -
	-- otherwise CastStop would restore a portrait that was never replaced
	local castIcon = GetCastIcon(unit)
	if not castIcon then return end

	portrait.isCasting = true
	portrait.portrait:SetTexture(castIcon)

	-- the class icon is a slice of an atlas, the cast icon a full texture: reset the texcoords
	if (portrait.useClassIcon and not portrait.db.ignoreClassIcons) and portrait.texCoords then
		BLINKIISPORTRAITS:Mirror(portrait.portrait, portrait.isPlayer and portrait.db.mirror, DEFAULT_COORDS)
	end

	if BLINKIISPORTRAITS.DebugEnabled then BLINKIISPORTRAITS:Debug(format("  texture <- cast icon | unit: %s | icon: %s", tostring(unit), tostring(castIcon))) end
end

local function CastStop(portrait, event, unit)
	-- STOP and INTERRUPTED both fire for the same cast, and INTERRUPTED can repeat; restoring the
	-- portrait more than once would rebuild the texture for every one of them
	if not portrait.isCasting then return end

	portrait.isCasting = false
	UpdatePortrait(portrait, unit)
end

local function ForceUpdate(portrait)
	Update(portrait, "ForceUpdate", portrait.unit)
end

local function SimpleUpdate(portrait, event)
	Update(portrait, event, portrait.unit)
end

-- PORTRAITS_UPDATED announces that portrait textures became available or changed. The unit state
-- (guid, connection) is unchanged in that moment, so this must always force an update - otherwise
-- Update() short circuits and a texture that was still missing on the first try stays empty.
local function PortraitsUpdated(portrait)
	-- the event fires for all portraits at once, but a unit that is provably absent has no texture
	-- to refresh. Skipping those avoids a full update pass (including the boss token scan) over
	-- every inactive portrait. A secret result (WoW 12.x) counts as "unknown" and updates anyway.
	if not portrait.demo and portrait.unit and SafeValue(UnitExists(portrait.unit)) == false then return end

	Update(portrait, "ForceUpdate", portrait.unit)
end

-- UNIT_PORTRAIT_UPDATE / UNIT_MODEL_CHANGED: the texture of a single unit became available or
-- changed, which likewise never shows up as a state change. Group portraits are registered
-- globally and receive these events for all units, so unrelated units are filtered out.
local function UnitTextureChanged(portrait, event, eventUnit)
	if eventUnit and portrait.unit and eventUnit ~= portrait.unit then
		-- skip only when the units are provably different; a secret result (WoW 12.x) is treated as
		-- "unknown" and updates anyway, since a redundant update is cheaper than an empty portrait
		if SafeValue(UnitIsUnit(eventUnit, portrait.unit)) == false then return end
	end

	Update(portrait, "ForceUpdate", portrait.unit)
end

local function DelayedUpdate(portrait, event)
	if portrait._delayedUpdateTimer then portrait._delayedUpdateTimer:Cancel() end
	portrait._delayedUpdateTimer = C_Timer.NewTimer(0.6, function()
		Update(portrait, event, portrait.unit)
		portrait._delayedUpdateTimer = nil
	end)
end

local eventHandlers = {
	-- portrait updates
	PORTRAITS_UPDATED = PortraitsUpdated,
	UNIT_CONNECTION = Update,
	UNIT_PORTRAIT_UPDATE = UnitTextureChanged,
	UNIT_MODEL_CHANGED = UnitTextureChanged,
	PARTY_MEMBER_ENABLE = Update,
	PARTY_MEMBER_DISABLE = Update,
	ForceUpdate = Update,

	-- cast icon updates
	UNIT_SPELLCAST_CHANNEL_START = CastStart,
	UNIT_SPELLCAST_START = CastStart,

	UNIT_SPELLCAST_CHANNEL_STOP = CastStop,
	UNIT_SPELLCAST_INTERRUPTED = CastStop,
	UNIT_SPELLCAST_STOP = CastStop,

	UNIT_SPELLCAST_EMPOWER_START = CastStart,
	UNIT_SPELLCAST_EMPOWER_STOP = CastStop,

	-- vehicle updates
	UNIT_ENTERED_VEHICLE = DelayedUpdate,
	UNIT_EXITING_VEHICLE = SimpleUpdate,
	UNIT_EXITED_VEHICLE = SimpleUpdate,
	VEHICLE_UPDATE = SimpleUpdate,

	-- target/ focus updates
	PLAYER_TARGET_CHANGED = ForceUpdate,
	PLAYER_FOCUS_CHANGED = ForceUpdate,
	UNIT_TARGET = ForceUpdate,

	-- party
	GROUP_ROSTER_UPDATE = SimpleUpdate,
	UNIT_NAME_UPDATE = SimpleUpdate,

	-- arena
	ARENA_OPPONENT_UPDATE = Update,
	UNIT_TARGETABLE_CHANGED = Update,
	ARENA_PREP_OPPONENT_SPECIALIZATIONS = SimpleUpdate,
	UPDATE_ACTIVE_BATTLEFIELD = SimpleUpdate,

	-- boss unit check/ update
	INSTANCE_ENCOUNTER_ENGAGE_UNIT = ForceUpdate,
}

local castEvents = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP" }
local empowerEvents = { "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP" }

-- lookup to skip unit re-resolution for cast events (unit cannot change mid cast)
local castEventLookup = {}
for _, event in ipairs(castEvents) do
	castEventLookup[event] = true
end
for _, event in ipairs(empowerEvents) do
	castEventLookup[event] = true
end

--- Resolves the unit token of a portrait from its parent unit frame.
-- Sources are tried in order of reliability: Cell stores the unit in "_unit", header based frames
-- (EllesmereUI) in the secure "unit" attribute, oUF style frames in ".unit". unitOverride wins over
-- the parent for addons that expose no unit at all (EQOL), unitFallback is the last resort for group
-- frames whose parent had no unit assigned yet - without it the portrait texture would stay empty.
-- @param portrait the portrait frame
-- @return the unit token, or nil if none could be resolved
function BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
	local parent = portrait.parentFrame
	if not parent then return portrait.unit end

	return (portrait.isCellParentFrame and parent._unit)
		or (portrait.isHeaderUnit and parent:GetAttribute("unit"))
		or portrait.unitOverride
		or parent.unit
		or portrait.unit
		or portrait.unitFallback
end

local function OnEvent(portrait, event, eventUnit, arg)
	local handler = eventHandlers[event]

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(format("event %s | %s | eventUnit: %s | handler: %s", tostring(event), tostring(portrait:GetName()), tostring(eventUnit), tostring(handler ~= nil)))
	end

	if not handler then return end

	-- the unit cannot change mid cast, so cast events skip the re-resolution
	if not castEventLookup[event] then portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait) end

	handler(portrait, event, eventUnit, arg)
end

-- mirrored texcoords are precomputed once per coords table to avoid per-call allocations
local mirroredCoordsCache = {}
local function GetMirroredCoords(coords)
	local mirrored = mirroredCoordsCache[coords]
	if not mirrored then
		if #coords == 8 then
			mirrored = { coords[5], coords[6], coords[7], coords[8], coords[1], coords[2], coords[3], coords[4] }
		else
			mirrored = { coords[2], coords[1], coords[3], coords[4] }
		end
		mirroredCoordsCache[coords] = mirrored
	end
	return mirrored
end

--- Applies (optionally mirrored) texcoords to a texture.
-- @param texture the texture to modify
-- @param mirror true to mirror horizontally
-- @param texCoords optional texcoords table (4 or 8 values); defaults to full texture
function BLINKIISPORTRAITS:Mirror(texture, mirror, texCoords)
	if texCoords then
		local coords = mirror and GetMirroredCoords(texCoords) or texCoords
		if #coords == 8 then
			texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4], coords[5], coords[6], coords[7], coords[8])
		else
			texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		end
	elseif mirror then
		texture:SetTexCoord(1, 0, 0, 1)
	else
		texture:SetTexCoord(0, 1, 0, 1)
	end
end

local function SetTexture(texture, file, wrapMode)
	texture:SetTexture(file, wrapMode, wrapMode, "TRILINEAR")
end

--- Applies the configured texture files to all layers of a portrait.
function BLINKIISPORTRAITS:UpdateTextures(portrait)
	local mirror = portrait.db.mirror

	SetTexture(portrait.texture, portrait.textureFile, "CLAMP")
	SetTexture(portrait.mask, portrait.maskFile, "CLAMPTOBLACKADDITIVE")

	if portrait.extraMask then SetTexture(portrait.extraMask, portrait.extraMaskFile, "CLAMPTOBLACKADDITIVE") end
	SetTexture(portrait.bg, portrait.bgFile, "CLAMP")

	BLINKIISPORTRAITS:Mirror(portrait.texture, mirror)
	BLINKIISPORTRAITS:Mirror(portrait.extra, mirror)
end

local extraTypes = { rare = true, elite = true, rareelite = true, boss = true }
local extraFileKeys = { rare = "rareFile", elite = "eliteFile", rareelite = "rareeliteFile", boss = "bossFile", player = "playerFile" }

-- precomputed boss unit tokens (boss1-boss8) to avoid per-call string concatenations
local MAX_BOSS_UNITS = 8
local bossTokens = {}
for i = 1, MAX_BOSS_UNITS do
	bossTokens[i] = "boss" .. i
end

-- Extracts the npcID from a creature GUID; returns nil for player GUIDs,
-- missing GUIDs or the secret placeholder (" ") stored by Update().
local function GetNpcID(guid)
	if not guid or guid == " " then return nil end
	return select(6, strsplit("-", guid))
end

-- Secret-safe check whether a unit matches one of the boss1-boss8 unit tokens.
-- UnitExists/UnitIsUnit may return secret values during an encounter (WoW 12.x);
-- secret results are treated as "unknown" and skipped.
local function IsBossTokenUnit(unit)
	for i = 1, MAX_BOSS_UNITS do
		local token = bossTokens[i]
		if SafeValue(UnitExists(token)) and SafeValue(UnitIsUnit(unit, token)) then return true end
	end
	return false
end

--- Determines the extra classification of a portrait unit (secret-safe, WoW 12.x).
-- Boss detection uses all available sources, in order:
--   1. portrait type "boss" (boss frames always show bosses)
--   2. cached npcIDs, learned at runtime and persisted in db.global.BossIDs
--   3. comparison against the boss1-boss8 unit tokens (active encounter)
--   4. UnitClassification ("worldboss"/"boss")
--   5. level fallback: non-player units with UnitLevel == -1 ("??")
-- All API results are ignored when secret, so detection degrades gracefully in combat.
-- @param portrait the portrait frame
-- @return "boss", "rareelite", "rare", "elite" or nil
function BLINKIISPORTRAITS:GetExtraClassification(portrait)
	local unit = portrait.unit
	if not unit then return nil end

	local npcID = GetNpcID(portrait.lastGUID)
	local classification = SafeValue(UnitClassification(unit))
	if classification == "worldboss" then classification = "boss" end

	local isBoss = (portrait.type == "boss")
		or (npcID and BLINKIISPORTRAITS.CachedBossIDs[npcID])
		or (classification == "boss")
		or (not portrait.isPlayer and IsBossTokenUnit(unit))
		or (not portrait.isPlayer and SafeValue(UnitLevel(unit)) == -1)

	if isBoss then
		-- learn the npcID for reliable pre-pull detection in future sessions
		if npcID and not BLINKIISPORTRAITS.CachedBossIDs[npcID] then BLINKIISPORTRAITS.CachedBossIDs[npcID] = true end
		return "boss"
	end

	return extraTypes[classification] and classification or nil
end

--- Updates the rare/elite/boss overlay texture of a portrait.
-- @param portrait the portrait frame
-- @param color optional color override (unit color)
-- @param force optional forced classification ("none" disables forcing)
function BLINKIISPORTRAITS:UpdateExtraTexture(portrait, color, force)
	if not (portrait.extra and portrait.db.extra) then
		if portrait.extra then portrait.extra:Hide() end
		return
	end

	local c = BLINKIISPORTRAITS:GetExtraClassification(portrait)
	local isExtraUnit = c ~= nil

	if not isExtraUnit and force and force ~= "none" then
		c = force
		isExtraUnit = true
	end

	if isExtraUnit and not color then
		local colors = BLINKIISPORTRAITS.db.profile.colors
		if BLINKIISPORTRAITS.db.profile.misc.force_reaction then
			color = colors.reaction[GetReactionType(portrait.unit)]
		else
			color = colors.classification[c]
		end
	end

	if color and c then
		portrait.extra:SetTexture(portrait[extraFileKeys[c] or (c .. "File")], "CLAMP", "CLAMP", "TRILINEAR")
		portrait.extra:SetVertexColor(color.r, color.g, color.b, color.a or 1)
		portrait.extra:Show()
	else
		portrait.extra:Hide()
	end
end

-- color functions

--- Returns the configured color for a unit (class, reaction, death or default color).
function BLINKIISPORTRAITS:GetUnitColor(unit, isDead, isPlayer, class)
	if not unit then return end

	local profile = BLINKIISPORTRAITS.db.profile
	local colors = profile.colors

	if isDead then return colors.misc.death, isPlayer end

	if profile.misc.force_default then return colors.misc.default, isPlayer end

	if isPlayer then
		if profile.misc.force_reaction then
			local unitFaction = UnitFactionGroup(unit)
			playerFaction = playerFaction or UnitFactionGroup("player")

			local reactionType = (playerFaction == unitFaction) and "friendly" or "enemy"
			return colors.reaction[reactionType], isPlayer
		else
			return class and colors.class[class] or colors.misc.default
		end
	else
		return colors.reaction[GetReactionType(unit)], isPlayer
	end
end

--- Sets the desaturation state of the portrait texture (only touches the texture on change).
function BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
	if isDead then
		if not portrait.isDesaturated then
			portrait.portrait:SetDesaturated(true)
			portrait.isDesaturated = true
		end
	elseif portrait.isDesaturated then
		portrait.portrait:SetDesaturated(false)
		portrait.isDesaturated = false
	end
end

-- update settings functions
local function UpdateZoom(portrait)
	local zoom = BLINKIISPORTRAITS.db.profile.misc.zoom
	local offset = (portrait.size / 2) * zoom
	local texture = portrait.portrait

	-- anchor explicitly to the portrait frame; a single consistent anchor model
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", portrait, "TOPLEFT", -offset, offset)
	texture:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", offset, -offset)
end

--- Applies size, position, strata and level to a portrait (skipped during combat lockdown).
function BLINKIISPORTRAITS:UpdateSize(portrait, size, point)
	if not InCombatLockdown() then
		size = size or portrait.size
		point = point or portrait.point
		portrait:SetSize(size / 2, size / 2)
		portrait.texture:SetSize(size, size)
		portrait:ClearAllPoints()
		portrait:SetPoint(point.point, portrait.parentFrame, point.relativePoint, point.x, point.y)

		if portrait.db.strata ~= "AUTO" then portrait:SetFrameStrata(portrait.db.strata) end
		portrait:SetFrameLevel(portrait.db.level)
	end
end

--- Resolves the texture/mask file paths for a portrait based on the profile settings.
function BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, settings)
	local profile = BLINKIISPORTRAITS.db.profile
	local dbMisc = profile.misc
	local dbCustom = profile.custom
	local media = mediaPortraits[settings.texture]

	portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\media\\blank.tga"

	portrait.classIcons = (portrait.useClassIcon and not portrait.db.ignoreClassIcons) and mediaClass[dbMisc.class_icon] or nil

	if dbCustom.enable then
		portrait.textureFile = "Interface\\Addons\\" .. dbCustom.texture
		portrait.maskFile = "Interface\\Addons\\" .. dbCustom.mask

		portrait.extraMaskFile = "Interface\\Addons\\" .. dbCustom.extra_mask

		if dbCustom.extra then
			portrait.playerFile = "Interface\\Addons\\" .. dbCustom.player

			portrait.rareFile = "Interface\\Addons\\" .. dbCustom.rare
			portrait.eliteFile = "Interface\\Addons\\" .. dbCustom.elite
			portrait.rareeliteFile = "Interface\\Addons\\" .. dbCustom.rareelite
			portrait.bossFile = "Interface\\Addons\\" .. dbCustom.boss
		else
			portrait.playerFile = mediaExtra[dbMisc.player]

			portrait.rareFile = mediaExtra[dbMisc.rare]
			portrait.eliteFile = mediaExtra[dbMisc.elite]
			portrait.rareeliteFile = mediaExtra[dbMisc.rareelite]
			portrait.bossFile = mediaExtra[dbMisc.boss]
		end
	else
		portrait.textureFile = media.texture
		portrait.maskFile = (settings.mirror and media.mask_mirror) and media.mask_mirror or media.mask

		portrait.extraMaskFile = (settings.mirror and media.extra_mirror) and media.extra_mirror or media.extra

		portrait.playerFile = mediaExtra[dbMisc.player]

		portrait.rareFile = mediaExtra[dbMisc.rare]
		portrait.eliteFile = mediaExtra[dbMisc.elite]
		portrait.rareeliteFile = mediaExtra[dbMisc.rareelite]
		portrait.bossFile = mediaExtra[dbMisc.boss]
	end
end

-- initialize function

--- Resolves a frame reference from a global name; supports dotted paths like "Stuf.units.player".
function BLINKIISPORTRAITS:ResolveFrame(path)
	if type(path) ~= "string" then return path end
	if not strfind(path, ".", 1, true) then return _G[path] end

	local obj = _G
	for part in gmatch(path, "[^%.]+") do
		obj = obj[part]
		if not obj then return nil end
	end
	return obj
end

local function GetUnitFrame(unit, type)
	local unitFrames = BLINKIISPORTRAITS.unitFrames

	if type == "pb4" then
		local singleFrames = unitFrames.pb4.singleUnits()
		local groupFrames = unitFrames.pb4.groupUnits()
		return singleFrames[unit] or groupFrames[unit]
	else
		return unitFrames[type][unit]
	end
end

--- Returns the frame name a unit frame addon uses for a unit, skipping the addon priority.
-- Used for optional companion frames whose addon type has already been resolved.
-- @param unit the unit key ("partyself", ...)
-- @param addonType the resolved addon type ("eui", "uuf", ...)
-- @return the frame name, or nil if this addon provides no such frame
function BLINKIISPORTRAITS:GetUnitFrameName(unit, addonType)
	if not addonType then return nil end
	return GetUnitFrame(unit, addonType)
end

-- priority order for resolving the parent unit frame addon
-- "unit" restricts an entry to a specific unit (Cell and DandersFrames provide party frames only)
local ufTypePriority = {
	{ type = "df", flag = "DF", unit = "party" },
	{ type = "cell", flag = "Cell", unit = "party" },
	{ type = "elvui", flag = "ELVUI" },
	{ type = "pb4", flag = "PB4" },
	{ type = "suf", flag = "SUF" },
	{ type = "uuf", flag = "UUF" },
	{ type = "ndui", flag = "NDUI" },
	{ type = "cell", flag = "Cell_UF" },
	{ type = "eqol", flag = "EQOL" },
	{ type = "bbf", flag = "BBF" },
	{ type = "eui", flag = "EUI" },
	{ type = "stuf", flag = "STUF" },
}

-- True if the addon of a priority entry is loaded and the entry is not restricted to another unit.
local function IsEntryAvailable(entry, unit)
	return BLINKIISPORTRAITS[entry.flag] and (not entry.unit or entry.unit == unit)
end

--- Returns the unit frame name and addon type for a unit, honoring the configured parent.
-- Entries that provide no frame for the requested unit are skipped, so a loaded addon with a
-- gap in its mapping (e.g. no party frames) cannot block a lower priority addon that has one.
-- @param unit the unit key ("player", "party", ...)
-- @param parent the configured unit frame addon ("auto" or a specific type)
-- @return frameName, addonType (or nil if no loaded unit frame addon provides the unit)
function BLINKIISPORTRAITS:GetUnitFrames(unit, parent)
	-- explicit selection or "auto" priority
	for _, entry in ipairs(ufTypePriority) do
		if IsEntryAvailable(entry, unit) and (parent == "auto" or parent == entry.type) then
			local frame = GetUnitFrame(unit, entry.type)
			if frame then return frame, entry.type end
		end
	end

	-- fallback: first loaded unit frame addon providing the unit, ignoring the configured parent
	for _, entry in ipairs(ufTypePriority) do
		if IsEntryAvailable(entry, unit) then
			local frame = GetUnitFrame(unit, entry.type)
			if frame then return frame, entry.type end
		end
	end
end

-- UNIT_* events whose relevant unit differs from the portrait unit, mapped to the unit they must be
-- filtered to. UNIT_TARGET fires for the unit whose target changed, so a targettarget portrait has
-- to listen to "target" - registered globally it would run for every group member's target change.
local unitEventOverrides = {
	UNIT_TARGET = "target",
}

--- Registers all given events on a portrait.
-- UNIT_* events are registered unit-filtered (RegisterUnitEvent) when the portrait has a fixed unit,
-- which avoids handler calls for unrelated units (raid/party spam).
function BLINKIISPORTRAITS:RegisterEvents(portrait, events)
	local unit = portrait.unit
	local useUnitEvents = unit and portrait.type ~= "party"

	for _, event in ipairs(events) do
		if useUnitEvents and strsub(event, 1, 5) == "UNIT_" then
			portrait:RegisterUnitEvent(event, unitEventOverrides[event] or unit)
		else
			portrait:RegisterEvent(event)
		end
		tinsert(portrait.events, event)
	end
end

--- Unregisters all events of a portrait, cancels pending timers and hides the frame.
function BLINKIISPORTRAITS:RemovePortrait(frame)
	if frame._delayedUpdateTimer then
		frame._delayedUpdateTimer:Cancel()
		frame._delayedUpdateTimer = nil
	end

	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	frame.eventsSet = nil
	frame.castEventsSet = nil
	frame.cast = nil
	frame:Hide()
end

local function GetPortraitFrameName(name, clickable)
	return "BP_Portrait_" .. name .. (clickable and "_Clickable" or "_Display")
end

local function HideInactivePortrait(name, clickable)
	local inactiveFrame = _G[GetPortraitFrameName(name, not clickable)]
	if inactiveFrame then BLINKIISPORTRAITS:RemovePortrait(inactiveFrame) end
end

--- Creates (or reuses) the portrait frame including all texture layers.
function BLINKIISPORTRAITS:CreatePortrait(name, parent)
	if parent then
		local clickable = BLINKIISPORTRAITS.db.profile.misc.clickable
		local frameName = GetPortraitFrameName(name, clickable)
		local portrait = _G[frameName]

		HideInactivePortrait(name, clickable)

		if not portrait then
			portrait = CreateFrame(clickable and "Button" or "Frame", frameName, parent, clickable and "SecureUnitButtonTemplate" or nil)

			-- texture
			portrait.texture = portrait:CreateTexture("BP_texture-" .. name .. (clickable and "_Clickable" or "_Display"), "ARTWORK", nil, 4)
			portrait.texture:SetPoint("CENTER", portrait, "CENTER", 0, 0)

			-- mask
			portrait.mask = portrait:CreateMaskTexture()
			portrait.mask:SetAllPoints(portrait.texture)

			-- portrait
			portrait.portrait = portrait:CreateTexture("BP_portrait-" .. name .. (clickable and "_Clickable" or "_Display"), "ARTWORK", nil, 2)
			portrait.portrait:SetAllPoints(portrait.texture)
			portrait.portrait:AddMaskTexture(portrait.mask)

			-- rare/elite/boss
			local extraOnTop = BLINKIISPORTRAITS.db.profile.misc.extratop
			portrait.extra = portrait:CreateTexture("BP_extra-" .. name .. (clickable and "_Clickable" or "_Display"), "OVERLAY", nil, extraOnTop and 7 or 1)
			portrait.extra:SetAllPoints(portrait.texture)

			-- extra mask
			if not extraOnTop then
				portrait.extraMask = portrait:CreateMaskTexture()
				portrait.extraMask:SetAllPoints(portrait.texture)
				portrait.extra:AddMaskTexture(portrait.extraMask)
			end

			-- bg
			portrait.bg = portrait:CreateTexture("BP_bg-" .. name .. (clickable and "_Clickable" or "_Display"), "BACKGROUND", nil, 1)
			portrait.bg:SetAllPoints(portrait.texture)
			portrait.bg:AddMaskTexture(portrait.mask)
			portrait.bg:SetVertexColor(0, 0, 0, 1)
		else
			portrait:SetParent(parent)
		end

		portrait.clickable = clickable

		if clickable then
			portrait:EnableMouse(true)
			portrait:SetAttribute("unit", portrait.unit)
			portrait:SetAttribute("*type1", "target")
			portrait:SetAttribute("*type2", "togglemenu")
			portrait:SetAttribute("type3", "focus")
			portrait:SetAttribute("toggleForVehicle", true)
			portrait:SetAttribute("ping-receiver", true)
			portrait:RegisterForClicks("AnyUp")
		else
			portrait:EnableMouse(false)
		end

		portrait:Show()

		return portrait
	end
end

--- Returns the portrait for a unit key, recreating it if the clickable setting changed.
function BLINKIISPORTRAITS:EnsurePortrait(unit, name, parent)
	local portrait = BLINKIISPORTRAITS.Portraits[unit]
	local clickable = BLINKIISPORTRAITS.db.profile.misc.clickable

	if portrait and portrait.clickable ~= clickable then
		BLINKIISPORTRAITS:RemovePortrait(portrait)
		portrait = nil
	end

	portrait = portrait or BLINKIISPORTRAITS:CreatePortrait(name, parent)
	BLINKIISPORTRAITS.Portraits[unit] = portrait

	return portrait
end

--- Applies textures, registers events and triggers the first update of a portrait.
function BLINKIISPORTRAITS:InitPortrait(portrait, events)
	if portrait then
		BLINKIISPORTRAITS:UpdateTextures(portrait)

		if not portrait.eventsSet then
			BLINKIISPORTRAITS:RegisterEvents(portrait, events)

			portrait:SetScript("OnEvent", OnEvent)
			portrait.eventsSet = true
		end
		OnEvent(portrait, "ForceUpdate", portrait.unit)

		UpdateZoom(portrait)
	end
end

local function UnregisterEvents(portrait, events)
	for _, event in ipairs(events) do
		portrait:UnregisterEvent(event)
	end
end

--- Registers the cast events (and empower events on retail) of a portrait once.
function BLINKIISPORTRAITS:RegisterCastEvents(portrait)
	if not portrait.castEventsSet then
		BLINKIISPORTRAITS:RegisterEvents(portrait, castEvents)

		if BLINKIISPORTRAITS.Retail then BLINKIISPORTRAITS:RegisterEvents(portrait, empowerEvents) end
		portrait.castEventsSet = true
	end
end

--- Unregisters the cast events (and empower events on retail) of a portrait.
function BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
	UnregisterEvents(portrait, castEvents)

	if BLINKIISPORTRAITS.Retail then UnregisterEvents(portrait, empowerEvents) end
	portrait.castEventsSet = false
end

--- Enables/disables the cast icon events based on the portrait settings.
function BLINKIISPORTRAITS:UpdateCastSettings(portrait)
	if portrait.db.cast then
		BLINKIISPORTRAITS:RegisterCastEvents(portrait)
		portrait.cast = true
	elseif portrait.cast then
		BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
		portrait.cast = false
	end
end

--- Shared setup for a portrait instance; used by all unit initializers.
-- opts:
--   key          (string) key in BLINKIISPORTRAITS.Portraits ("player", "boss1", ...)
--   type         (string) db profile key ("player", "target", "party", ...)
--   parent       (frame)  parent unit frame
--   parentFrame  (string) resolved unit frame addon type ("elvui", "cell", ...)
--   events       (table)  events to register
--   unitOverride (string) optional fixed unit token (used before parent.unit)
--   unitFallback (string) optional unit token used only if no other source yields one
--   isHeaderUnit (bool)   unit is read from the parent's "unit" attribute
--   cellFlag     (bool)   addon flag for cell parent detection (defaults to Cell_UF)
--   isGroup      (bool)   group frame demo handling (boss/arena/party)
--   demo         (bool)   toggles demo mode for group frames
-- @return the portrait frame (or nil)
function BLINKIISPORTRAITS:SetupUnitPortrait(opts)
	local db = BLINKIISPORTRAITS.db.profile
	if not db then return end

	local settings = db[opts.type]
	local parent = opts.parent

	local portrait = BLINKIISPORTRAITS:EnsurePortrait(opts.key, opts.key, parent)
	if not portrait then return end

	if settings.unitframe ~= "auto" then portrait:SetParent(parent) end

	local cellFlag = opts.cellFlag
	if cellFlag == nil then cellFlag = BLINKIISPORTRAITS.Cell_UF end

	local isCellParentFrame = (opts.parentFrame == "cell") and cellFlag
	local isHeaderUnit = opts.isHeaderUnit

	portrait.events = {}
	portrait.parentFrame = parent
	portrait.isCellParentFrame = isCellParentFrame
	portrait.isHeaderUnit = isHeaderUnit
	portrait.unitOverride = opts.unitOverride
	portrait.unitFallback = opts.unitFallback
	portrait.unit = nil -- discard the unit of a previous parent before resolving the current one
	portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
	portrait.type = opts.type
	portrait.db = settings
	portrait.size = settings.size
	portrait.point = settings.point
	portrait.useClassIcon = db.misc.class_icon ~= "none"
	portrait.realUnit = opts.type

	if opts.isGroup then
		if opts.demo then
			portrait.demo = not portrait.demo
		elseif BLINKIISPORTRAITS.SUF then
			portrait.demo = not ShadowUF.db.profile.locked
		end
	else
		portrait.demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
	end

	portrait.isPlayer = nil
	portrait.unitClass = nil
	portrait.lastGUID = nil

	BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, settings)
	BLINKIISPORTRAITS:UpdateSize(portrait)
	BLINKIISPORTRAITS:UpdateCastSettings(portrait)

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(
			format(
				"setup %s | addon: %s | parent: %s | unit: %s | header: %s | cell: %s",
				tostring(opts.key),
				tostring(opts.parentFrame),
				tostring(parent:GetName() or "unnamed"),
				tostring(portrait.unit),
				tostring(isHeaderUnit and true or false),
				tostring(isCellParentFrame and true or false)
			)
		)
	end

	BLINKIISPORTRAITS:InitPortrait(portrait, opts.events)

	return portrait
end

--- Removes a portrait by its key and clears all references to it.
function BLINKIISPORTRAITS:KillPortrait(key)
	local portrait = BLINKIISPORTRAITS.Portraits[key]
	if not portrait then return end

	if portrait.parentFrame and portrait.parentFrame._bpPortrait == portrait then portrait.parentFrame._bpPortrait = nil end

	BLINKIISPORTRAITS:RemovePortrait(portrait)
	BLINKIISPORTRAITS.Portraits[key] = nil
end
