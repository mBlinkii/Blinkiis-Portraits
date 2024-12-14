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
	colors = {
		border = {
			default = { r = 0, g = 0, b = 0, a = 1 },
			rare = { r = 1, g = 1, b = 1, a = 1 },
			elite = { r = 1, g = 1, b = 1, a = 1 },
			rareelite = { r = 1, g = 1, b = 1, a = 1 },
			boss = { r = 1, g = 0, b = 0, a = 1 },
		},
		misc = {
			death = {
				a = { r = 0.89, g = 0.61, b = 0.29, a = 1 },
				b = { r = 0.89, g = 0.42, b = 0.16, a = 1 },
			},
			default = {
				a = { r = 0.89, g = 0.61, b = 0.29, a = 1 },
				b = { r = 0.89, g = 0.42, b = 0.16, a = 1 },
			},
		},
		class = {
			DEATHKNIGHT = {
				a = { r = 0.81, g = 0.17, b = 0.17, a = 1 },
				b = { r = 0.96, g = 0.14, b = 0.31, a = 1 },
			},
			DEMONHUNTER = {
				a = { r = 0.70, g = 0, b = 0.54, a = 1 },
				b = { r = 0.72, g = 0, b = 0.96, a = 1 },
			},
			DRUID = {
				a = { r = 1.00, g = 0.36, b = 0.04, a = 1 },
				b = { r = 1, g = 0.50, b = 0.03, a = 1 },
			},
			EVOKER = {
				a = { r = 0.20, g = 0.58, b = 0.50, a = 1 },
				b = { r = 0.2, g = 1, b = 0.97, a = 1 },
			},
			HUNTER = {
				a = { r = 0.6, g = 0.8, b = 0.32, a = 1 },
				b = { r = 0.67, g = 0.92, b = 0.3, a = 1 },
			},
			MAGE = {
				a = { r = 0, g = 0.60, b = 0.81, a = 1 },
				b = { r = 0.2, g = 0.78, b = 0.98, a = 1 },
			},
			MONK = {
				a = { r = 0, g = 0.78, b = 0.53, a = 1 },
				b = { r = 0, g = 1, b = 0.52, a = 1 },
			},
			PALADIN = {
				a = { r = 1, g = 0.25, b = 0.65, a = 1 },
				b = { r = 0.96, g = 0.52, b = 0.84, a = 1 },
			},
			PRIEST = {
				a = { r = 0.74, g = 0.74, b = 0.74, a = 1 },
				b = { r = 1, g = 1, b = 1, a = 1 },
			},
			ROGUE = {
				a = { r = 1, g = 0.74, b = 0.23, a = 1 },
				b = { r = 1, g = 0.92, b = 0.25, a = 1 },
			},
			SHAMAN = {
				a = { r = 0.00, g = 0.38, b = 0.92, a = 1 },
				b = { r = 0.03, g = 0.5, b = 0.92, a = 1 },
			},
			WARLOCK = {
				a = { r = 0.38, g = 0.28, b = 0.67, a = 1 },
				b = { r = 0.52, g = 0.38, b = 0.92, a = 1 },
			},
			WARRIOR = {
				a = { r = 0.78, g = 0.54, b = 0.28, a = 1 },
				b = { r = 0.87, g = 0.63, b = 0.38, a = 1 },
			},
		},
		classification = {
			rare = {
				a = { r = 0, g = 0.46, b = 1, a = 1 },
				b = { r = 0, g = 0.27, b = 0.59, a = 1 },
			},
			rareelite = {
				a = { r = 0.63, g = 0, b = 1, a = 1 },
				b = { r = 0.44, g = 0, b = 0.70, a = 1 },
			},
			elite = {
				a = { r = 1, g = 0, b = 0.90, a = 1 },
				b = { r = 0.62, g = 0, b = 0.36, a = 1 },
			},
			boss = {
				a = { r = 0.78, g = 0.12, b = 0.12, a = 1 },
				b = { r = 0.85, g = 0.25, b = 0.25, a = 1 },
			},
		},
		reaction = {
			enemy = {
				a = { r = 0.78, g = 0.12, b = 0.12, a = 1 },
				b = { r = 0.85, g = 0.25, b = 0.25, a = 1 },
			},
			neutral = {
				a = { r = 1.00, g = 0.70, b = 0, a = 1 },
				b = { r = 0.77, g = 0.45, b = 0, a = 1 },
			},
			friendly = {
				a = { r = 0.17, g = 0.75, b = 0, a = 1 },
				b = { r = 0, g = 1, b = 0.22, a = 1 },
			},
		},
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
BLINKIISPORTRAITS.Name = "|CFF00A3FFB|r|CFF00B4FFl|r|CFF00C6FFi|r|CFF00D8FFn|r|CFF00EAFFk|r|CFF00F6FFi|r|CFF00F6FFi|r Portraits"
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

function BLINKIISPORTRAITS:Initialize()
	BLINKIISPORTRAITS:InitializePortraits()
end
