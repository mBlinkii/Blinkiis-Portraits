local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassification = UnitClassification
local UnitFactionGroup = UnitFactionGroup
local UnitIsDead = UnitIsDead
local UnitExists = UnitExists
local select, tinsert = select, tinsert

local mediaPortraits = BLINKIISPORTRAITS.media.portraits
local mediaExtra = BLINKIISPORTRAITS.media.extra
local mediaClass = BLINKIISPORTRAITS.media.class

local playerFaction = nil

-- portrait texture update functions
local function Update(portrait, event, eventUnit)
	if not portrait.unit or not eventUnit or not UnitIsUnit(portrait.unit, eventUnit) then return end

	local unit = (portrait.demo and not UnitExists(portrait.unit)) and "player" or portrait.unit
	local guid = UnitGUID(unit)
	local isAvailable = UnitIsConnected(unit) and UnitIsVisible(unit)
	local hasStateChanged = ((event == "ForceUpdate") or (portrait.guid ~= guid) or (portrait.state ~= isAvailable))

	if hasStateChanged then
		local class = select(2, UnitClass(unit))
		local isPlayer = UnitIsPlayer(unit) or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit))

		portrait.isPlayer = isPlayer
		portrait.unitClass = class
		portrait.lastGUID = guid
		portrait.state = isAvailable
		portrait.unit = unit

		local color = BLINKIISPORTRAITS:GetUnitColor(unit, portrait.isDead, isPlayer, class)
		if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

		BLINKIISPORTRAITS:UpdatePortrait(portrait, event, unit)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.forceExtra)

		if not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
	end
end

local debounceTimers = {
	player = nil,
	pet = nil,
}

local latestArgs = {
	player = nil,
	pet = nil,
}

local function VehicleUpdate(portrait, _, unit, arg2)
	local realUnit = portrait.realUnit
	local isInVehicle = (UnitInVehicle("player") or arg2)

	-- Cache arguments
	latestArgs[realUnit] = { portrait = portrait, unit = unit, isInVehicle = isInVehicle }

	-- Cancel previous timer
	if debounceTimers[realUnit] then debounceTimers[realUnit]:Cancel() end

	-- Start timer (e.g. 0.3 second delay)
	debounceTimers[realUnit] = C_Timer.NewTimer(0.3, function()
		local args = latestArgs[realUnit]
		if args == nil then return end
		local p, u, iV = args.portrait, args.unit, args.isInVehicle

		-- print("VehicleUpdate", u, iV, p.realUnit)

		if p.realUnit == "player" then
			u = iV and "pet" or "player"
		elseif p.realUnit == "pet" then
			u = iV and "player" or "pet"
		end

		-- print("VehicleUpdate unit", u)
		Update(p, "ForceUpdate", u)
	end)
end

local function ForceUpdate(portrait, _, unit)
	Update(portrait, "ForceUpdate", unit or portrait.unit)
end

local eventHandlers = {
	-- portrait updates
	PORTRAITS_UPDATED = ForceUpdate,
	UNIT_CONNECTION = Update,
	UNIT_PORTRAIT_UPDATE = Update,
	PARTY_MEMBER_ENABLE = Update,
	ForceUpdate = Update,

	-- vehicle updates
	UNIT_ENTERED_VEHICLE = VehicleUpdate,
	UNIT_EXITING_VEHICLE = VehicleUpdate,
	UNIT_EXITED_VEHICLE = VehicleUpdate,
	VEHICLE_UPDATE = VehicleUpdate,

	-- target/ focus updates
	PLAYER_TARGET_CHANGED = function(portrait, event, unit)
		Update(portrait, event, unit or portrait.unit)
	end,
	PLAYER_FOCUS_CHANGED = function(portrait, event, unit)
		Update(portrait, event, unit or portrait.unit)
	end,
	UNIT_TARGET = function(portrait, event)
		Update(portrait, event, portrait.unit)
	end,

	-- party
	GROUP_ROSTER_UPDATE = ForceUpdate,

	-- arena
	ARENA_OPPONENT_UPDATE = Update,
	UNIT_TARGETABLE_CHANGED = Update,
	ARENA_PREP_OPPONENT_SPECIALIZATIONS = ForceUpdate,
	INSTANCE_ENCOUNTER_ENGAGE_UNIT = ForceUpdate,
	UPDATE_ACTIVE_BATTLEFIELD = ForceUpdate,

	-- death updates
	UNIT_HEALTH = function(portrait, _, unit)
		portrait.isDead = BLINKIISPORTRAITS:UpdateDeathStatus(unit)
	end,
}

