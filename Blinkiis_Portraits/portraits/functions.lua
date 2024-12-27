local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassification = UnitClassification
local UnitFactionGroup = UnitFactionGroup
local select, tinsert = select, tinsert

local mediaPortraits = BLINKIISPORTRAITS.media.portraits
local mediaExtra = BLINKIISPORTRAITS.media.extra
function BLINKIISPORTRAITS:RegisterEvents(portrait, events, cast)
	for _, event in pairs(events) do
		if cast and portrait.type ~= "party" then
			portrait:RegisterUnitEvent(event, portrait.unit)
		else
			portrait:RegisterEvent(event)
		end
		tinsert(portrait.events, event)
	end
end

local function UpdateZoom(texture, size)
	local zoom = BLINKIISPORTRAITS.db.profile.misc.zoom
	local offset = (size / 2) * zoom

	texture:SetPoint("TOPLEFT", 0 - offset, 0 + offset)
	texture:SetPoint("BOTTOMRIGHT", 0 + offset, 0 - offset)
end

local unitFrames = nil
function BLINKIISPORTRAITS:GetUnitFrames(unit)
	if not unitFrames then
		if BLINKIISPORTRAITS.ELVUI then
			unitFrames = {}
			unitFrames["player"] = "ElvUF_Player"
			unitFrames["target"] = "ElvUF_Target"
			unitFrames["pet"] = "ElvUF_Pet"
			unitFrames["targettarget"] = "ElvUF_TargetTarget"
			unitFrames["focus"] = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Focus"
			unitFrames["party"] = "ElvUF_PartyGroup1UnitButton"
			unitFrames["boss"] = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Boss"
			unitFrames["arena"] = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Arena"
		elseif BLINKIISPORTRAITS.PB4 then
			local PitBull4 = _G.PitBull4
			local PB4_SingleUnits = PitBull4.db.profile.units
			local PB4_GroupUnits = PitBull4.db.profile.groups

			local validSingleUnits = {
				player = true,
				target = true,
				pet = true,
				targettarget = true,
				focus = BLINKIISPORTRAITS.Classic and nil or true,
			}

			local validGroupUnits = {
				party = true,
				boss = BLINKIISPORTRAITS.Classic and nil or true,
				arena = BLINKIISPORTRAITS.Classic and nil or true,
			}

			unitFrames = {}

			for singleName, value in pairs(PB4_SingleUnits) do
				if value and validSingleUnits[value.unit] then unitFrames[value.unit] = "PitBull4_Frames_" .. singleName end
			end

			for groupName, value in pairs(PB4_GroupUnits) do
				if value and validGroupUnits[value.unit_group] then unitFrames[value.unit_group] = format("PitBull4_Groups_%sUnitButton", groupName) end
			end
		elseif BLINKIISPORTRAITS.SUF then
			unitFrames = {}
			unitFrames["player"] = "SUFUnitplayer"
			unitFrames["target"] = "SUFUnittarget"
			unitFrames["pet"] = "SUFUnitpet"
			unitFrames["targettarget"] = "SUFUnittargettarget"
			unitFrames["focus"] = BLINKIISPORTRAITS.Classic and nil or "SUFUnitfocus"
			unitFrames["party"] = "SUFHeaderpartyUnitButton"
			unitFrames["boss"] = BLINKIISPORTRAITS.Classic and nil or "SUFHeaderboss"
			unitFrames["arena"] = BLINKIISPORTRAITS.Classic and nil or "SUFHeaderArena"
		end
	end

	return unitFrames and unitFrames[unit]
end

function BLINKIISPORTRAITS:Mirror(texture, mirror)
	texture:SetTexCoord(mirror and 1 or 0, mirror and 0 or 1, 0, 1)
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

local playerFaction

function BLINKIISPORTRAITS:GetUnitColor(unit)
	if not unit then return end
	local colors = BLINKIISPORTRAITS.db.profile.colors

	if UnitIsDead(unit) then return colors.misc.death, nil, true end
	if BLINKIISPORTRAITS.db.profile.misc.force_default then return colors.misc.default end

	if UnitIsPlayer(unit) or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit)) then
		if BLINKIISPORTRAITS.db.profile.misc.force_reaction then
			local unitFaction = select(1, UnitFactionGroup(unit))
			playerFaction = playerFaction or select(1, UnitFactionGroup("player"))

			local reactionType = (playerFaction == unitFaction) and "friendly" or "enemy"
			return colors.reaction[reactionType], true
		else
			local _, class = UnitClass(unit)
			return colors.class[class], true
		end
	else
		local reaction = UnitReaction(unit, "player")
		local reactionType = reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly") or "enemy"
		return colors.reaction[reactionType], false
	end
