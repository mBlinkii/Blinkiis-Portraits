local _G = _G
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded

-- addon name and namespace
local addonName, _ = ...
local C_Timer_After = C_Timer.After

BLINKIISPORTRAITS = LibStub("AceAddon-3.0"):NewAddon("BLINKIISPORTRAITS", "AceEvent-3.0", "AceConsole-3.0")

-- settings
BLINKIISPORTRAITS.Version = GetAddOnMetadata(addonName, "Version")
BLINKIISPORTRAITS.Name = "|CFF00A3FFB|r|CFF00B4FFl|r|CFF00C6FFi|r|CFF00D8FFn|r|CFF00EAFFk|r|CFF00F6FFi|r|CFF00F6FFi|r Portraits"
BLINKIISPORTRAITS.Icon = "|TInterface\\Addons\\Blinkiis_Portraits\\media\\icon.tga:14:14|t"
BLINKIISPORTRAITS.Logo = "Interface\\Addons\\Blinkiis_Portraits\\media\\logo.tga"
BLINKIISPORTRAITS.media = {}
BLINKIISPORTRAITS.defaults = {}
BLINKIISPORTRAITS.dialogs = {}
BLINKIISPORTRAITS.SUF = nil
BLINKIISPORTRAITS.ELVUI = nil
BLINKIISPORTRAITS.PB4 = nil
BLINKIISPORTRAITS.Cell = nil
BLINKIISPORTRAITS.CachedBossIDs = {}

do
	BLINKIISPORTRAITS.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
	BLINKIISPORTRAITS.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
	BLINKIISPORTRAITS.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	BLINKIISPORTRAITS.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

-- portraits
BLINKIISPORTRAITS.Portraits = {}

-- addonCompartment functions
function BLINKIISPORTRAITS_OnAddonCompartmentClick()
	LibStub("AceConfigDialog-3.0"):Open("BLINKIISPORTRAITS")
end

function BLINKIISPORTRAITS_OnAddonCompartmentOnEnter()
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR_RIGHT")
	GameTooltip:AddDoubleLine(BLINKIISPORTRAITS.Name, format("|CFFF7DC6FVer. %s|r", BLINKIISPORTRAITS.Version))
	GameTooltip:Show()
end

function BLINKIISPORTRAITS_OnAddonCompartmentOnLeave()
	GameTooltip:Hide()
end

-- default functions
function BLINKIISPORTRAITS:Print(...)
	print(BLINKIISPORTRAITS.Name .. ":", ...)
end

function BLINKIISPORTRAITS:LoadDB()
	self.db = LibStub("AceDB-3.0"):New("BlinkiisPortraitsDB", BLINKIISPORTRAITS.defaults, true)
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

function BLINKIISPORTRAITS:DelayedUpdate()
	C_Timer_After(0.1, BLINKIISPORTRAITS.LoadPortraits)
end

function BLINKIISPORTRAITS:PLAYER_ENTERING_WORLD()
	C_Timer_After(0.1, BLINKIISPORTRAITS.LoadPortraits)
end

local function UpdateGroupPortraits(_, typ)
	if typ == "arena" then
		BLINKIISPORTRAITS:InitializeArenaPortrait(true)
	elseif typ == "boss" then
		BLINKIISPORTRAITS:InitializeBossPortrait(true)
	elseif typ.groups and typ.groupName == "party" then
		BLINKIISPORTRAITS:InitializePartyPortrait(true)
	end
end

local function IsSUFParent()
	local units = { "player", "target", "targettarget", "focus", "party", "boss", "arena" }

	for _, unit in ipairs(units) do
		if BLINKIISPORTRAITS.db.profile[unit].unitframe == "suf" then return true end
	end
	return false
end

function BLINKIISPORTRAITS:OnInitialize()
	BLINKIISPORTRAITS.SUF = IsAddOnLoaded("ShadowedUnitFrames")
	BLINKIISPORTRAITS.ELVUI = IsAddOnLoaded("ElvUI")
	BLINKIISPORTRAITS.PB4 = IsAddOnLoaded("PitBull4")
	BLINKIISPORTRAITS.Cell = IsAddOnLoaded("Cell") and IsAddOnLoaded("Cell_UnitFrames")

	BLINKIISPORTRAITS:LoadDB()
	BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- add options profile tab
	BLINKIISPORTRAITS.options.args.profile_group = LibStub("AceDBOptions-3.0"):GetOptionsTable(BLINKIISPORTRAITS.db)

	-- callback on profile change
	self.db.RegisterCallback(self, "OnProfileChanged", BLINKIISPORTRAITS.LoadPortraits)

	-- fix for suf
	if BLINKIISPORTRAITS.SUF and IsSUFParent() and ShadowUF then
		if not BLINKIISPORTRAITS.SUF_Hook then
			hooksecurefunc(ShadowUF.Units, "CheckUnitStatus", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "InitializeFrame", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "UninitializeFrame", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "CheckGroupedUnitStatus", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "CheckUnitStatus", BLINKIISPORTRAITS.DelayedUpdate)
			BLINKIISPORTRAITS.SUF_Hook = true
		end
	end

	-- add options to elvui options
	if IsAddOnLoaded("ElvUI") then ElvUI[1].Libs.EP:RegisterPlugin(addonName, BLINKIISPORTRAITS.LoadOptions) end

	-- elvui demo mode
	if BLINKIISPORTRAITS.ELVUI and ElvUI then
		local UF = ElvUI[1]:GetModule("UnitFrames")
		hooksecurefunc(UF, "ToggleForceShowGroupFrames", UpdateGroupPortraits)
		hooksecurefunc(UF, "HeaderConfig", UpdateGroupPortraits)
	end

	-- update custom class icons
	BLINKIISPORTRAITS:UpdateCustomClassIcons()
end
