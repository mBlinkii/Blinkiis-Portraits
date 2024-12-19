local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassification = UnitClassification
local ipairs = ipairs

local BPP = BLINKIISPORTRAITS.Portraits

local mediaPortraits = BLINKIISPORTRAITS.media.portraits
local mediaExtra = BLINKIISPORTRAITS.media.extra
function BLINKIISPORTRAITS:RegisterEvents(frame, events)
	for _, event in ipairs(events) do
		frame:RegisterEvent(event)
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

function BLINKIISPORTRAITS:GetUnitColor(unit)
	local colorClass = BLINKIISPORTRAITS.db.profile.colors.class
	local colorReaction = BLINKIISPORTRAITS.db.profile.colors.reaction
	local colorMisc = BLINKIISPORTRAITS.db.profile.colors.misc

	if UnitIsPlayer(unit) or (BLINKIISPORTRAITS.Retail and UnitInPartyIsAI(unit)) then
		local _, class = UnitClass(unit)
		return colorClass[class]
	else
		local reaction = UnitReaction(unit, "player")
		local reactionType = reaction and ((reaction <= 3) and "enemy" or (reaction == 4) and "neutral" or "friendly") or "enemy"
		return colorReaction[reactionType]
	end
end

function BLINKIISPORTRAITS:UpdateTextures(portrait)
	portrait.texture:SetTexture(portrait.textureFile, "CLAMP", "CLAMP", "TRILINEAR")
	portrait.mask:SetTexture(portrait.maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	portrait.extraMask:SetTexture(portrait.extraMaskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	portrait.bg:SetTexture(portrait.bgFile, "CLAMP", "CLAMP", "TRILINEAR")
end

function BLINKIISPORTRAITS:UpdateExtraTexture(portrait, forced)
	if not portrait.extra then return end

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
	local color, c
	local colorClassification = BLINKIISPORTRAITS.db.profile.colors.classification

	if forced then
		color = colorClassification.player
		c = "player"
	elseif portrait.db.extra then
		local unit = portrait.unit

		-- (rareIDS[npcID] and "rare") or (eliteIDS[npcID] and "elite") or (rareeliteIDS[npcID] and "rareelite") or
		c = UnitClassification(unit) -- "worldboss", "rareelite", "elite", "rare", "normal", "trivial", or "minus"
		color = colorClassification[c]
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
	portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\media\\blank.tga"
	portrait.bossFile = mediaExtra[BLINKIISPORTRAITS.db.profile.misc.boss]
	portrait.eliteFile = mediaExtra[BLINKIISPORTRAITS.db.profile.misc.elite]
	portrait.extraMaskFile = mediaPortraits[settings.texture].extra
	portrait.maskFile = mediaPortraits[settings.texture].mask
	portrait.playerFile = mediaExtra[BLINKIISPORTRAITS.db.profile.misc.player]
	portrait.rareFile = mediaExtra[BLINKIISPORTRAITS.db.profile.misc.rare]
	portrait.rareeliteFile = mediaExtra[BLINKIISPORTRAITS.db.profile.misc.rareelite]
	portrait.textureFile = mediaPortraits[settings.texture].texture
end

function BLINKIISPORTRAITS:UpdateSize(portrait, size, point)
	if not InCombatLockdown() then
		size = size or portrait.size
		point = point or portrait.point
		portrait:SetSize(size, size)
		portrait:ClearAllPoints()
		portrait:SetPoint(point.point, portrait.parentFrame, point.relativePoint, point.x, point.y)
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
		BLINKIISPORTRAITS:RegisterEvents(portrait, events)

		portrait:SetScript("OnEvent", portrait.func)
		portrait.events = events

		portrait:func(portrait)
	end
end

function BLINKIISPORTRAITS:oldInitializePortraits()
	--BLINKIISPORTRAITS.unitframes = nil
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
		BLINKIISPORTRAITS.unitframes = {
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
		BLINKIISPORTRAITS.unitframes = {
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

	-- if unitframes then
	-- 	if BLINKIISPORTRAITS.db.player.enable then
	-- 		BLINKIISPORTRAITS:InitPlayerPortrait(_G[unitframes.player])
	-- 	elseif BLINKIISPORTRAITS.Portraits.player then
	-- 		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.player)
	-- 		BLINKIISPORTRAITS.Portraits.player = nil
	-- 	end

	-- 	if BLINKIISPORTRAITS.db.target.enable then
	-- 		BLINKIISPORTRAITS:InitTargetPortrait(_G[unitframes.target])
	-- 	elseif BLINKIISPORTRAITS.Portraits.target then
	-- 		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.target)
	-- 		BLINKIISPORTRAITS.Portraits.target = nil
	-- 	end
	-- 	-- CreatePortrait("player", _G[unitframes.player], events.player)
	-- 	-- CreatePortrait("target", _G[unitframes.target], events.target)
	-- 	-- CreatePortrait("focus", _G[unitframes.focus], events.focus)
	-- 	-- CreatePortrait("targettarget", _G[unitframes.targettarget], events.targettarget)
	-- 	-- CreatePortrait("pet", _G[unitframes.pet], events.pet)

	-- 	-- for i = 1, 5 do
	-- 	-- 	CreatePortrait("party" .. i, _G[unitframes.party .. i], events.party, "party")
	-- 	-- end

	-- 	-- for i = 1, 8 do
	-- 	-- 	CreatePortrait("boss" .. i, _G[unitframes.boss .. i], events.boss, "boss")
	-- 	-- end

	-- 	-- for i = 1, 5 do
	-- 	-- 	CreatePortrait("arena" .. i, _G[unitframes.arena .. i], events.arena, "arena")
	-- 	-- end
	-- end
end
