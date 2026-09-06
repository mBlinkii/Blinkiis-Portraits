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
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitIsVisible = UnitIsVisible
-- not present on the long dead classic clients the TBC/Wrath TOCs target
local IsUnitModelReadyForUI = IsUnitModelReadyForUI or function() return true end
local UnitLevel = UnitLevel
local UnitReaction = UnitReaction
local format = format
local gmatch = string.gmatch
local ipairs, type = ipairs, type
local select = select
local strfind, strsplit, strsub = strfind, strsplit, strsub
local tostring = tostring
local CreateColor = CreateColor
-- secret API (WoW 12.1), missing on the classic clients the other TOCs target
local issecretvalue = issecretvalue
local C_ClassColor_GetClassColor = _G.C_ClassColor and _G.C_ClassColor.GetClassColor
local EvalColor = _G.C_CurveUtil and _G.C_CurveUtil.EvaluateColorFromBoolean
-- radial ring API (WoW 12.1), missing on the classic clients the other TOCs target
local UnitHealthMissing = _G.UnitHealthMissing
local UnitCastingDuration = _G.UnitCastingDuration
local UnitChannelDuration = _G.UnitChannelDuration
local UnitEmpoweredChannelDuration = _G.UnitEmpoweredChannelDuration
local RADIAL_RENDER_MODE = BLINKIISPORTRAITS.RadialRenderMode
local StatusBarInterpolation = _G.Enum and _G.Enum.StatusBarInterpolation
local StatusBarTimerDirection = _G.Enum and _G.Enum.StatusBarTimerDirection

local mediaPortraits = BLINKIISPORTRAITS.media.portraits
local mediaExtra = BLINKIISPORTRAITS.media.extra
local mediaClass = BLINKIISPORTRAITS.media.class

local playerFaction = nil

-- shared to avoid per-call allocations
local DEFAULT_COORDS = { 0, 1, 0, 1 }

local function IsSecretValue(value)
	return (issecretvalue and issecretvalue(value)) or false
end

local function SafeValue(value)
	if issecretvalue and issecretvalue(value) then return nil end
	return value
end

-- a secret color has secret components, its alpha must not be branched on
local function SetColor(texture, color)
	if not color then return end

	local alpha = color.a
	texture:SetVertexColor(color.r, color.g, color.b, (IsSecretValue(alpha) or alpha == nil) and 1 or alpha)
end

