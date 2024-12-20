local _G = _G
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local ReloadUI = ReloadUI
local strlower = strlower
local CopyTable = CopyTable

-- addon name and namespace
local addonName, _ = ...

BLINKIISPORTRAITS = LibStub("AceAddon-3.0"):NewAddon("BLINKIISPORTRAITS", "AceEvent-3.0", "AceConsole-3.0")

-- settings
BLINKIISPORTRAITS.Version = GetAddOnMetadata(addonName, "Version")
BLINKIISPORTRAITS.Name = "|CFF00A3FFB|r|CFF00B4FFl|r|CFF00C6FFi|r|CFF00D8FFn|r|CFF00EAFFk|r|CFF00F6FFi|r|CFF00F6FFi|r Portraits"
BLINKIISPORTRAITS.Icon = "|TInterface\\Addons\\Blinkiis_Portraits\\media\\icon.tga:14:14|t"
BLINKIISPORTRAITS.Logo = "Interface\\Addons\\Blinkiis_Portraits\\media\\logo.tga"
BLINKIISPORTRAITS.media = {}
BLINKIISPORTRAITS.defaults = {}

-- portraits
BLINKIISPORTRAITS.Portraits = {}

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

function BLINKIISPORTRAITS:LoadDB()
	self.db = LibStub("AceDB-3.0"):New("BlinkiisPortraitsDB")

	for k, v in pairs(BLINKIISPORTRAITS.defaults) do
		if self.db.profile[k] == nil then
			local value = v
			self.db.profile[k] = value
		end
	end
end

function BLINKIISPORTRAITS:LoadPortraits()
	BLINKIISPORTRAITS:InitializePlayerPortrait()
	BLINKIISPORTRAITS:InitializeTargetPortrait()
end

function BLINKIISPORTRAITS:PLAYER_ENTERING_WORLD(event)
	BLINKIISPORTRAITS:LoadPortraits()
end

function BLINKIISPORTRAITS:OnInitialize()
	BLINKIISPORTRAITS:LoadDB()
	BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")
end
