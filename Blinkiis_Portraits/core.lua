local _G = _G
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local addonName, _ = ...
local C_Timer_After = C_Timer.After
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local pairs = pairs
local select = select

BLINKIISPORTRAITS = LibStub("AceAddon-3.0"):NewAddon("BLINKIISPORTRAITS", "AceEvent-3.0", "AceConsole-3.0")

BLINKIISPORTRAITS.Version = GetAddOnMetadata(addonName, "Version")
BLINKIISPORTRAITS.Name = L["|CFF00A3FFB|r|CFF00B4FFl|r|CFF00C6FFi|r|CFF00D8FFn|r|CFF00EAFFk|r|CFF00F6FFi|r|CFF00F6FFi|r Portraits"]
BLINKIISPORTRAITS.Icon = "|TInterface\\Addons\\Blinkiis_Portraits\\media\\icon_32.tga:16:16|t"
BLINKIISPORTRAITS.Logo = "Interface\\Addons\\Blinkiis_Portraits\\media\\logo.tga"
BLINKIISPORTRAITS.media = {}
BLINKIISPORTRAITS.defaults = {}
BLINKIISPORTRAITS.dialogs = {}
BLINKIISPORTRAITS.LoadedAddons = {}
BLINKIISPORTRAITS.CachedBossIDs = {}
BLINKIISPORTRAITS.DebugEnabled = false

do
	BLINKIISPORTRAITS.Mists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
	BLINKIISPORTRAITS.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
	BLINKIISPORTRAITS.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
	BLINKIISPORTRAITS.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	BLINKIISPORTRAITS.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

-- radial status bars (WoW 12.1), missing on the classic clients the other TOCs target
BLINKIISPORTRAITS.RadialRenderMode = _G.Enum and _G.Enum.StatusBarRenderMode and _G.Enum.StatusBarRenderMode.Radial

-- secret API (WoW 12.1), missing on the classic clients the other TOCs target
local issecretvalue = _G.issecretvalue
local ShouldUnitIdentityBeSecret = _G.C_Secrets and _G.C_Secrets.ShouldUnitIdentityBeSecret

local UnitClass, UnitInPartyIsAI, UnitIsPlayer = UnitClass, UnitInPartyIsAI, UnitIsPlayer

function BLINKIISPORTRAITS:IsSecretValue(value)
	return (issecretvalue and issecretvalue(value)) or false
end

function BLINKIISPORTRAITS:SafeValue(value)
	if issecretvalue and issecretvalue(value) then return nil end

	return value
end

-- hidden identity in combat: enemy players and hostile NPCs in dungeons, every identity API answers them with a secret value
function BLINKIISPORTRAITS:IsSecretUnit(unit)
	return (unit and ShouldUnitIdentityBeSecret and ShouldUnitIdentityBeSecret(unit)) or false
end

-- a secret unit is hostile but not necessarily a player, only icon and mirror handling treat it as one
function BLINKIISPORTRAITS:GetUnitIdentity(unit)
	if not unit then return false, false, nil end

	local isSecret = BLINKIISPORTRAITS:IsSecretUnit(unit)
	local isPlayer = isSecret or BLINKIISPORTRAITS:SafeValue(UnitIsPlayer(unit)) or (BLINKIISPORTRAITS.Retail and BLINKIISPORTRAITS:SafeValue(UnitInPartyIsAI(unit))) or false

	return isSecret, isPlayer, select(2, UnitClass(unit))
end

BLINKIISPORTRAITS.Portraits = {}

function BLINKIISPORTRAITS_OnAddonCompartmentClick()
	LibStub("AceConfigDialog-3.0"):Open("BLINKIISPORTRAITS")
end

function BLINKIISPORTRAITS_OnAddonCompartmentOnEnter()
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR_RIGHT")
	GameTooltip:AddDoubleLine(BLINKIISPORTRAITS.Name, format(L["|CFFF7DC6FVer. %s|r"], BLINKIISPORTRAITS.Version))
	GameTooltip:Show()
end

function BLINKIISPORTRAITS_OnAddonCompartmentOnLeave()
	GameTooltip:Hide()
end

function BLINKIISPORTRAITS:Print(...)
	print(BLINKIISPORTRAITS.Name .. ":", ...)
end

function BLINKIISPORTRAITS:Debug(...)
	if not BLINKIISPORTRAITS.DebugEnabled then return end
	print("|cff888888[BP]|r", ...)
end

