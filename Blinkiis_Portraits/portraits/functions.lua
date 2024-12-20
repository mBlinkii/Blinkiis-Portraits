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
		print(event, portrait.events)
		tinsert(portrait.events, event)
	end
end

local unitFrames = nil
function BLINKIISPORTRAITS:GetUnitFrames(unit)
	if not unitFrames then
		if IsAddOnLoaded("ShadowedUnitFrames") then
			unitFrames = {
				player = "SUFUnitplayer",
				target = "SUFUnittarget",
				pet = "SUFUnitpet",
				targettarget = "SUFUnittargettarget",
				focus = "SUFUnitocus",
				party = "SUFHeaderpartyUnitButton",
				boss = "SUFHeaderboss",
				arena = "SUFHeaderArena",
			}
		elseif IsAddOnLoaded("ElvUI") then
			unitFrames = {
				player = "ElvUF_Player",
				target = "ElvUF_Target",
				pet = "ElvUF_Pet",
				targettarget = "ElvUF_TargetTarget",
				focus = "ElvUF_Focus",
				party = "ElvUF_PartyGroup1UnitButton",
				boss = "ElvUF_Boss",
				arena = "ElvUF_Arena",
			}
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
	SetTexture(portrait.extraMask, portrait.extraMaskFile, "CLAMPTOBLACKADDITIVE")
	SetTexture(portrait.bg, portrait.bgFile, "CLAMP")

	BLINKIISPORTRAITS:Mirror(portrait.texture, mirror)
	BLINKIISPORTRAITS:Mirror(portrait.mask, mirror)
	BLINKIISPORTRAITS:Mirror(portrait.extraMask, mirror)
end

local playerFaction

function BLINKIISPORTRAITS:GetUnitColor(unit)
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

function BLINKIISPORTRAITS:DebugPrint(frame, event, eventUnit, color)
	-- #00F8DFFF #F6FF00FF #00F97CFF
	BLINKIISPORTRAITS:Print(
		color .. (event and "Event - " or "") .. frame.type .. ":|r",
		"|CFF00F8DFUnit|r:",
		frame.unit,
		"|CFFF6FF00EventUnit|r:",
		eventUnit,
		"|CFF00F97COther|r:",
		frame.type,
		event
	)
end

function BLINKIISPORTRAITS:UpdateSettings(portrait, settings)
	portrait.size = settings.size
	portrait.point = settings.point
end

function BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, settings)
	local dbMisc = BLINKIISPORTRAITS.db.profile.misc
	local media = mediaPortraits[settings.texture]

	portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\media\\blank.tga"
	portrait.bossFile = mediaExtra[dbMisc.boss]
	portrait.eliteFile = mediaExtra[dbMisc.elite]
	portrait.extraMaskFile = (settings.mirror and media.extra_mirror) and media.extra_mirror or media.extra
	portrait.maskFile = (settings.mirror and media.mask_mirror) and media.mask_mirror or media.mask
	portrait.playerFile = mediaExtra[dbMisc.player]
	portrait.rareFile = mediaExtra[dbMisc.rare]
	portrait.rareeliteFile = mediaExtra[dbMisc.rareelite]
	portrait.textureFile = media.texture
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
	BLINKIISPORTRAITS:Print("|cff96e1ffCREATE|r", name, parent)

	if parent then
		local portrait = CreateFrame("Button", "BP_Portrait_" .. name, parent, "SecureUnitButtonTemplate")

		-- texture
		portrait.texture = portrait:CreateTexture("BP_texture-" .. name, "OVERLAY", nil, 4)
		portrait.texture:SetAllPoints(portrait)

		-- mask
		portrait.mask = portrait:CreateMaskTexture()
		portrait.mask:SetAllPoints(portrait)

		-- portrait
		portrait.portrait = portrait:CreateTexture("BP_portrait-" .. name, "OVERLAY", nil, 2)
		portrait.portrait:SetAllPoints(portrait)
		portrait.portrait:AddMaskTexture(portrait.mask)
		local unit = parent.unit == "party" and "player" or parent.unit
		SetPortraitTexture(portrait.portrait, unit, true)

		-- extra mask
		portrait.extraMask = portrait:CreateMaskTexture()
		portrait.extraMask:SetAllPoints(portrait)

		-- rare/elite/boss
		portrait.extra = portrait:CreateTexture("BP_extra-" .. name, "OVERLAY", nil, 1)
		portrait.extra:SetAllPoints(portrait)
		portrait.extra:AddMaskTexture(portrait.extraMask)

		-- bg
		portrait.bg = portrait:CreateTexture("BP_bg-" .. name, "OVERLAY", nil, 1)
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
