local _G = _G
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local ReloadUI = ReloadUI
local strlower = strlower

-- addon name and namespace
local addonName, _ = ...

-- defaults
local defaults = {
	test = true,
	test_tbl = { a = "aaaa", b = "bbb" },
	player = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "RIGHT", relativePoint = "LEFT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	target = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "LEFT", relativePoint = "RIGHT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	focus = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "LEFT", relativePoint = "RIGHT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	targettarget = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "LEFT", relativePoint = "RIGHT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	pet = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "RIGHT", relativePoint = "LEFT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	party = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "RIGHT", relativePoint = "LEFT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	boss = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "LEFT", relativePoint = "RIGHT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
	arena = {
		cast = false,
		enable = true,
		flip = false,
		level = 20,
		mirror = false,
		point = { point = "LEFT", relativePoint = "RIGHT", x = 0, y = 0 },
		size = 90,
		strata = "AUTO",
		texture = "drop",
	},
}

-- main function/ db loader
local function OnEvent(self, event, addOnName)
	if event == "ADDON_LOADED" and addOnName == "Blinkiis_Portraits" then
		BlinkiisPortraitsDB = BlinkiisPortraitsDB or {}
		self.db = BlinkiisPortraitsDB
		for k, v in pairs(defaults) do
			if self.db[k] == nil then self.db[k] = v end
		end

		self:InitializeOptions()
	elseif event == "PLAYER_LOGOUT" then
		BlinkiisPortraitsDB = BLINKIISPORTRAITS.db
	else
		BLINKIISPORTRAITS:Initialize()
	end
end

-- main frame module
BLINKIISPORTRAITS = CreateFrame("Frame")

BLINKIISPORTRAITS:RegisterEvent("ADDON_LOADED")
BLINKIISPORTRAITS:RegisterEvent("PLAYER_LOGOUT")
BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")
BLINKIISPORTRAITS:SetScript("OnEvent", OnEvent)

-- settings
BLINKIISPORTRAITS.Version = GetAddOnMetadata(addonName, "Version")
BLINKIISPORTRAITS.Name = "Blinkiis Portraits"
BLINKIISPORTRAITS.Icon = "|TInterface\\Addons\\ElvUI_mMediaTag\\media\\logo\\mmt_icon_round.tga:14:14|t"
BLINKIISPORTRAITS.Media = {}
BLINKIISPORTRAITS.Config = {}
BLINKIISPORTRAITS.Portraits = {}

-- slash commands
SLASH_BLINKII1 = "/bp"

SlashCmdList.BLINKII = function(msg, editBox)
	msg = strlower(msg)

	if msg == "debug" then
		BLINKIISPORTRAITS:DebugPrintTable(BLINKIISPORTRAITS.db)
	elseif msg == "test" then
		BLINKIISPORTRAITS:TEST()
	else
		BLINKIISPORTRAITS:ToggleOptions()
	end
end

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end

-- debug/ default functions
function GetTableLng(tbl)
	local getN = 0
	for n in pairs(tbl) do
		getN = getN + 1
	end
	return getN
end

