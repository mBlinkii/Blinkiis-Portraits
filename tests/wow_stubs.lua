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
