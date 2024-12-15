local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassification = UnitClassification
local ipairs = ipairs

function BLINKIISPORTRAITS:RegisterEvents(frame, events)
	for _, event in ipairs(events) do
		frame:RegisterEvent(event)
	end
end

function BLINKIISPORTRAITS:GetUnitColor(unit)
	local colorClass = BLINKIISPORTRAITS.db.colors.class
	local colorReaction = BLINKIISPORTRAITS.db.colors.reaction
	local colorMisc = BLINKIISPORTRAITS.db.colors.misc

	if UnitIsPlayer(unit) or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit)) then
		local _, class = UnitClass(unit)
		return colorClass[class]
	else
		local reaction = UnitReaction(unit, "player")
		local reactionType = reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly") or "enemy"
		return colorReaction[reactionType]
	end
end

function BLINKIISPORTRAITS:UpdateTextures(frame)
	frame.texture:SetTexture(frame.textureFile, "CLAMP", "CLAMP", "TRILINEAR")
	frame.mask:SetTexture(frame.maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	frame.extraMask:SetTexture(frame.extraMaskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	frame.bg:SetTexture(frame.bgFile, "CLAMP", "CLAMP", "TRILINEAR")
end

function BLINKIISPORTRAITS:UpdateExtraTexture(frame)
	if not frame.extra then return end

	-- test
	-- local rareIDS = {
	-- 	["42859"] = true,
	-- }

	-- local eliteIDS = {
	-- 	["3127"] = true,
	-- }

	-- local rareeliteIDS = {
	-- 	["3116"] = true,
	-- }

	--local guid = UnitGUID(frame.unit)
	--local npcID = guid and select(6, strsplit("-", guid))

	local colorClassification = BLINKIISPORTRAITS.db.colors.classification
	local unit = frame.unit

	-- (rareIDS[npcID] and "rare") or (eliteIDS[npcID] and "elite") or (rareeliteIDS[npcID] and "rareelite") or
	local c = UnitClassification(unit) -- "worldboss", "rareelite", "elite", "rare", "normal", "trivial", or "minus"
	local color = colorClassification[c]

	if color then
		print(frame[c .. "File"])
		frame.extra:SetTexture(frame[c .. "File"], "CLAMP", "CLAMP", "TRILINEAR")
		frame.extra:SetVertexColor(color.a.r, color.a.g, color.a.b, color.a.a or 1)
		frame.extra:Show()
	else
		frame.extra:Hide()
	end
end

function BLINKIISPORTRAITS:RemovePortrait(frame, events)
	if frame and events then
		for _, event in pairs(events) do
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

function BLINKIISPORTRAITS:UpdateSettings(frame, parent, frameType, settings)
	-- local settings = BLINKIISPORTRAITS.db[frameType or unitType]
	frame.Settings = settings
	frame.parentFrame = parent
	frame.unit = parent.unit
	frame.type = frameType or frame.type
	frame.size = settings.size
	frame.point = settings.point
	frame.textureFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
	frame.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\blank.tga"
	frame.maskFile = "Interface\\Addons\\Blinkiis_Portraits\\mask.tga"
	frame.extraMaskFile = "Interface\\Addons\\Blinkiis_Portraits\\extramask.tga"
	frame.rareFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
	frame.eliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
	frame.rareeliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
	frame.bossFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
end

function BLINKIISPORTRAITS:CreatePortrait(unitType, parent, settings, frameType)
	local BPP = BLINKIISPORTRAITS.Portraits

	BLINKIISPORTRAITS:Print("|cff96e1ffCREATE|r", parent, unitType)

	if parent then
		local portrait = BPP[unitType] or CreateFrame("Button", "BP_Portrait_" .. unitType, parent, "SecureUnitButtonTemplate")

		BLINKIISPORTRAITS:UpdateSettings(portrait, parent, frameType or unitType, settings)

		if not portrait.isBuild then
			-- texture
			portrait.texture = portrait:CreateTexture("BP_texture-" .. unitType, "OVERLAY", nil, 4)
			portrait.texture:SetAllPoints(portrait)

			-- mask
			portrait.mask = portrait:CreateMaskTexture()
			portrait.mask:SetAllPoints(portrait)

			-- portrait
			portrait.portrait = portrait:CreateTexture("BP_portrait-" .. unitType, "OVERLAY", nil, 2)
			portrait.portrait:SetAllPoints(portrait)
			portrait.portrait:AddMaskTexture(portrait.mask)
			local unit = parent.unit == "party" and "player" or parent.unit
			SetPortraitTexture(portrait.portrait, unit, true)

			-- extra mask
			portrait.extraMask = portrait:CreateMaskTexture()
			portrait.extraMask:SetAllPoints(portrait)

			-- rare/elite/boss
			portrait.extra = portrait:CreateTexture("BP_extra-" .. unitType, "OVERLAY", nil, 1)
			portrait.extra:SetAllPoints(portrait)
			portrait.extra:AddMaskTexture(portrait.extraMask)

			-- bg
			portrait.bg = portrait:CreateTexture("BP_bg-" .. unitType, "OVERLAY", nil, 1)
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
			portrait.isBuild = true
		end

		if not InCombatLockdown() then
			portrait:SetSize(portrait.size, portrait.size)
			portrait:ClearAllPoints()
			portrait:SetPoint(portrait.point.point, portrait.parentFrame, portrait.point.relativePoint, portrait.point.x, portrait.point.y)
		end

		BPP[unitType] = portrait
	end
end

function BLINKIISPORTRAITS:InitializePortraits()
	local unitframes = nil
	local events = {
		player = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"UNIT_ENTERED_VEHICLE",
			"UNIT_EXITING_VEHICLE",
			"UNIT_EXITED_VEHICLE",
		},
		target = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"PLAYER_TARGET_CHANGED",
		},
		focus = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"PLAYER_FOCUS_CHANGED",
			"GROUP_ROSTER_UPDATE",
		},
		targettarget = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"UNIT_TARGET",
			"GROUP_ROSTER_UPDATE",
		},
		pet = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"UNIT_PET",
			"UNIT_EXITED_VEHICLE",
			"PET_UI_UPDATE",
		},
		party = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"UNIT_NAME_UPDATE",
			"UPDATE_ACTIVE_BATTLEFIELD",
			"GROUP_ROSTER_UPDATE",
			"UNIT_ENTERED_VEHICLE",
			"UNIT_EXITED_VEHICLE",
		},
		boss = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		},
		arena = {
			"UNIT_PORTRAIT_UPDATE",
			"PORTRAITS_UPDATED",
			"ARENA_OPPONENT_UPDATE",
			"ARENA_PREP_OPPONENT_SPECIALIZATIONS",
			"PVP_MATCH_STATE_CHANGED",
		},
	}

	if IsAddOnLoaded("ShadowedUnitFrames") then
		unitframes = {
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
		unitframes = {
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

	if unitframes then
		BLINKIISPORTRAITS:InitPlayerPortrait(_G[unitframes.player])
		BLINKIISPORTRAITS:InitTargetPortrait(_G[unitframes.target])
		-- CreatePortrait("player", _G[unitframes.player], events.player)
		-- CreatePortrait("target", _G[unitframes.target], events.target)
		-- CreatePortrait("focus", _G[unitframes.focus], events.focus)
		-- CreatePortrait("targettarget", _G[unitframes.targettarget], events.targettarget)
		-- CreatePortrait("pet", _G[unitframes.pet], events.pet)

		-- for i = 1, 5 do
		-- 	CreatePortrait("party" .. i, _G[unitframes.party .. i], events.party, "party")
		-- end

		-- for i = 1, 8 do
		-- 	CreatePortrait("boss" .. i, _G[unitframes.boss .. i], events.boss, "boss")
		-- end

		-- for i = 1, 5 do
		-- 	CreatePortrait("arena" .. i, _G[unitframes.arena .. i], events.arena, "arena")
		-- end
	end
end