local function OnEvent(portrait, event, eventUnit, arg)
	local unit = portrait.isCellParentFrame and portrait.parentFrame._unit or portrait.parentFrame.unit
	portrait.unit = unit

	if eventHandlers[event] then eventHandlers[event](portrait, event, eventUnit, arg) end
end

function BLINKIISPORTRAITS:Mirror(texture, mirror, texCoords)
	if texCoords then
		local coords = texCoords
		if #coords == 8 then
			texture:SetTexCoord(unpack((mirror and { coords[5], coords[6], coords[7], coords[8], coords[1], coords[2], coords[3], coords[4] } or coords)))
		else
			texture:SetTexCoord(unpack((mirror and { coords[2], coords[1], coords[3], coords[4] } or coords)))
		end
	else
		texture:SetTexCoord(mirror and 1 or 0, mirror and 0 or 1, 0, 1)
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

	BLINKIISPORTRAITS:Mirror(portrait.texture, mirror)
	BLINKIISPORTRAITS:Mirror(portrait.extra, mirror)
end

function BLINKIISPORTRAITS:UpdateExtraTexture(portrait, color, force)
	if not (portrait.extra and portrait.db.extra) then
		if portrait.extra then portrait.extra:Hide() end
		return
	end

	local c = portrait.type == "boss" and "boss" or ((BLINKIISPORTRAITS.CachedBossIDs[portrait.lastGUID] and "boss") or UnitClassification(portrait.unit))
	local isExtraUnit = c == "rare" or c == "elite" or c == "rareelite" or c == "boss"
	if not isExtraUnit and (force and force ~= "none") then c = force end

	if ((force and force ~= "none") or isExtraUnit) and not color then
		if BLINKIISPORTRAITS.db.profile.misc.force_reaction then
			local colorReaction = BLINKIISPORTRAITS.db.profile.colors.reaction
			local reaction = UnitReaction(portrait.unit, "player")
			local reactionType = reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly") or "enemy"
			color = colorReaction[reactionType]
		else
			local colorClassification = BLINKIISPORTRAITS.db.profile.colors.classification
			color = colorClassification[c]
		end
	end

	if color then
		portrait.extra:SetTexture(portrait[c .. "File"], "CLAMP", "CLAMP", "TRILINEAR")
		portrait.extra:SetVertexColor(color.r, color.g, color.b, color.a or 1)
		portrait.extra:Show()
	else
		portrait.extra:Hide()
	end
end

function BLINKIISPORTRAITS:UpdatePortrait(portrait, event, unit)
	local showCastIcon = portrait.db.cast and BLINKIISPORTRAITS:UpdateCastIcon(portrait, event)
	local forceDesaturate = BLINKIISPORTRAITS.db.profile.misc.desaturate

	if not showCastIcon then
		if portrait.useClassIcon and (portrait.isPlayer or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit or portrait.unit))) then
			portrait.unitClass = portrait.unitClass or select(2, UnitClass(portrait.unit))
			portrait.texCoords = portrait.classIcons.texCoords[portrait.unitClass]
			portrait.portrait:SetTexture(portrait.classIcons.texture, "CLAMP", "CLAMP", "TRILINEAR")
		else
			SetPortraitTexture(portrait.portrait, unit or portrait.unit, true)
		end

		BLINKIISPORTRAITS:UpdateDesaturated(portrait, (forceDesaturate or portrait.isDead))
	end

	BLINKIISPORTRAITS:Mirror(portrait.portrait, portrait.isPlayer and portrait.db.mirror, (portrait.isPlayer and portrait.useClassIcon) and portrait.texCoords)
end