local function PrintTable(tbl, indent, simple, noFunctions)
	--if not indent then indent = "   " end
	if type(tbl) == "table" then
		for entry, value in pairs(tbl) do
			if (type(value) == "table") and not simple then
				print(indent and indent .. "   " or "", "|cff60ffc3 [" .. entry .. "]|r", value)
				PrintTable(value, indent and indent .. "   " or "   ", true, noFunctions)
			else
				if type(value) == "table" then
					print(indent and indent .. "   " or "", "|cff60ffc3 [" .. entry .. "]|r", " > ", value)
				elseif type(value) == "number" then
					print(indent and indent .. "   " or "", "|cfff5b062 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "string" then
					print(indent and indent .. "   " or "", "|cffd56ef5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "boolean" then
					print(indent and indent .. "   " or "", "|cff96e1ff[" .. entry .. "]|r", " = ", (value and "|cffabff87true|r" or "|cffff8787false|r"))
				elseif (type(value) == "function") and not noFunctions then
					print(indent and indent .. "   " or "", "|cffb5b3f5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) ~= "function" then
					print(indent and indent .. "   " or "", "|cfffbd7f9 [" .. entry .. "]|r", " = ", value)
				end
			end
		end
	else
		print(tostring(tbl))
	end
end

function BLINKIISPORTRAITS:DebugPrintTable(tbl, simple, noFunctions)
	if type(tbl) == "table" then
		local tblLength = GetTableLng(tbl)
		BLINKIISPORTRAITS:Print(": Table Start >>>", tbl, "Entries:", tblLength, "Options:", "Simple:", simple, "Functions:", noFunctions)
		PrintTable(tbl, nil, (tblLength > 50), noFunctions)
	else
		BLINKIISPORTRAITS:Print("Not a Table:", tbl)
	end
end

function BLINKIISPORTRAITS:Print(...)
	print(BLINKIISPORTRAITS.Name .. ":", ...)
end

function BLINKIISPORTRAITS:TEST(...)
	-- local unitframes = { "PlayerFrame" }
	-- --_G.PlayerFrame.portrait:Hide()
	-- -- .unit

	-- local frameTexture = _G.PlayerFrame.PlayerFrameContainer.FrameTexture
	-- frameTexture:SetTexture("Interface\\Addons\\Blinkiis_Portraits\\frame.tga")
	-- -- frameTexture:Hide()

	-- -- _G.PlayerFrame.PlayerFrameContainer = textures
	-- -- AlternatePowerFrameTexture
	-- -- FrameFlash
	-- -- FrameTexture
	-- -- PlayerPortrait
	-- -- VehicleFrameTexture
	-- -- PlayerPortraitMask
	-- BLINKIISPORTRAITS:DebugPrintTable(_G.PlayerFrame, nil, true)

	BLINKIISPORTRAITS:Initialize()
end

local unitframesDB = {
	elvui = {
		player = "ElvUF_Player",
		target = "ElvUF_Target",
		pet = "ElvUF_Pet",
		targettarget = "ElvUF_TargetTarget",
		focus = "ElvUF_Focus",
		party = "ElvUF_PartyGroup1UnitButton",
		boss = "ElvUF_Boss",
		arena = "ElvUF_Arena",
	},
	suf = {
		player = "SUFUnitplayer",
		target = "SUFUnittarget",
		pet = "SUFUnitpet",
		targettarget = "SUFUnittargettarget",
		focus = "SUFUnitocus",
		party = "SUFHeaderpartyUnitButton",
		boss = "SUFHeaderboss",
		arena = "SUFHeaderArena",
	},
	6,
}

local function UpdatePortrait(frame, event, eventUnit)
	BLINKIISPORTRAITS:Print("|cfff5b062OTHER|r", frame.unit, frame.type, frame, event, eventUnit)

	if
		event == "UNIT_PORTRAIT_UPDATE"
		or event == "PORTRAITS_UPDATED"
		or (frame.type == "target" and event == "PLAYER_TARGET_CHANGED")
		or (frame.type == "focus" and event == "PLAYER_FOCUS_CHANGED")
		or ((frame.type == "focus" or frame.type == "targettarget") and event == "GROUP_ROSTER_UPDATE")
		or (frame.type == "targettarget" and event == "UNIT_TARGET")
	then
		SetPortraitTexture(frame.portrait, frame.unit, true)

		if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
	end
end

local function UpdatePetPortrait(frame, event, eventUnit)
	local unit = frame.unit

	if event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then
		unit = UnitInVehicle("player") and UnitHasVehiclePlayerFrameUI("player") and "player" or "pet"
	end

	frame.unit = unit

	--if event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then
	BLINKIISPORTRAITS:Print("|cffd56ef5PET|r", frame.unit, frame.type, frame, event, eventUnit)
	SetPortraitTexture(frame.portrait, frame.unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
	--end
end

local function UpdatePartyPortrait(frame, event, eventUnit)
	--if event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then
	local unit = frame.unit == "party" and "player" or frame.unit
	BLINKIISPORTRAITS:Print("|cff60ffc3PARTY EVENT|r", frame.unit, frame.type, frame, event, eventUnit)
	SetPortraitTexture(frame.portrait, unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= unit then frame:SetAttribute("unit", unit) end
	--end
end

local function UpdateBossPortrait(frame, event, eventUnit)
	local unit = frame.unit == "boss" and "player" or frame.unit
	BLINKIISPORTRAITS:Print("|cffb5b3f5BOSS EVENT|r", frame.unit, frame.type, frame, event, eventUnit)
	SetPortraitTexture(frame.portrait, unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= unit then frame:SetAttribute("unit", unit) end
end

local function UpdateArenaPortrait(frame, event, eventUnit)
	local unit = frame.unit == "arena" and "player" or frame.unit
	BLINKIISPORTRAITS:Print("|cffffb3f5Arena EVENT|r", frame.unit, frame.type, frame, event, eventUnit)
	SetPortraitTexture(frame.portrait, unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= unit then frame:SetAttribute("unit", unit) end
end

-- portraits
local function CreatePortrait(unitType, parent, events, frameType)
	local BPP = BLINKIISPORTRAITS.Portraits

	BLINKIISPORTRAITS:Print("|cff96e1ffCREATE|r", parent, unitType)

	if not BPP[unitType] and parent then
		local portrait = CreateFrame("Button", "BP_Portrait_" .. unitType, parent, "SecureUnitButtonTemplate")

		local settings = BLINKIISPORTRAITS.db[frameType or unitType]
		portrait.Settings = settings
		portrait.parentFrame = parent
		portrait.unit = parent.unit
		portrait.type = frameType or unitType
		portrait.size = settings.size
		portrait.point = settings.point
		portrait.textureFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
		portrait.bgFile = "Interface\\Addons\\Blinkiis_Portraits\\blank.tga"
		portrait.maskFile = "Interface\\Addons\\Blinkiis_Portraits\\mask.tga"
		portrait.rareFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
		portrait.eliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
		portrait.rareeliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"
		portrait.bossFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga"

		for _, event in ipairs(events) do
			portrait:RegisterEvent(event)
		end

		if portrait.type == "pet" then
			portrait:SetScript("OnEvent", UpdatePetPortrait)
		elseif portrait.type == "party" then
			portrait:SetScript("OnEvent", UpdatePartyPortrait)
		elseif portrait.type == "boss" then
			portrait:SetScript("OnEvent", UpdateBossPortrait)
		elseif portrait.type == "arena" then
			portrait:SetScript("OnEvent", UpdateArenaPortrait)
		else
			portrait:SetScript("OnEvent", UpdatePortrait)
		end

		if not InCombatLockdown() then
			portrait:SetSize(portrait.size, portrait.size)
			portrait:ClearAllPoints()
			portrait:SetPoint(portrait.point.point, portrait.parentFrame, portrait.point.relativePoint, portrait.point.x, portrait.point.y)
		end

		-- texture
		portrait.texture = portrait:CreateTexture("BP_texture-" .. unitType, "OVERLAY", nil, 4)
		portrait.texture:SetAllPoints(portrait)
		portrait.texture:SetTexture(portrait.textureFile, "CLAMP", "CLAMP", "TRILINEAR")

		-- mask
		portrait.mask = portrait:CreateMaskTexture()
		portrait.mask:SetAllPoints(portrait)
		portrait.mask:SetTexture(portrait.maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

		-- portrait
		portrait.portrait = portrait:CreateTexture("BP_portrait-" .. unitType, "OVERLAY", nil, 2)
		portrait.portrait:SetAllPoints(portrait)
		portrait.portrait:AddMaskTexture(portrait.mask)
		local unit = parent.unit == "party" and "player" or parent.unit
		SetPortraitTexture(portrait.portrait, unit, true)

		-- bg
		portrait.bg = portrait:CreateTexture("BP_bg-" .. unitType, "OVERLAY", nil, 1)
		portrait.bg:SetAllPoints(portrait)
		portrait.bg:AddMaskTexture(portrait.mask)
		portrait.bg:SetTexture(portrait.bgFile, "CLAMP", "CLAMP", "TRILINEAR")
		portrait.bg:SetVertexColor(0, 0, 0, 1)

		-- scripts to interact with mouse
		portrait:SetAttribute("unit", portrait.unit)
		portrait:SetAttribute("*type1", "target")
		portrait:SetAttribute("*type2", "togglemenu")
		portrait:SetAttribute("type3", "focus")
		portrait:SetAttribute("toggleForVehicle", true)
		portrait:SetAttribute("ping-receiver", true)
		portrait:RegisterForClicks("AnyUp")

		BPP[unitType] = portrait
	end
end

function BLINKIISPORTRAITS:Initialize()
	local unitframes = nil
	local events = {
		player = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED" },
		target = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED" },
		focus = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_FOCUS_CHANGED", "GROUP_ROSTER_UPDATE" },
		targettarget = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_TARGET", "GROUP_ROSTER_UPDATE" },
		pet = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_PET", "UNIT_EXITED_VEHICLE", "PET_UI_UPDATE" },
		party = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_NAME_UPDATE", "UPDATE_ACTIVE_BATTLEFIELD", "GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE" },
		boss = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" },
		arena = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "ARENA_OPPONENT_UPDATE", "ARENA_PREP_OPPONENT_SPECIALIZATIONS", "PVP_MATCH_STATE_CHANGED" },
	}

	if IsAddOnLoaded("ShadowedUnitFrames") then
		unitframes = unitframesDB.suf
	elseif IsAddOnLoaded("ElvUI") then
		unitframes = unitframesDB.elvui
	end

	if unitframes then
		CreatePortrait("player", _G[unitframes.player], events.player)
		CreatePortrait("target", _G[unitframes.target], events.target)
		CreatePortrait("focus", _G[unitframes.focus], events.focus)
		CreatePortrait("targettarget", _G[unitframes.targettarget], events.targettarget)
		CreatePortrait("pet", _G[unitframes.pet], events.pet)

		for i = 1, 5 do
			CreatePortrait("party" .. i, _G[unitframes.party .. i], events.party, "party")
		end

		for i = 1, 8 do
			CreatePortrait("boss" .. i, _G[unitframes.boss .. i], events.boss, "boss")
		end

		for i = 1, 5 do
			CreatePortrait("arena" .. i, _G[unitframes.arena .. i], events.arena, "arena")
		end
	end
end