local function GetReactionType(unit)
	local reaction = SafeValue((unit == "pet") and UnitReaction("player", unit) or UnitReaction(unit, "player"))
	return (reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly")) or "enemy"
end

local function GetCastIcon(unit)
	return select(3, UnitCastingInfo(unit)) or select(3, UnitChannelInfo(unit))
end

local function CreateRing(portrait)
	if portrait.ring or not portrait.ringMode then return end

	local ring = CreateFrame("StatusBar", nil, portrait)
	ring:SetStatusBarTexture(portrait.textureFile)
	ring:SetRenderMode(RADIAL_RENDER_MODE)
	ring:Hide()

	portrait.ring = ring
end

local function GetRingColor(mode)
	local colors = BLINKIISPORTRAITS.db.profile.colors.ring
	return (mode == "cast") and colors.cast or colors.health
end

-- the bar owns its fill texture, so it has to be read again after every SetStatusBarTexture
local function UpdateRingTexture(portrait)
	local ring = portrait.ring
	if not ring then return end

	local db = portrait.db.ring
	local color = GetRingColor(portrait.ringMode)

	ring:SetStatusBarTexture(portrait.textureFile)
	ring:SetStatusBarColor(color.r, color.g, color.b, db.alpha)
	-- SetTimerDuration keeps the range, so the max health of the health mode would stay in here
	if portrait.ringMode == "cast" then ring:SetMinMaxValues(0, 1) end

	local fill = ring:GetStatusBarTexture()
	fill:SetDrawLayer("ARTWORK", 6)
	fill:SetRadialProgressBarFeather(db.feather)
	fill:SetRadialProgressBarReverse(db.reverse)
	-- the option is in degrees, the API takes a fraction of a full turn
	fill:SetRadialProgressBarStartOffset(db.start / 360)
	BLINKIISPORTRAITS:Mirror(fill, portrait.db.mirror)
end

local function UpdateRingSize(portrait)
	local ring = portrait.ring
	if not ring then return end

	ring:ClearAllPoints()
	ring:SetPoint("CENTER", portrait.texture, "CENTER")
	ring:SetSize(portrait.size, portrait.size)
	-- same frame level, so the fill sorts against the portrait regions by draw layer
	ring:SetFrameLevel(portrait:GetFrameLevel())
end

-- the health of a secret unit stays secret and is only handed on, arithmetic on it errors
local function UpdateRingHealth(portrait)
	local ring = portrait.ring
	if not (ring and portrait.unit and portrait.ringMode == "health") then return end

	ring:SetMinMaxValues(0, UnitHealthMax(portrait.unit))

	if portrait.db.ring.invert then
		ring:SetValue(UnitHealthMissing(portrait.unit))
	else
		ring:SetValue(UnitHealth(portrait.unit))
	end

	ring:Show()
end

-- the duration object renders itself, so there is no OnUpdate and no reading of cast times
local function UpdateRingCast(portrait)
	local ring = portrait.ring
	if not (ring and portrait.unit and portrait.ringMode == "cast") then return end

	-- UnitChannelInfo may be secret, the duration objects never are
	local channel = UnitChannelDuration(portrait.unit) or UnitEmpoweredChannelDuration(portrait.unit)
	local duration = channel or UnitCastingDuration(portrait.unit)
	if not duration then return ring:Hide() end

	ring:SetTimerDuration(duration, StatusBarInterpolation.Immediate, channel and StatusBarTimerDirection.RemainingTime or StatusBarTimerDirection.ElapsedTime)
	ring:Show()
end

local function UpdateRing(portrait)
	UpdateRingHealth(portrait)
	UpdateRingCast(portrait)
end

local Update

local RETRY_INTERVAL = 0.2
local MAX_PORTRAIT_TRIES = 10

-- SetPortraitTexture paints black while the model is still loading, so a bounded retry follows
local function RetryPortrait(portrait)
	if portrait.portraitRetry or not portrait:IsVisible() or (portrait.portraitTries or 0) >= MAX_PORTRAIT_TRIES then return end

	portrait.portraitTries = (portrait.portraitTries or 0) + 1
	portrait.portraitRetry = C_Timer.NewTimer(RETRY_INTERVAL, function()
		portrait.portraitRetry = nil
		if portrait:IsVisible() then Update(portrait, "ForceUpdate") end
	end)
end

local function UpdatePortrait(portrait, unit, isNewUnit)
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
	local portraitUnit = unit or portrait.unit
	local useClassIcon = portrait.useClassIcon and not portrait.db.ignoreClassIcons and portrait.isPlayer

	if useClassIcon and not portrait.unitClass then portrait.unitClass = SafeValue(select(2, UnitClass(portraitUnit))) end

	-- a secret class token cannot be a table key, so the class icon is skipped
	local texCoords = (useClassIcon and portrait.unitClass) and portrait.classIcons.texCoords[portrait.unitClass] or nil
	portrait.texCoords = texCoords

	if texCoords then
		portrait.portrait:SetTexture(portrait.classIcons.texture, "CLAMP", "CLAMP", "TRILINEAR")
		portrait.portraitSet = nil

		if BLINKIISPORTRAITS.DebugEnabled then
			BLINKIISPORTRAITS:Debug(format("  texture <- class icon | unit: %s | class: %s", tostring(portraitUnit), tostring(portrait.unitClass)))
		end
	else
		local isAvailable = portrait.state

		-- keep the previous texture while the model is not ready, unless there is nothing worth keeping
		if isAvailable or isNewUnit or not portrait.portraitSet then SetPortraitTexture(portrait.portrait, portraitUnit, true) end

		portrait.portraitSet = isAvailable

		if isAvailable then
			portrait.portraitTries = nil
		else
			RetryPortrait(portrait)
		end

		if BLINKIISPORTRAITS.DebugEnabled then
			BLINKIISPORTRAITS:Debug(
				format("  texture <- SetPortraitTexture | unit: %s | available: %s | result: %s", tostring(portraitUnit), tostring(isAvailable), tostring(portrait.portrait:GetTexture()))
			)
		end
	end

	BLINKIISPORTRAITS:UpdateDesaturated(portrait, (forceDesaturate or portrait.isDead))

	BLINKIISPORTRAITS:Mirror(portrait.portrait, portrait.isPlayer and portrait.db.mirror, texCoords)
end

function Update(portrait, event, eventUnit)
	if not portrait.unit then
		if BLINKIISPORTRAITS.DebugEnabled then BLINKIISPORTRAITS:Debug(format("%s | %s | SKIPPED, no unit resolved", tostring(portrait:GetName()), tostring(event))) end
		return
	end

	local unit = (portrait.demo and not SafeValue(UnitExists(portrait.unit))) and "player" or portrait.unit
	-- a secret GUID must not be compared, the placeholder keeps the change detection working
	local guid = UnitGUID(unit)
	guid = IsSecretValue(guid) and " " or guid

	local isNewUnit = portrait.lastGUID ~= guid
	local isAvailable = (IsUnitModelReadyForUI(unit) and UnitIsConnected(unit) and UnitIsVisible(unit)) or false
	local hasStateChanged = ((event == "ForceUpdate") or isNewUnit or (portrait.state ~= isAvailable))

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(
			format(
				"%s | %s | unit: %s | exists: %s | available: %s | guidChanged: %s | changed: %s",
				tostring(portrait:GetName()),
				tostring(event),
				tostring(unit),
				tostring(SafeValue(UnitExists(unit)) and true or false),
				tostring(isAvailable),
				tostring(isNewUnit),
				tostring(hasStateChanged)
			)
		)
	end

	if hasStateChanged then
		local isSecret, isPlayer, class = BLINKIISPORTRAITS:GetUnitIdentity(unit)

		portrait.isSecret = isSecret
		portrait.isPlayer = isPlayer
		portrait.unitClass = SafeValue(class)
		portrait.lastGUID = guid
		portrait.state = isAvailable
		portrait.unit = unit
		portrait.isDead = not isSecret and SafeValue(UnitIsDead(unit)) or false

		local color = BLINKIISPORTRAITS:GetUnitColor(unit, portrait.isDead, isPlayer, class, isSecret)
		SetColor(portrait.texture, color)

		UpdatePortrait(portrait, unit, isNewUnit)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.forceExtra)

		if portrait.clickable and not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
	end