end

function BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
	if isDead then
		portrait.portrait:SetDesaturated(true)
		portrait.isDesaturated = true
	elseif portrait.isDesaturated then
		portrait.portrait:SetDesaturated(false)
		portrait.isDesaturated = false
	end
end

function BLINKIISPORTRAITS:UpdateExtraTexture(portrait, color, player)
	if not portrait.extra then return end

	local c = player and "player" or (portrait.type == "boss" and "boss" or UnitClassification(portrait.unit))

	if not color then
		if BLINKIISPORTRAITS.db.profile.misc.force_reaction then
			local colorReaction = BLINKIISPORTRAITS.db.profile.colors.reaction
			local reaction = UnitReaction(portrait.unit, "player")
			local reactionType = reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly") or "enemy"
			color = colorReaction[reactionType]
		else
			local colorClassification = BLINKIISPORTRAITS.db.profile.colors.classification

			if player then
				color = colorClassification.player
			elseif portrait.db.extra then
				color = colorClassification[c]
			end
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

function BLINKIISPORTRAITS:RemovePortrait(frame)
	if frame and frame.events then
		for _, event in pairs(frame.events) do
			frame:UnregisterEvent(event)
		end
	end

	frame:Hide()
	frame = nil
end

function BLINKIISPORTRAITS:UpdateSettings(portrait, settings)
	portrait.size = settings.size
	portrait.point = settings.point
end

function BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, settings)
	local dbMisc = BLINKIISPORTRAITS.db.profile.misc
	local dbCustom = BLINKIISPORTRAITS.db.profile.custom
	local media = mediaPortraits[settings.texture]

	portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\media\\blank.tga"

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

function BLINKIISPORTRAITS:UpdateSize(portrait, size, point)
	if not InCombatLockdown() then
		size = size or portrait.size
		point = point or portrait.point
		portrait:SetSize(size, size)
		portrait:ClearAllPoints()
		portrait:SetPoint(point.point, portrait.parentFrame, point.relativePoint, point.x, point.y)

		if portrait.db.strata ~= "AUTO" then portrait:SetFrameStrata(portrait.db.strata) end
		portrait:SetFrameLevel(portrait.db.level)
	end
end

function BLINKIISPORTRAITS:CreatePortrait(name, parent)
	if parent then
		local portrait = CreateFrame("Button", "BP_Portrait_" .. name, parent, "SecureUnitButtonTemplate")

		-- texture
		portrait.texture = portrait:CreateTexture("BP_texture-" .. name, "ARTWORK", nil, 4)
		portrait.texture:SetAllPoints(portrait)

		-- mask
		portrait.mask = portrait:CreateMaskTexture()
		portrait.mask:SetAllPoints(portrait)

		-- portrait
		portrait.portrait = portrait:CreateTexture("BP_portrait-" .. name, "ARTWORK", nil, 2)
		portrait.portrait:SetAllPoints(portrait)
		portrait.portrait:AddMaskTexture(portrait.mask)
		local unit = (parent.unit == "party" or not parent.unit) and "player" or parent.unit

		SetPortraitTexture(portrait.portrait, unit, true)

		-- rare/elite/boss
		local extraOnTop = BLINKIISPORTRAITS.db.profile.misc.extratop
		portrait.extra = portrait:CreateTexture("BP_extra-" .. name, "OVERLAY", nil, extraOnTop and 7 or 1)
		portrait.extra:SetAllPoints(portrait)

		-- extra mask
		if not extraOnTop then
			portrait.extraMask = portrait:CreateMaskTexture()
			portrait.extraMask:SetAllPoints(portrait)
			portrait.extra:AddMaskTexture(portrait.extraMask)
		end

		-- bg
		portrait.bg = portrait:CreateTexture("BP_bg-" .. name, "BACKGROUND", nil, 1)
		portrait.bg:SetAllPoints(portrait)
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

			portrait:SetScript("OnEvent", portrait.func)
			portrait.eventsSet = true
		end
		portrait:func(portrait)

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

function BLINKIISPORTRAITS:UpdateCastIcon(portrait, event, addCastIcon)
	if not addCastIcon then return false end

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
