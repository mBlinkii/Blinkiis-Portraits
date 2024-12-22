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
BLINKIISPORTRAITS.SUF = nil
BLINKIISPORTRAITS.ELVUI = nil

do
	BLINKIISPORTRAITS.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
	BLINKIISPORTRAITS.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
	BLINKIISPORTRAITS.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	BLINKIISPORTRAITS.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

-- portraits
BLINKIISPORTRAITS.Portraits = {}

-- default functions
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
	BLINKIISPORTRAITS:InitializeArenaPortrait()
	BLINKIISPORTRAITS:InitializeBossPortrait()
	BLINKIISPORTRAITS:InitializeFocusPortrait()
	BLINKIISPORTRAITS:InitializePartyPortrait()
	BLINKIISPORTRAITS:InitializePetPortrait()
	BLINKIISPORTRAITS:InitializePlayerPortrait()
	BLINKIISPORTRAITS:InitializeTargetPortrait()
	BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
end

function BLINKIISPORTRAITS:PLAYER_ENTERING_WORLD(event)
	BLINKIISPORTRAITS:LoadPortraits()
end

function BLINKIISPORTRAITS:OnInitialize()
	BLINKIISPORTRAITS:LoadDB()
	BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")

	if IsAddOnLoaded("ElvUI") then
		local E, _, _, _, _ = unpack(ElvUI)
		local EP = E.Libs.EP
		EP:RegisterPlugin(addonName, BLINKIISPORTRAITS.LoadOptions)
	end
end