end

local function CastStart(portrait, _, unit)
	UpdateRingCast(portrait)
	if not portrait.db.cast then return end

	-- without an icon nothing is replaced, so the casting state must stay unset
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
	if portrait.ring and portrait.ringMode == "cast" then portrait.ring:Hide() end

	-- STOP and INTERRUPTED both fire for one cast, so the portrait is restored only once
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

-- the unit state does not change when textures arrive, so this always forces an update
local function PortraitsUpdated(portrait)
	-- a provably absent unit has no texture to refresh, a secret result counts as unknown
	if not portrait.demo and portrait.unit and SafeValue(UnitExists(portrait.unit)) == false then return end

	Update(portrait, "ForceUpdate", portrait.unit)
end

-- group portraits receive these events for every unit, so unrelated ones are filtered out
local function UnitTextureChanged(portrait, event, eventUnit)
	if eventUnit and portrait.unit and eventUnit ~= portrait.unit then
		-- skip only provably different units, a secret result updates anyway
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
	PORTRAITS_UPDATED = PortraitsUpdated,
	UNIT_CONNECTION = Update,
	UNIT_PORTRAIT_UPDATE = UnitTextureChanged,
	UNIT_MODEL_CHANGED = UnitTextureChanged,
	PARTY_MEMBER_ENABLE = Update,
	PARTY_MEMBER_DISABLE = Update,
	ForceUpdate = Update,

	UNIT_HEALTH = UpdateRingHealth,
	UNIT_MAXHEALTH = UpdateRingHealth,

	UNIT_SPELLCAST_CHANNEL_START = CastStart,
	UNIT_SPELLCAST_START = CastStart,

	UNIT_SPELLCAST_CHANNEL_STOP = CastStop,
	UNIT_SPELLCAST_INTERRUPTED = CastStop,
	UNIT_SPELLCAST_STOP = CastStop,

	UNIT_SPELLCAST_EMPOWER_START = CastStart,
	UNIT_SPELLCAST_EMPOWER_STOP = CastStop,

	UNIT_ENTERED_VEHICLE = DelayedUpdate,
	UNIT_EXITING_VEHICLE = SimpleUpdate,
	UNIT_EXITED_VEHICLE = SimpleUpdate,
	VEHICLE_UPDATE = SimpleUpdate,

	PLAYER_TARGET_CHANGED = ForceUpdate,
	PLAYER_FOCUS_CHANGED = ForceUpdate,
	UNIT_TARGET = ForceUpdate,

	GROUP_ROSTER_UPDATE = SimpleUpdate,
	UNIT_NAME_UPDATE = SimpleUpdate,

	ARENA_OPPONENT_UPDATE = Update,
	UNIT_TARGETABLE_CHANGED = Update,
	ARENA_PREP_OPPONENT_SPECIALIZATIONS = SimpleUpdate,
	UPDATE_ACTIVE_BATTLEFIELD = SimpleUpdate,

	INSTANCE_ENCOUNTER_ENGAGE_UNIT = ForceUpdate,
}

