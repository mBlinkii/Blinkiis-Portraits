local _G = _G
local BLINKIISPORTRAITS = BLINKIISPORTRAITS
local C_AddOns = _G.C_AddOns

local ipairs = ipairs
local UnitName = UnitName

local OWN_FOLDER = "Blinkiis_Portraits"
local ALWAYS_KEPT = { "BugSack", "!BugGrabber" }
local OPTIONAL_KEPT = { "JiberishIcons", "ElvUI_JiberishIcons" }

local function GetCharacter()
	return UnitName("player")
end

local function IsEnabled(name)
	return (C_AddOns.GetAddOnEnableState(name, GetCharacter()) or 0) > 0
end

local function GetDependencies(name)
	return { C_AddOns.GetAddOnDependencies(name) }
end

local function KeepWithDependencies(keep, name)
	if keep[name] then return end

	keep[name] = true
	for _, dependency in ipairs(GetDependencies(name)) do
		KeepWithDependencies(keep, dependency)
	end
end

local function KeepIfEnabled(keep, name)
	if IsEnabled(name) then KeepWithDependencies(keep, name) end
end

-- load on demand modules of kept addons (ElvUI_Options) stay, plugins of Blinkiis Portraits never do
local function IsModuleOfKept(keep, name)
	if not C_AddOns.IsAddOnLoadOnDemand(name) then return false end

	local dependencies = GetDependencies(name)
	if not dependencies[1] then return false end

	for _, dependency in ipairs(dependencies) do
		if dependency == OWN_FOLDER or not keep[dependency] then return false end
	end
	return true
end

function BLINKIISPORTRAITS:GetDebugModeKeepSet(ownFolder)
	local keep = {}
	KeepWithDependencies(keep, ownFolder or OWN_FOLDER)

	for _, name in ipairs(ALWAYS_KEPT) do
		KeepIfEnabled(keep, name)
	end
	for _, name in ipairs(OPTIONAL_KEPT) do
		KeepIfEnabled(keep, name)
	end
	for _, provider in ipairs(BLINKIISPORTRAITS:GetProviders()) do
		for _, folder in ipairs(provider.addons) do
			KeepIfEnabled(keep, folder)
		end
	end

	for index = 1, C_AddOns.GetNumAddOns() do
		local name = C_AddOns.GetAddOnInfo(index)
		if name and not keep[name] and IsModuleOfKept(keep, name) then keep[name] = true end
	end

	return keep
end

function BLINKIISPORTRAITS:IsDebugModeActive()
	local state = BLINKIISPORTRAITS.db.char.debugMode
	return (state and state.active) or false
end

-- a second call must not replace the saved list with an empty one
function BLINKIISPORTRAITS:EnableDebugMode(ownFolder)
	if BLINKIISPORTRAITS:IsDebugModeActive() then return 0 end

	local keep = BLINKIISPORTRAITS:GetDebugModeKeepSet(ownFolder)
	local character = GetCharacter()
	local disabled = {}

	for index = 1, C_AddOns.GetNumAddOns() do
		local name = C_AddOns.GetAddOnInfo(index)
		if name and not keep[name] and IsEnabled(name) then
			disabled[#disabled + 1] = name
			C_AddOns.DisableAddOn(name, character)
		end
	end

	BLINKIISPORTRAITS.db.char.debugMode = { active = true, disabled = disabled }
	return #disabled
end

local function IsInstalled(name)
	for index = 1, C_AddOns.GetNumAddOns() do
		if C_AddOns.GetAddOnInfo(index) == name then return true end
	end
	return false
end

function BLINKIISPORTRAITS:DisableDebugMode()
	if not BLINKIISPORTRAITS:IsDebugModeActive() then return nil end

	local character = GetCharacter()
	local restored = 0
	for _, name in ipairs(BLINKIISPORTRAITS.db.char.debugMode.disabled or {}) do
		if IsInstalled(name) then
			C_AddOns.EnableAddOn(name, character)
			restored = restored + 1
		end
	end

	BLINKIISPORTRAITS.db.char.debugMode = nil
	return restored
end
