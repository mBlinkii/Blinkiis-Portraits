local _G = _G
local BLINKIISPORTRAITS = BLINKIISPORTRAITS
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local format = format
local gmatch = gmatch
local ipairs = ipairs
local pairs = pairs
local sort = table.sort
local strfind = strfind
local type = type

local PLUGIN_PRIORITY_START = 1000

local providers = {}
local providerList = {}
local nextPluginPriority = PLUGIN_PRIORITY_START

local function SortByPriority(a, b)
	return a.priority < b.priority
end

local function AddProvider(id, def)
	if type(id) ~= "string" or providers[id] or type(def) ~= "table" or type(def.addons) ~= "table" or type(def.units) ~= "table" then return false end

	local provider = {
		id = id,
		label = def.label or id,
		addons = def.addons,
		units = def.units,
		flag = def.flag,
		optionValue = def.optionValue or id,
		unitRestriction = def.unitRestriction,
		getUnit = def.getUnit,
		resolveName = def.resolveName,
		priority = def.priority,
		available = false,
	}

	if not provider.priority then
		provider.priority = nextPluginPriority
		nextPluginPriority = nextPluginPriority + 1
	end

	providers[id] = provider
	providerList[#providerList + 1] = provider
	sort(providerList, SortByPriority)

	return true
end

local function GetLoadedFolder(folders)
	for _, folder in ipairs(folders) do
		if IsAddOnLoaded(folder) then return folder end
	end
end

-- builtin providers keep their addon flags, the rest of the addon and the report still read them
function BLINKIISPORTRAITS:RefreshProviderAvailability()
	BLINKIISPORTRAITS.LoadedAddons = BLINKIISPORTRAITS.LoadedAddons or {}

	for _, provider in ipairs(providerList) do
		local folder = GetLoadedFolder(provider.addons)
		provider.available = folder ~= nil

		if provider.flag then
			BLINKIISPORTRAITS.LoadedAddons[provider.flag] = folder
			BLINKIISPORTRAITS[provider.flag] = provider.available
		end
	end
end

function BLINKIISPORTRAITS:GetProvider(id)
	return providers[id]
end

function BLINKIISPORTRAITS:GetProviders()
	return providerList
end

function BLINKIISPORTRAITS:GetProviderByOptionValue(optionValue)
	for _, provider in ipairs(providerList) do
		if provider.optionValue == optionValue then return provider end
	end
end

function BLINKIISPORTRAITS:GetProviderOptionValues()
	local values = { auto = L["AUTO"] }
	for _, provider in ipairs(providerList) do
		if not values[provider.optionValue] then values[provider.optionValue] = provider.label end
	end
	return values
end

function BLINKIISPORTRAITS.API:RegisterFrameProvider(id, def)
	if type(def) == "table" then
		def.flag = nil
		def.resolveName = nil
		def.optionValue = nil
	end

	local ok = AddProvider(id, def)
	if ok then BLINKIISPORTRAITS:RefreshProviderAvailability() end

	return ok
end

local function GetUnitEntry(provider, unit)
	if provider.resolveName then return provider.resolveName(unit) end

	return provider.units[unit]
end

local function IsUsable(provider, unit)
	return provider.available and (not provider.unitRestriction or provider.unitRestriction == unit)
end

function BLINKIISPORTRAITS:GetUnitFrameName(unit, optionValue)
	if not optionValue then return nil end

	for _, provider in ipairs(providerList) do
		if provider.optionValue == optionValue and IsUsable(provider, unit) then
			local entry = GetUnitEntry(provider, unit)
			if entry then return entry end
		end
	end
end

-- a loaded addon with a gap in its mapping must not block a lower priority addon
function BLINKIISPORTRAITS:GetUnitFrames(unit, setting)
	for _, provider in ipairs(providerList) do
		if IsUsable(provider, unit) and (setting == "auto" or setting == provider.optionValue) then
			local entry = GetUnitEntry(provider, unit)
			if entry then return entry, provider.optionValue end
		end
	end

	for _, provider in ipairs(providerList) do
		if IsUsable(provider, unit) then
			local entry = GetUnitEntry(provider, unit)
			if entry then return entry, provider.optionValue end
		end
	end
end

function BLINKIISPORTRAITS:ResolveFrame(path)
	if type(path) == "function" then return path() end
	if type(path) ~= "string" then return path end
	if not strfind(path, ".", 1, true) then return _G[path] end

	local obj = _G
	for part in gmatch(path, "[^%.]+") do
		obj = obj[part]
		if not obj then return nil end
	end
	return obj
end

function BLINKIISPORTRAITS:ResolveGroupFrame(entry, index)
	if type(entry) == "function" then return entry(index) end
	if type(entry) ~= "string" then return nil end

	return BLINKIISPORTRAITS:ResolveFrame(entry .. index)
end

-- oUF renamed frame.unit to __unit (ElvUI 15.22), Cell uses _unit, header frames only the attribute
function BLINKIISPORTRAITS:GetFrameUnit(frame, optionValue)
	if not frame then return nil end

	local provider = optionValue and BLINKIISPORTRAITS:GetProviderByOptionValue(optionValue)
	if provider and provider.getUnit then
		local unit = provider.getUnit(frame)
		if unit then return unit end
	end

	return frame.__unit or frame._unit or (frame.GetAttribute and frame:GetAttribute("unit")) or frame.unit
end

local function PitBull4Name(unit)
	local PitBull4 = _G.PitBull4
	local profile = PitBull4 and PitBull4.db and PitBull4.db.profile
	if not profile then return nil end

	for name, value in pairs(profile.units or {}) do
		if value and value.unit == unit and (unit ~= "focus" or not BLINKIISPORTRAITS.Classic) then return "PitBull4_Frames_" .. name end
	end

	local isClassicGroup = BLINKIISPORTRAITS.Classic and (unit == "boss" or unit == "arena")
	if isClassicGroup then return nil end

	for name, value in pairs(profile.groups or {}) do
		if value and value.unit_group == unit then return format("PitBull4_Groups_%sUnitButton", name) end
	end
end

local CLASSIC = BLINKIISPORTRAITS.Classic

-- priorities keep the order of the former hard-coded list
AddProvider("df", {
	label = "DandersFrames",
	flag = "DF",
	addons = { "DandersFrames" },
	priority = 10,
	unitRestriction = "party",
	units = { party = "DandersPartyHeaderUnitButton" },
})

-- Cell owns the party header, every other frame belongs to Cell_UnitFrames; both share the "cell" setting
AddProvider("cell", {
	label = "Cell",
	flag = "Cell",
	addons = { "Cell" },
	priority = 20,
	unitRestriction = "party",
	units = { party = "CellPartyFrameHeaderUnitButton" },
})

AddProvider("elvui", {
	label = "ElvUI",
	flag = "ELVUI",
	addons = { "ElvUI" },
	priority = 30,
	units = {
		player = "ElvUF_Player",
		target = "ElvUF_Target",
		pet = "ElvUF_Pet",
		targettarget = "ElvUF_TargetTarget",
		focus = not CLASSIC and "ElvUF_Focus" or nil,
		party = "ElvUF_PartyGroup1UnitButton",
		boss = not CLASSIC and "ElvUF_Boss" or nil,
		arena = "ElvUF_Arena",
	},
})

AddProvider("pb4", {
	label = "PitBull 4",
	flag = "PB4",
	addons = { "PitBull4" },
	priority = 40,
	units = {},
	resolveName = PitBull4Name,
})

AddProvider("suf", {
	label = "Shadowed Unit Frames",
	flag = "SUF",
	addons = { "ShadowedUnitFrames", "ShadowedUnitFrames-WorgenFix" },
	priority = 50,
	units = {
		player = "SUFUnitplayer",
		target = "SUFUnittarget",
		pet = "SUFUnitpet",
		targettarget = "SUFUnittargettarget",
		focus = not CLASSIC and "SUFUnitfocus" or nil,
		party = "SUFHeaderpartyUnitButton",
		boss = not CLASSIC and "SUFHeaderbossUnitButton" or nil,
		arena = "SUFHeaderarenaUnitButton",
	},
})

AddProvider("uuf", {
	label = "Unhalted Unit Frames",
	flag = "UUF",
	addons = { "UnhaltedUnitFrames" },
	priority = 60,
	units = {
		player = "UUF_Player",
		target = "UUF_Target",
		pet = "UUF_Pet",
		targettarget = "UUF_TargetTarget",
		focus = "UUF_Focus",
		party = "UUF_Party", -- UUF_Party1-4, individually spawned oUF frames (MAX_PARTY_FRAMES = 4)
		partyself = "UUF_PartyPlayer", -- separate player frame, only spawned when "Show Player" is on
		boss = "UUF_Boss",
	},
})

AddProvider("ndui", {
	label = "NDui",
	flag = "NDUI",
	addons = { "NDui" },
	priority = 70,
	units = {
		player = "oUF_Player",
		target = "oUF_Target",
		pet = "oUF_Pet",
		targettarget = "oUF_ToT",
		focus = not CLASSIC and "oUF_Focus" or nil,
		party = "oUF_PartyUnitButton",
		boss = not CLASSIC and "oUF_Boss" or nil,
		arena = not CLASSIC and "oUF_Arena" or nil,
	},
})

-- Cell_UnitFrames has no arena frames (see CUF Data/Constants.lua TITLE_CASED_UNITS)
AddProvider("cell_uf", {
	label = "Cell",
	flag = "Cell_UF",
	addons = { "Cell_UnitFrames" },
	optionValue = "cell",
	priority = 80,
	units = {
		player = "CUF_Player",
		target = "CUF_Target",
		pet = "CUF_Pet",
		targettarget = "CUF_TargetTarget",
		focus = not CLASSIC and "CUF_Focus" or nil,
		party = "CellPartyFrameHeaderUnitButton",
		boss = "CUF_Boss",
	},
})

AddProvider("eqol", {
	label = "EQOL",
	flag = "EQOL",
	addons = { "EnhanceQoL" },
	priority = 90,
	units = {
		player = "EQOLUFPlayerFrame",
		target = "EQOLUFTargetFrame",
		pet = "EQOLUFPetFrame",
		targettarget = "EQOLUFToTFrame",
		focus = "EQOLUFFocusFrame",
		party = "EQOLUFPartyHeaderUnitButton",
		boss = "EQOLUFBoss",
	},
})

-- the party member frames are children of PartyFrame, not globals
AddProvider("bbf", {
	label = "BetterBlizzFrames",
	flag = "BBF",
	addons = { "BetterBlizzFrames" },
	priority = 100,
	units = {
		player = "PlayerFrame",
		target = "TargetFrame",
		pet = "PetFrame",
		targettarget = "TargetTargetFrame",
		focus = "FocusFrame",
		party = "PartyFrame.MemberFrame",
	},
})

AddProvider("eui", {
	label = "EllesmereUI",
	flag = "EUI",
	addons = { "EllesmereUI" },
	priority = 110,
	units = {
		player = "EllesmereUIUnitFrames_Player",
		target = "EllesmereUIUnitFrames_Target",
		pet = "EllesmereUIUnitFrames_Pet",
		targettarget = "EllesmereUIUnitFrames_TargetTarget",
		focus = "EllesmereUIUnitFrames_Focus",
		party = "ERFPartyHeaderUnitButton",
		partyself = "ERFPartySelfButton", -- separate player button next to the party header
		boss = "EllesmereUIUnitFrames_Boss",
	},
})

AddProvider("stuf", {
	label = "Stuf",
	flag = "STUF",
	addons = { "Stuf" },
	priority = 120,
	units = {
		player = "Stuf.units.player",
		target = "Stuf.units.target",
		pet = "Stuf.units.pet",
		targettarget = "Stuf.units.targettarget",
		focus = "Stuf.units.focus",
		party = "Stuf.units.party",
		boss = "Stuf.units.boss",
		arena = "Stuf.units.arena",
	},
})