local castEvents = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP" }
local empowerEvents = { "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP" }
local healthEvents = { "UNIT_HEALTH", "UNIT_MAXHEALTH" }

-- cast events skip the unit re-resolution
local castEventLookup = {}
for _, event in ipairs(castEvents) do
	castEventLookup[event] = true
end
for _, event in ipairs(empowerEvents) do
	castEventLookup[event] = true
end

-- oUF renamed frame.unit to __unit (ElvUI 15.22), Cell uses _unit, header frames only the attribute
function BLINKIISPORTRAITS:GetFrameUnit(frame)
	if not frame then return nil end

	return frame.__unit or frame._unit or (frame.GetAttribute and frame:GetAttribute("unit")) or frame.unit
end

function BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
	local parent = portrait.parentFrame
	if not parent then return portrait.unit end

	return portrait.unitOverride or BLINKIISPORTRAITS:GetFrameUnit(parent) or portrait.unit or portrait.unitFallback
end

local function OnEvent(portrait, event, eventUnit, arg)
	-- a hidden portrait has nothing to repaint; OnShow catches up with a single forced update
	if not portrait:IsVisible() then return end

	local handler = eventHandlers[event]

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(format("event %s | %s | eventUnit: %s | handler: %s", tostring(event), tostring(portrait:GetName()), tostring(eventUnit), tostring(handler ~= nil)))
	end

	if not handler then return end

	-- the unit cannot change mid cast, and only group frames hand out new unit tokens at all
	if not castEventLookup[event] and (portrait.isDynamicUnit or not portrait.unit) then
		portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
		BLINKIISPORTRAITS:ApplyUnitEvents(portrait)
	end

	handler(portrait, event, eventUnit, arg)
end

-- events are ignored while hidden, so a portrait that becomes visible has to catch up
local function OnShow(portrait)
	if not portrait.db then return end

	portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
	BLINKIISPORTRAITS:ApplyUnitEvents(portrait)
	Update(portrait, "ForceUpdate", portrait.unit)
	UpdateRing(portrait)
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

function BLINKIISPORTRAITS:UpdateTextures(portrait)
	local mirror = portrait.db.mirror

	SetTexture(portrait.texture, portrait.textureFile, "CLAMP")
	SetTexture(portrait.mask, portrait.maskFile, "CLAMPTOBLACKADDITIVE")

	if portrait.extraMask then SetTexture(portrait.extraMask, portrait.extraMaskFile, "CLAMPTOBLACKADDITIVE") end
	SetTexture(portrait.bg, portrait.bgFile, "CLAMP")

	UpdateRingTexture(portrait)

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

-- nil for player GUIDs, missing GUIDs and the secret placeholder
local function GetNpcID(guid)
	if not guid or guid == " " then return nil end
	return select(6, strsplit("-", guid))
end

-- secret results are treated as unknown and skipped
local function IsBossTokenUnit(unit)
	-- the tokens are filled sequentially, so without boss1 there is no encounter to compare against
	if not SafeValue(UnitExists(bossTokens[1])) then return false end

	for i = 1, MAX_BOSS_UNITS do
		local token = bossTokens[i]
		if SafeValue(UnitExists(token)) and SafeValue(UnitIsUnit(unit, token)) then return true end
	end
	return false
end