-- color functions
function BLINKIISPORTRAITS:GetUnitColor(unit, isDead, isPlayer, class)
	if not unit then return end

	local colors = BLINKIISPORTRAITS.db.profile.colors

	if isDead then return colors.misc.death, isPlayer end

	if BLINKIISPORTRAITS.db.profile.misc.force_default then return colors.misc.default, isPlayer end

	if isPlayer then
		if BLINKIISPORTRAITS.db.profile.misc.force_reaction then
			local unitFaction = select(1, UnitFactionGroup(unit))
			playerFaction = playerFaction or select(1, UnitFactionGroup("player"))

			local reactionType = (playerFaction == unitFaction) and "friendly" or "enemy"
			return colors.reaction[reactionType], isPlayer
		else
			return class and colors.class[class] or colors.misc.default
		end
	else
		local reaction = (unit == "pet") and UnitReaction("player", unit) or UnitReaction(unit, "player")
		local reactionType = (reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly")) or "enemy"
		return colors.reaction[reactionType], isPlayer
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

-- unit status functions
function BLINKIISPORTRAITS:UpdateDeathStatus(portrait, unit)
	local isDead = (UnitExists(unit) and UnitIsDead(unit))
	if isDead then
		local deathColor = BLINKIISPORTRAITS.db.profile.colors.misc.death
		BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
		portrait.texture:SetVertexColor(deathColor.r, deathColor.g, deathColor.b, deathColor.a or 1)
	end
	return isDead
end

-- update settings functions
local function UpdateZoom(texture, size)
	local zoom = BLINKIISPORTRAITS.db.profile.misc.zoom
	local offset = (size / 2) * zoom

	texture:SetPoint("TOPLEFT", 0 - offset, 0 + offset)
	texture:SetPoint("BOTTOMRIGHT", 0 + offset, 0 - offset)
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
	end
end

function BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, settings)
	local dbMisc = BLINKIISPORTRAITS.db.profile.misc
	local dbCustom = BLINKIISPORTRAITS.db.profile.custom
	local media = mediaPortraits[settings.texture]

	portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\media\\blank.tga"

	if portrait.useClassIcon then portrait.classIcons = mediaClass[BLINKIISPORTRAITS.db.profile.misc.class_icon] end

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
local function GetUnitFrame(unit, type)
	local unitFrames = {
		elvui = {
			player = "ElvUF_Player",
			target = "ElvUF_Target",
			pet = "ElvUF_Pet",
			targettarget = "ElvUF_TargetTarget",
			focus = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Focus",
			party = "ElvUF_PartyGroup1UnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Boss",
			arena = "ElvUF_Arena",
		},
		suf = {
			player = "SUFUnitplayer",
			target = "SUFUnittarget",
			pet = "SUFUnitpet",
			targettarget = "SUFUnittargettarget",
			focus = BLINKIISPORTRAITS.Classic and nil or "SUFUnitfocus",
			party = "SUFHeaderpartyUnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "SUFHeaderbossUnitButton",
			arena = "SUFHeaderarenaUnitButton",
		},
		cell = {
			player = "CUF_Player",
			target = "CUF_Target",
			pet = "CUF_Pet",
			targettarget = "CUF_TargetTarget",
			focus = BLINKIISPORTRAITS.Classic and nil or "CUF_Focus",
			party = "CellPartyFrameHeaderUnitButton",
			boss = "CUF_Boss",
			arena = "CUF_Arena",
		},
		pb4 = {
			singleUnits = function()
				local PitBull4 = _G.PitBull4
				local PB4_SingleUnits = PitBull4.db.profile.units
				local validSingleUnits = {
					player = true,
					target = true,
					pet = true,
					targettarget = true,
					focus = BLINKIISPORTRAITS.Classic and nil or true,
				}

				local frames = {}
				for singleName, value in pairs(PB4_SingleUnits) do
					if value and validSingleUnits[value.unit] then frames[value.unit] = "PitBull4_Frames_" .. singleName end
				end
				return frames
			end,
			groupUnits = function()
				local PitBull4 = _G.PitBull4
				local PB4_GroupUnits = PitBull4.db.profile.groups
				local validGroupUnits = {
					party = true,
					boss = BLINKIISPORTRAITS.Classic and nil or true,
					arena = BLINKIISPORTRAITS.Classic and nil or true,
				}

				local frames = {}
				for groupName, value in pairs(PB4_GroupUnits) do
					if value and validGroupUnits[value.unit_group] then frames[value.unit_group] = format("PitBull4_Groups_%sUnitButton", groupName) end
				end
				return frames
			end,
		},
		uuf = {
			player = "UUF_Player",
			target = "UUF_Target",
			pet = "UUF_Pet",
			targettarget = "UUF_TargetTarget",
			focus = "UUF_Focus",
			party = nil, -- uff has no party frames
			boss = "UUF_Boss",
			arena = nil, -- uff has no arena frames
		},
		ndui = {
			player = "oUF_Player",
			target = "oUF_Target",
			pet = "oUF_Pet",
			targettarget = "oUF_ToT",
			focus = BLINKIISPORTRAITS.Classic and nil or "oUF_Focus",
			party = "oUF_PartyUnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "oUF_Boss",
			arena = BLINKIISPORTRAITS.Classic and nil or "oUF_Arena",
		},
	}

	if type == "pb4" then
		local singleFrames = unitFrames.pb4.singleUnits()
		local groupFrames = unitFrames.pb4.groupUnits()
		return singleFrames[unit] or groupFrames[unit]
	else
		return unitFrames[type][unit]
	end
