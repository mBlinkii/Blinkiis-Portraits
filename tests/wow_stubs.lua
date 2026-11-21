local env = ...

local function noop() end

local frameMethods = setmetatable({}, {
	__index = function()
		return noop
	end,
})

function env.CreateFrame()
	return setmetatable({}, { __index = frameMethods })
end

env.reportedErrors = {}

function env.geterrorhandler()
	return function(err)
		env.reportedErrors[#env.reportedErrors + 1] = err
	end
end

-- WoW's xpcall forwards extra arguments, plain Lua 5.1 does not
function env.xpcall(fn, handler, ...)
	local args = { n = select("#", ...), ... }
	return xpcall(function()
		return fn(unpack(args, 1, args.n))
	end, handler)
end

local function DropStatus(ok, ...)
	if ok then return ... end
end

function env.securecallfunction(fn, ...)
	if type(fn) ~= "function" then return end
	return DropStatus(env.xpcall(fn, env.geterrorhandler(), ...))
end

function env.GetRealmName()
	return "TestRealm"
end

function env.UnitNameUnmodified()
	return "Tester"
end

function env.UnitClass()
	return "Warrior", "WARRIOR"
end

function env.UnitRace()
	return "Human", "Human"
end

function env.UnitFactionGroup()
	return "Alliance"
end

function env.GetCurrentRegion()
	return 3
end

function env.GetCurrentRegionName()
	return "EU"
end

function env.GetLocale()
	return "enUS"
end

env.format = string.format
env.strmatch = string.match
env.strfind = string.find
env.gmatch = string.gmatch
env.strsub = string.sub
env.strlower = string.lower
env.strlenutf8 = string.len
env.tinsert = table.insert
env.tremove = table.remove

function env.wipe(t)
	for k in pairs(t) do
		t[k] = nil
	end
	return t
end

local timers = {}

env.C_Timer = {
	After = function(_, fn)
		timers[#timers + 1] = fn
	end,
}

function env.flushTimers()
	while #timers > 0 do
		local pending = timers
		timers = {}
		for _, fn in ipairs(pending) do
			fn()
		end
	end
end

local inCombat = false

function env.InCombatLockdown()
	return inCombat
end

function env.setCombat(value)
	inCombat = value
end

local loadedAddons = {}

function env.IsAddOnLoaded(name)
	return loadedAddons[name] == true
end

env.C_AddOns = { IsAddOnLoaded = env.IsAddOnLoaded }

function env.setLoadedAddons(list)
	loadedAddons = {}
	for _, name in ipairs(list) do
		loadedAddons[name] = true
	end
end

env.noop = noop

local addonList = {}

function env.setAddOnList(list)
	addonList = list
end

local function FindAddOn(name)
	for _, addon in ipairs(addonList) do
		if addon.name == name then return addon end
	end
end

function env.UnitName()
	return "Tester"
end

env.C_AddOns.GetNumAddOns = function()
	return #addonList
end
env.C_AddOns.GetAddOnInfo = function(index)
	local addon = addonList[index]
	return addon and addon.name
end
env.C_AddOns.GetAddOnEnableState = function(name)
	local addon = FindAddOn(name)
	return (addon and addon.enabled) and 2 or 0
end
env.C_AddOns.IsAddOnLoadOnDemand = function(name)
	local addon = FindAddOn(name)
	return addon and addon.lod or false
end
env.C_AddOns.GetAddOnDependencies = function(name)
	local addon = FindAddOn(name)
	return unpack(addon and addon.deps or {})
end
env.C_AddOns.DisableAddOn = function(name)
	local addon = FindAddOn(name)
	if addon then addon.enabled = false end
end
env.C_AddOns.EnableAddOn = function(name)
	local addon = FindAddOn(name)
	if addon then addon.enabled = true end
end

function env.isAddOnEnabled(name)
	local addon = FindAddOn(name)
	return addon and addon.enabled or false
end

local addonMetadata = {}

function env.setAddOnMetadata(name, field, value)
	addonMetadata[name .. "|" .. field] = value
end

env.C_AddOns.GetAddOnMetadata = function(name, field)
	return addonMetadata[name .. "|" .. field]
end

function env.GetBuildInfo()
	return "12.1.5", "70961", "Nov 1 2026", 120105
end