-- boss detection in order: portrait type, cached npcID, boss token, classification, level -1
function BLINKIISPORTRAITS:GetExtraClassification(portrait)
	local unit = portrait.unit
	if not unit then return nil end

	-- a secret unit can be a hostile NPC, so only a proven player skips the NPC checks
	local isKnownPlayer = portrait.isPlayer and not portrait.isSecret
	local npcID = GetNpcID(portrait.lastGUID)
	local classification = SafeValue(UnitClassification(unit))
	if classification == "worldboss" then classification = "boss" end

	local isBoss = (portrait.type == "boss")
		or (npcID and BLINKIISPORTRAITS.CachedBossIDs[npcID])
		or (classification == "boss")
		or (not isKnownPlayer and IsBossTokenUnit(unit))
		or (not isKnownPlayer and SafeValue(UnitLevel(unit)) == -1)

	if isBoss then
		-- learn the npcID for reliable pre-pull detection in future sessions
		if npcID and not BLINKIISPORTRAITS.CachedBossIDs[npcID] then BLINKIISPORTRAITS.CachedBossIDs[npcID] = true end
		return "boss"
	end

	return extraTypes[classification] and classification or nil
end

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
		SetColor(portrait.extra, color)
		portrait.extra:Show()
	else
		portrait.extra:Hide()
	end
end

-- a secret class token must not be nil checked or used as a table key, the game API answers it with a secret color
local function GetClassColor(class)
	if IsSecretValue(class) then return C_ClassColor_GetClassColor and C_ClassColor_GetClassColor(class) end

	if not class then return nil end

	return BLINKIISPORTRAITS.db.profile.colors.class[class]
end

-- a secret unit is hostile but can still be an NPC, so let the API branch on the identity instead of guessing
local function GetSecretColor(unit, colors, class)
	local enemy = colors.reaction.enemy
	local c = EvalColor and GetClassColor(class)

	if not c then return enemy end

	-- secret color channels are fine here, only the alpha has to stay plain
	return EvalColor(UnitIsPlayer(unit), CreateColor(c.r, c.g, c.b, 1), CreateColor(enemy.r, enemy.g, enemy.b, 1))
end

function BLINKIISPORTRAITS:GetUnitColor(unit, isDead, isPlayer, class, isSecret)
	if not unit then return end

	local profile = BLINKIISPORTRAITS.db.profile
	local colors = profile.colors

	if isDead then return colors.misc.death, isPlayer end

	if profile.misc.force_default then return colors.misc.default, isPlayer end

	if isSecret then return (profile.misc.force_reaction and colors.reaction.enemy or GetSecretColor(unit, colors, class)), isPlayer end

	if isPlayer then
		if profile.misc.force_reaction then
			local unitFaction = SafeValue(UnitFactionGroup(unit))
			playerFaction = playerFaction or UnitFactionGroup("player")

			local reactionType = (playerFaction == unitFaction) and "friendly" or "enemy"
			return colors.reaction[reactionType], isPlayer
		else
			return GetClassColor(class) or colors.misc.default
		end
	else
		return colors.reaction[GetReactionType(unit)], isPlayer
	end
end

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

local function UpdateZoom(portrait)
	local zoom = BLINKIISPORTRAITS.db.profile.misc.zoom
	local offset = (portrait.size / 2) * zoom
	local texture = portrait.portrait

	-- anchor explicitly to the portrait frame; a single consistent anchor model
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", portrait, "TOPLEFT", -offset, offset)
	texture:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", offset, -offset)
end

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

		UpdateRingSize(portrait)
	end
end

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

-- supports dotted paths like "Stuf.units.player"
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

function BLINKIISPORTRAITS:GetUnitFrameName(unit, addonType)
	if not addonType then return nil end
	return GetUnitFrame(unit, addonType)
end

-- "unit" restricts an entry to a specific unit (Cell and DandersFrames: party only)
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

local function IsEntryAvailable(entry, unit)
	return BLINKIISPORTRAITS[entry.flag] and (not entry.unit or entry.unit == unit)
end

-- a loaded addon with a gap in its mapping must not block a lower priority addon
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

-- UNIT_TARGET fires for the unit whose target changed, so targettarget listens to "target"
local unitEventOverrides = {
	UNIT_TARGET = "target",
}