end

function BLINKIISPORTRAITS:GetUnitFrames(unit, parent)
	local type
	if BLINKIISPORTRAITS.Cell and (parent == "auto" or parent == "cell") then
		type = "cell"
	elseif BLINKIISPORTRAITS.ELVUI and (parent == "auto" or parent == "elvui") then
		type = "elvui"
	elseif BLINKIISPORTRAITS.PB4 and (parent == "auto" or parent == "pb4") then
		type = "pb4"
	elseif BLINKIISPORTRAITS.SUF and (parent == "auto" or parent == "suf") then
		type = "suf"
	elseif BLINKIISPORTRAITS.UUF and (parent == "auto" or parent == "uuf") then
		type = "uuf"
	elseif BLINKIISPORTRAITS.NDUI and (parent == "auto" or parent == "ndui") then
		type = "ndui"
	end

	if type then
		return GetUnitFrame(unit, type), type
	else
		if BLINKIISPORTRAITS.Cell then
			return GetUnitFrame(unit, "cell"), "cell"
		elseif BLINKIISPORTRAITS.ELVUI then
			return GetUnitFrame(unit, "elvui"), "elvui"
		elseif BLINKIISPORTRAITS.PB4 then
			return GetUnitFrame(unit, "pb4"), "pb4"
		elseif BLINKIISPORTRAITS.SUF then
			return GetUnitFrame(unit, "suf"), "suf"
		elseif BLINKIISPORTRAITS.UUF then
			return GetUnitFrame(unit, "uuf"), "uuf"
		elseif BLINKIISPORTRAITS.NDUI then
			return GetUnitFrame(unit, "ndui"), "ndui"
		end
	end
end

function BLINKIISPORTRAITS:RegisterEvents(portrait, events, cast)
	for _, event in pairs(events) do
		if cast and portrait.type ~= "party" then
			portrait:RegisterUnitEvent(event, portrait.unit)
		else
			portrait:RegisterEvent(event)
		end
		tinsert(portrait.events, event)
	end

	-- death check
	if portrait.type == "party" then
		portrait:RegisterEvent("UNIT_HEALTH")
	else
		portrait:RegisterUnitEvent("UNIT_HEALTH", portrait.unit)
	end
	tinsert(portrait.events, "UNIT_HEALTH")
end

function BLINKIISPORTRAITS:RemovePortrait(frame)
	if frame and frame.events then
		for _, event in pairs(frame.events) do
			frame:UnregisterEvent(event)
		end
	end

	frame:Hide()
	frame = nil
end