local function GetTableLength(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end
	return count
end

local function PrintTable(tbl, indent, simple, noFunctions, depth)
	indent = indent or " "
	depth = depth or 1
	local colors = "|CFF" .. format("%X", random(50, 200)) .. format("%X", random(50, 200)) .. format("%X", random(50, 200))
	local color = "|CFF" .. format("%X", random(50, 200)) .. format("%X", random(50, 200)) .. format("%X", random(50, 200))
	if type(tbl) == "table" then
		print(color .. indent .. " {|r")
		for entry, value in pairs(tbl) do
			if (type(value) == "table") and not simple then
				PrintTable(value, indent .. indent .. "[" .. entry .. "]", true, noFunctions, depth + 1)
			else
				if type(entry) == "table" then entry = tostring(entry) end

				if type(value) == "table" then
					print(color .. indent .. "|r", "|cff60ffc3 [" .. entry .. "]|r", " > ", value)
				elseif type(value) == "number" then
					print(color .. indent .. "|r", "|cfff5b062 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "string" then
					print(color .. indent .. "|r", "|cffd56ef5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "boolean" then
					print(color .. indent .. "|r", "|cff96e1ff[" .. entry .. "]|r", " = ", (value and "|cffabff87true|r" or "|cffff8787false|r"))
				elseif (type(value) == "function") and not noFunctions then
					print(color .. indent .. "|r", "|cffb5b3f5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) ~= "function" then
					print(color .. indent .. "|r", "|cfffbd7f9 [" .. entry .. "]|r", " = ", value)
				end
			end
		end
		print(color .. indent .. " }|r")
		print(" ")
	else
		print(tostring(tbl))
	end
end

function BLINKIISPORTRAITS:DebugPrintTable(tbl, simple, noFunctions)
	if type(tbl) == "table" then
		local tblLength = GetTableLength(tbl)
		BLINKIISPORTRAITS:Print(": Table Start >>>", tbl, "Entries:", tblLength, "Options:", "Simple:", simple, "Functions:", noFunctions)
		PrintTable(tbl, "-", (tblLength > 50), noFunctions)
	else
		BLINKIISPORTRAITS:Print("Not a Table:", tbl)
	end
end

function BLINKIISPORTRAITS:LoadDB()
	self.db = LibStub("AceDB-3.0"):New("BlinkiisPortraitsDB", BLINKIISPORTRAITS.defaults, true)
end

-- a fork ships under its own folder but keeps the frame names of the original, so it shares its flag
local ADDON_FOLDERS = {
	SUF = { "ShadowedUnitFrames", "ShadowedUnitFrames-WorgenFix" },
	ELVUI = { "ElvUI" },
	PB4 = { "PitBull4" },
	Cell = { "Cell" },
	Cell_UF = { "Cell_UnitFrames" },
	UUF = { "UnhaltedUnitFrames" },
	NDUI = { "NDui" },
	EQOL = { "EnhanceQoL" },
	BBF = { "BetterBlizzFrames" },
	EUI = { "EllesmereUI" },
	STUF = { "Stuf" },
	DF = { "DandersFrames" },
	JI = { "ElvUI_JiberishIcons" },
}

local function GetLoadedAddon(folders)
	for _, folder in ipairs(folders) do
		if IsAddOnLoaded(folder) then return folder end
	end
end

local function CheckAddons()
	for flag, folders in pairs(ADDON_FOLDERS) do
		local loaded = GetLoadedAddon(folders)

		BLINKIISPORTRAITS.LoadedAddons[flag] = loaded
		BLINKIISPORTRAITS[flag] = loaded ~= nil
	end
end

local isDelayedUpdateScheduled = false

function BLINKIISPORTRAITS:LoadPortraits()
	if InCombatLockdown() then
		if not isDelayedUpdateScheduled then
			isDelayedUpdateScheduled = true
			C_Timer_After(1, function()
				isDelayedUpdateScheduled = false
				BLINKIISPORTRAITS:LoadPortraits()
			end)
		end
		return
	end

	isDelayedUpdateScheduled = false

	CheckAddons()

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
	C_Timer_After(0.5, BLINKIISPORTRAITS.LoadPortraits)
end

-- header based addons create their unit buttons lazily, so every roster change needs a re-check
local partyWatcherEvents = {
	"GROUP_ROSTER_UPDATE",
	"PARTY_MEMBER_ENABLE",
	"PARTY_MEMBER_DISABLE",
}

local isPartyRefreshScheduled = false

-- throttled to coalesce event bursts, deferred while anchors and attributes are locked
function BLINKIISPORTRAITS:RefreshPartyPortraits()
	if isPartyRefreshScheduled then return end
	isPartyRefreshScheduled = true

	C_Timer_After(0.5, function()
		isPartyRefreshScheduled = false

		if InCombatLockdown() then
			BLINKIISPORTRAITS:RefreshPartyPortraits()
			return
		end

		if BLINKIISPORTRAITS:HasPendingPartyPortraits() then BLINKIISPORTRAITS:InitializePartyPortrait() end
	end)
end

local function OnPartyWatcherEvent()
	BLINKIISPORTRAITS:RefreshPartyPortraits()
end

local function CreatePartyWatcher()
	if BLINKIISPORTRAITS.PartyWatcher then return end

	local watcher = CreateFrame("Frame", "BP_PartyWatcher")

	for _, event in ipairs(partyWatcherEvents) do
		watcher:RegisterEvent(event)
	end

	watcher:SetScript("OnEvent", OnPartyWatcherEvent)
	BLINKIISPORTRAITS.PartyWatcher = watcher
end

function BLINKIISPORTRAITS:PLAYER_ENTERING_WORLD()
	-- JiberishIcons builds its style packs on its own ADDON_LOADED, which can run after ours
	if BLINKIISPORTRAITS.JI then BLINKIISPORTRAITS:SetupJiberishClassIcons() end

	C_Timer_After(0.5, BLINKIISPORTRAITS.LoadPortraits)
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
		local unitframe = BLINKIISPORTRAITS.db.profile[unit].unitframe
		local resolvedFrame, resolvedParent = BLINKIISPORTRAITS:GetUnitFrames(unit, unitframe)
		if resolvedFrame and resolvedParent == "suf" then return true end
	end
	return false
end

function BLINKIISPORTRAITS:OnInitialize()
	CheckAddons()

	BLINKIISPORTRAITS:LoadDB()
	BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")
	CreatePartyWatcher()

	BLINKIISPORTRAITS.options.args.profile_group.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(BLINKIISPORTRAITS.db)

	BLINKIISPORTRAITS.CachedBossIDs = BLINKIISPORTRAITS.db.global.BossIDs or {}

	self.db.RegisterCallback(self, "OnProfileChanged", BLINKIISPORTRAITS.LoadPortraits)

	if BLINKIISPORTRAITS.SUF and IsSUFParent() and ShadowUF then
		if not BLINKIISPORTRAITS.SUF_Hook then
			hooksecurefunc(ShadowUF.Units, "CheckUnitStatus", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "InitializeFrame", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "UninitializeFrame", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.Units, "CheckGroupedUnitStatus", BLINKIISPORTRAITS.DelayedUpdate)
			hooksecurefunc(ShadowUF.modules.movers, "Update", BLINKIISPORTRAITS.DelayedUpdate)
			BLINKIISPORTRAITS.SUF_Hook = true
		end
	end

	if BLINKIISPORTRAITS.EQOL then
		local EQOL_GF = (_G.EnhanceQoL and _G.EnhanceQoL.Aura and _G.EnhanceQoL.Aura.UF) and _G.EnhanceQoL.Aura.UF.GroupFrames or nil
		if EQOL_GF then hooksecurefunc(EQOL_GF, "RefreshGroupIcons", BLINKIISPORTRAITS.DelayedUpdate) end
	end

	BLINKIISPORTRAITS:SetupElvUIOptions()

	if BLINKIISPORTRAITS.ELVUI and ElvUI then
		local UF = ElvUI[1]:GetModule("UnitFrames")
		hooksecurefunc(UF, "ToggleForceShowGroupFrames", UpdateGroupPortraits)
		hooksecurefunc(UF, "HeaderConfig", UpdateGroupPortraits)
	end

	BLINKIISPORTRAITS:UpdateCustomClassIcons()

	if not BLINKIISPORTRAITS.db.profile.db_Update or BLINKIISPORTRAITS.db.profile.db_Update < 1.30 then
		-- the version string can carry suffixes ("1.52.1", "1.52-beta")
		local versionNumber = tonumber(BLINKIISPORTRAITS.Version) or tonumber(strmatch(BLINKIISPORTRAITS.Version or "", "%d+%.?%d*")) or 1.30
		BLINKIISPORTRAITS.db.profile.db_Update = versionNumber
		BLINKIISPORTRAITS.db.profile.misc.zoom = 0
	end
end