-- unit filtered whenever a unit is resolved, re-registering an event just re-targets it
function BLINKIISPORTRAITS:RegisterEvents(portrait, events)
	local unit = portrait.unit

	for _, event in ipairs(events) do
		if unit and strsub(event, 1, 5) == "UNIT_" then
			portrait:RegisterUnitEvent(event, unitEventOverrides[event] or unit)
		else
			portrait:RegisterEvent(event)
		end
	end
end

function BLINKIISPORTRAITS:ApplyUnitEvents(portrait, force)
	local unit = portrait.unit
	if not force and portrait.registeredUnit == unit then return end

	-- without a resolved unit everything stays unfiltered so the portrait can recover
	portrait.registeredUnit = unit

	if portrait.eventList then BLINKIISPORTRAITS:RegisterEvents(portrait, portrait.eventList) end

	if portrait.cast then
		BLINKIISPORTRAITS:RegisterEvents(portrait, castEvents)

		if BLINKIISPORTRAITS.Retail then BLINKIISPORTRAITS:RegisterEvents(portrait, empowerEvents) end
	end

	BLINKIISPORTRAITS:UpdateRingEvents(portrait)
end

function BLINKIISPORTRAITS:RemovePortrait(frame)
	if frame._delayedUpdateTimer then
		frame._delayedUpdateTimer:Cancel()
		frame._delayedUpdateTimer = nil
	end

	if frame.portraitRetry then
		frame.portraitRetry:Cancel()
		frame.portraitRetry = nil
	end

	if frame.ring then frame.ring:Hide() end
	if frame.texture then frame.texture:SetAlpha(1) end

	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	frame:SetScript("OnShow", nil)
	frame.eventsSet = nil
	frame.castEventsSet = nil
	frame.ringMode = nil
	frame.ringEventsSet = nil
	frame.cast = nil
	frame.eventList = nil
	frame.registeredUnit = nil
	frame.portraitSet = nil
	frame.portraitTries = nil
	frame:Hide()
end

local function GetPortraitFrameName(name, clickable)
	return "BP_Portrait_" .. name .. (clickable and "_Clickable" or "_Display")
end

local function HideInactivePortrait(name, clickable)
	local inactiveFrame = _G[GetPortraitFrameName(name, not clickable)]
	if inactiveFrame then BLINKIISPORTRAITS:RemovePortrait(inactiveFrame) end
end

function BLINKIISPORTRAITS:CreatePortrait(name, parent)
	if parent then
		local clickable = BLINKIISPORTRAITS.db.profile.misc.clickable
		local frameName = GetPortraitFrameName(name, clickable)
		local portrait = _G[frameName]

		HideInactivePortrait(name, clickable)

		if not portrait then
			portrait = CreateFrame(clickable and "Button" or "Frame", frameName, parent, clickable and "SecureUnitButtonTemplate" or nil)

			portrait.texture = portrait:CreateTexture("BP_texture-" .. name .. (clickable and "_Clickable" or "_Display"), "ARTWORK", nil, 4)
			portrait.texture:SetPoint("CENTER", portrait, "CENTER", 0, 0)

			portrait.mask = portrait:CreateMaskTexture()
			portrait.mask:SetAllPoints(portrait.texture)

			portrait.portrait = portrait:CreateTexture("BP_portrait-" .. name .. (clickable and "_Clickable" or "_Display"), "ARTWORK", nil, 2)
			portrait.portrait:SetAllPoints(portrait.texture)
			portrait.portrait:AddMaskTexture(portrait.mask)

			local extraOnTop = BLINKIISPORTRAITS.db.profile.misc.extratop
			portrait.extra = portrait:CreateTexture("BP_extra-" .. name .. (clickable and "_Clickable" or "_Display"), "OVERLAY", nil, extraOnTop and 7 or 1)
			portrait.extra:SetAllPoints(portrait.texture)

			if not extraOnTop then
				portrait.extraMask = portrait:CreateMaskTexture()
				portrait.extraMask:SetAllPoints(portrait.texture)
				portrait.extra:AddMaskTexture(portrait.extraMask)
			end

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

function BLINKIISPORTRAITS:InitPortrait(portrait, events)
	if portrait then
		BLINKIISPORTRAITS:UpdateTextures(portrait)

		portrait.eventList = events

		if not portrait.eventsSet then
			portrait:SetScript("OnEvent", OnEvent)
			portrait:SetScript("OnShow", OnShow)
			portrait.eventsSet = true
		end

		BLINKIISPORTRAITS:ApplyUnitEvents(portrait, true)
		OnEvent(portrait, "ForceUpdate", portrait.unit)
		UpdateRing(portrait)

		UpdateZoom(portrait)
	end