function BLINKIISPORTRAITS:CreatePortrait(name, parent)
	if parent then
		local portrait = CreateFrame("Button", "BP_Portrait_" .. name, parent, "SecureUnitButtonTemplate")

		-- texture
		portrait.texture = portrait:CreateTexture("BP_texture-" .. name, "ARTWORK", nil, 4)
		portrait.texture:SetPoint("CENTER", portrait, "CENTER", 0, 0)

		-- mask
		portrait.mask = portrait:CreateMaskTexture()
		portrait.mask:SetAllPoints(portrait.texture)

		-- portrait
		portrait.portrait = portrait:CreateTexture("BP_portrait-" .. name, "ARTWORK", nil, 2)
		portrait.portrait:SetAllPoints(portrait.texture)
		portrait.portrait:AddMaskTexture(portrait.mask)
		local unit = (parent.unit == "party" or not parent.unit) and "player" or parent.unit

		-- rare/elite/boss
		local extraOnTop = BLINKIISPORTRAITS.db.profile.misc.extratop
		portrait.extra = portrait:CreateTexture("BP_extra-" .. name, "OVERLAY", nil, extraOnTop and 7 or 1)
		portrait.extra:SetAllPoints(portrait.texture)

		-- extra mask
		if not extraOnTop then
			portrait.extraMask = portrait:CreateMaskTexture()
			portrait.extraMask:SetAllPoints(portrait.texture)
			portrait.extra:AddMaskTexture(portrait.extraMask)
		end

		-- bg
		portrait.bg = portrait:CreateTexture("BP_bg-" .. name, "BACKGROUND", nil, 1)
		portrait.bg:SetAllPoints(portrait.texture)
		portrait.bg:AddMaskTexture(portrait.mask)
		portrait.bg:SetVertexColor(0, 0, 0, 1)

		-- scripts to interact with mouse
		portrait:SetAttribute("unit", portrait.unit)
		portrait:SetAttribute("*type1", "target")
		portrait:SetAttribute("*type2", "togglemenu")
		portrait:SetAttribute("type3", "focus")
		portrait:SetAttribute("toggleForVehicle", true)
		portrait:SetAttribute("ping-receiver", true)
		portrait:RegisterForClicks("AnyUp")
		portrait:Show()

		return portrait
	end
end

function BLINKIISPORTRAITS:InitPortrait(portrait, events)
	if portrait then
		BLINKIISPORTRAITS:UpdateTextures(portrait)

		if not portrait.eventsSet then
			BLINKIISPORTRAITS:RegisterEvents(portrait, events)

			portrait:SetScript("OnEvent", OnEvent)
			portrait.eventsSet = true
		end
		OnEvent(portrait, "ForceUpdate", portrait.unit)

		UpdateZoom(portrait.portrait, portrait.size)
	end
end

-- cast functions
local castStartEvents = {
	UNIT_SPELLCAST_START = true,
	UNIT_SPELLCAST_CHANNEL_START = true,
	UNIT_SPELLCAST_EMPOWER_START = true,
}

local castStopEvents = {
	UNIT_SPELLCAST_INTERRUPTED = true,
	UNIT_SPELLCAST_STOP = true,
	UNIT_SPELLCAST_CHANNEL_STOP = true,
	UNIT_SPELLCAST_EMPOWER_STOP = true,
}

local function GetCastIcon(unit)
	return select(3, UnitCastingInfo(unit)) or select(3, UnitChannelInfo(unit))
end

function BLINKIISPORTRAITS:UpdateCastIcon(portrait, event)
	portrait.castStarted = castStartEvents[event] or false
	portrait.castStopped = castStopEvents[event] or false

	if portrait.castStarted or (portrait.isCasting and not portrait.castStopped) then
		portrait.isCasting = true
		portrait.empowering = (event == "UNIT_SPELLCAST_EMPOWER_START") or false
		local texture = GetCastIcon(portrait.unit)
		if texture then
			portrait.portrait:SetTexture(texture)
			return true
		end
		return false
	elseif portrait.castStopped or (portrait.isCasting and not GetCastIcon(portrait.unit)) then
		portrait.isCasting = false
		return false
	end

	return false
end

local castEvents = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP" }
local empowerEvents = { "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_STOP" }

local function UnregisterEvents(portrait, events)
	for _, event in pairs(events) do
		portrait:UnregisterEvent(event)
	end
end

function BLINKIISPORTRAITS:RegisterCastEvents(portrait)
	if not portrait.castEventsSet then
		BLINKIISPORTRAITS:RegisterEvents(portrait, castEvents, true)

		if BLINKIISPORTRAITS.Retail then BLINKIISPORTRAITS:RegisterEvents(portrait, empowerEvents, true) end
		portrait.castEventsSet = true
	end
end

function BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
	UnregisterEvents(portrait, castEvents)

	if BLINKIISPORTRAITS.Retail then UnregisterEvents(portrait, empowerEvents) end
	portrait.castEventsSet = false
end

function BLINKIISPORTRAITS:UpdateCastSettings(portrait)
	if portrait.db.cast then
		BLINKIISPORTRAITS:RegisterCastEvents(portrait)
		portrait.cast = true
	elseif portrait.cast then
		BLINKIISPORTRAITS:UnregisterCastEvents(portrait)
		portrait.cast = false
	end
end