end

local function UnregisterEvents(portrait, events)
	for _, event in ipairs(events) do
		portrait:UnregisterEvent(event)
	end
end

function BLINKIISPORTRAITS:RegisterCastEvents(portrait)
	if not portrait.castEventsSet then
		BLINKIISPORTRAITS:RegisterEvents(portrait, castEvents)

		if BLINKIISPORTRAITS.Retail then BLINKIISPORTRAITS:RegisterEvents(portrait, empowerEvents) end
		portrait.castEventsSet = true
	end
end

function BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
	UnregisterEvents(portrait, castEvents)

	if BLINKIISPORTRAITS.Retail then UnregisterEvents(portrait, empowerEvents) end
	portrait.castEventsSet = false
end

function BLINKIISPORTRAITS:UpdateCastSettings(portrait)
	local needsCast = (portrait.db.cast or portrait.ringMode == "cast") and true or false

	if needsCast then
		BLINKIISPORTRAITS:RegisterCastEvents(portrait)
	elseif portrait.cast then
		BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
	end

	portrait.cast = needsCast
end

function BLINKIISPORTRAITS:UpdateRingEvents(portrait)
	if portrait.ringMode == "health" then
		BLINKIISPORTRAITS:RegisterEvents(portrait, healthEvents)
		portrait.ringEventsSet = true
	elseif portrait.ringEventsSet then
		UnregisterEvents(portrait, healthEvents)
		portrait.ringEventsSet = false
	end
end

-- the border below the fill is dimmed, otherwise the ring is not readable against it
function BLINKIISPORTRAITS:UpdateRingSettings(portrait)
	local db = portrait.db.ring
	portrait.ringMode = (RADIAL_RENDER_MODE and db and db.mode ~= "none") and db.mode or nil

	CreateRing(portrait)

	portrait.texture:SetAlpha(portrait.ringMode and db.baseAlpha or 1)
	if portrait.ring and not portrait.ringMode then portrait.ring:Hide() end
end

function BLINKIISPORTRAITS:SetupUnitPortrait(opts)
	local db = BLINKIISPORTRAITS.db.profile
	if not db then return end

	local settings = db[opts.type]
	local parent = opts.parent

	local portrait = BLINKIISPORTRAITS:EnsurePortrait(opts.key, opts.key, parent)
	if not portrait then return end

	if settings.unitframe ~= "auto" then portrait:SetParent(parent) end

	portrait.parentFrame = parent
	portrait.parentAddon = opts.parentFrame
	portrait.unitOverride = opts.unitOverride
	portrait.unitFallback = opts.unitFallback
	portrait.isDynamicUnit = opts.isDynamicUnit
	portrait.unit = nil -- discard the unit of a previous parent before resolving the current one
	portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
	portrait.type = opts.type
	portrait.db = settings
	portrait.size = settings.size
	portrait.point = settings.point
	-- a selected style can vanish when custom or JiberishIcons packs are deleted
	portrait.useClassIcon = db.misc.class_icon ~= "none" and mediaClass[db.misc.class_icon] ~= nil
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
	BLINKIISPORTRAITS:UpdateRingSettings(portrait)
	BLINKIISPORTRAITS:UpdateSize(portrait)
	BLINKIISPORTRAITS:UpdateCastSettings(portrait)

	if BLINKIISPORTRAITS.DebugEnabled then
		BLINKIISPORTRAITS:Debug(format("setup %s | addon: %s | parent: %s | unit: %s", tostring(opts.key), tostring(opts.parentFrame), tostring(parent:GetName() or "unnamed"), tostring(portrait.unit)))
	end

	BLINKIISPORTRAITS:InitPortrait(portrait, opts.events)

	return portrait
end

function BLINKIISPORTRAITS:KillPortrait(key)
	local portrait = BLINKIISPORTRAITS.Portraits[key]
	if not portrait then return end

	if portrait.parentFrame and portrait.parentFrame._bpPortrait == portrait then portrait.parentFrame._bpPortrait = nil end

	BLINKIISPORTRAITS:RemovePortrait(portrait)
	BLINKIISPORTRAITS.Portraits[key] = nil
end
