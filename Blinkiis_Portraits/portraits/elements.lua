local BLINKIISPORTRAITS = BLINKIISPORTRAITS
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local format = format
local ipairs = ipairs
local pairs = pairs
local sort = table.sort
local type = type

local definitions = {}
local hooks = {}

function BLINKIISPORTRAITS:DefineElement(name, def)
	definitions[name] = def
end

function BLINKIISPORTRAITS:GetElementDefinition(name)
	return definitions[name]
end

function BLINKIISPORTRAITS:GetElementHooks(name)
	return hooks[name]
end

local function GetState(portrait, name)
	local elements = portrait.elements
	if not elements then
		elements = {}
		portrait.elements = elements
	end

	local state = elements[name]
	if not state then
		state = {}
		elements[name] = state
	end
	return state
end

-- elements return at most four values; the first one stays readable for other elements as element.result
local function Keep(state, a, b, c, d)
	state.result = a
	return a, b, c, d
end

local function RunPost(list, state, portrait, unit, ...)
	state.result = ...
	for i = 1, #list do
		BLINKIISPORTRAITS:SafeCall(list[i], state, portrait, unit, ...)
	end
	return ...
end

-- without hooks this is a plain call, so the builtin paths keep their cost
function BLINKIISPORTRAITS:RunElement(portrait, name, event, unit)
	local def = definitions[name]
	if not def then return end

	local state = GetState(portrait, name)
	local hook = hooks[name]
	if not hook then return Keep(state, def.Update(state, portrait, event, unit)) end

	local pre = hook.pre
	for i = 1, #pre do
		BLINKIISPORTRAITS:SafeCall(pre[i], state, portrait, unit)
	end

	if hook.override then return RunPost(hook.post, state, portrait, unit, BLINKIISPORTRAITS:SafeCall(hook.override, state, portrait, event, unit)) end

	return RunPost(hook.post, state, portrait, unit, def.Update(state, portrait, event, unit))
end

function BLINKIISPORTRAITS:HookElementInternal(pluginName, name, spec)
	if not definitions[name] or type(spec) ~= "table" then return false end

	local hook = hooks[name]
	if spec.Override and hook and hook.override then
		local reason = format(L["%s cannot override the portrait element %s, %s already does."], pluginName, name, hook.overrideOwner)
		BLINKIISPORTRAITS:Print(reason)
		return false, reason
	end

	if not hook then
		hook = { pre = {}, post = {}, events = {} }
		hooks[name] = hook
	end

	if spec.PreUpdate then hook.pre[#hook.pre + 1] = spec.PreUpdate end
	if spec.PostUpdate then hook.post[#hook.post + 1] = spec.PostUpdate end
	if spec.Override then
		hook.override = spec.Override
		hook.overrideOwner = pluginName
	end
	if type(spec.events) == "table" then
		for _, event in ipairs(spec.events) do
			hook.events[#hook.events + 1] = event
		end
	end

	return true
end

local pluginElements = {}
local pluginElementNames = {}

local function IsRegisteredPlugin(plugin)
	return type(plugin) == "table" and plugin.name ~= nil and BLINKIISPORTRAITS.API:GetPlugin(plugin.name) == plugin
end

function BLINKIISPORTRAITS.API:RegisterElement(plugin, name, def)
	if not IsRegisteredPlugin(plugin) or type(name) ~= "string" or definitions[name] then return false end
	if type(def) ~= "table" or type(def.Enable) ~= "function" or type(def.Update) ~= "function" then return false end

	definitions[name] = def
	pluginElements[name] = plugin.name
	pluginElementNames[#pluginElementNames + 1] = name
	sort(pluginElementNames)

	return true
end

function BLINKIISPORTRAITS.API:HookElement(plugin, name, spec)
	if not IsRegisteredPlugin(plugin) then return false end

	return BLINKIISPORTRAITS:HookElementInternal(plugin.name, name, spec)
end

local function AddRoute(routes, list, event, name)
	local names = routes[event]
	if not names then
		names = {}
		routes[event] = names
		list[#list + 1] = event
	end

	for i = 1, #names do
		if names[i] == name then return end
	end
	names[#names + 1] = name
end

local function SortRoutes(routes)
	for _, names in pairs(routes) do
		sort(names)
	end
end

-- built once per setup, the event path only reads these tables
function BLINKIISPORTRAITS:BuildElementRouting(portrait)
	local routes, list = {}, {}

	for _, name in ipairs(pluginElementNames) do
		local def = definitions[name]
		local state = GetState(portrait, name)
		local isEnabled = BLINKIISPORTRAITS:SafeCall(def.Enable, state, portrait) and true or false

		if state.enabled and not isEnabled and def.Disable then BLINKIISPORTRAITS:SafeCall(def.Disable, state, portrait) end
		state.enabled = isEnabled

		if isEnabled and def.events then
			for _, event in ipairs(def.events) do
				AddRoute(routes, list, event, name)
			end
		end
	end

	for name, hook in pairs(hooks) do
		local isActive = not pluginElements[name] or GetState(portrait, name).enabled
		if isActive then
			for _, event in ipairs(hook.events) do
				AddRoute(routes, list, event, name)
			end
		end
	end

	SortRoutes(routes)
	portrait.elementEvents = routes
	portrait.elementEventList = list
end

function BLINKIISPORTRAITS.API:UpdateElement(portrait, name)
	return BLINKIISPORTRAITS:RunElement(portrait, name, "UpdateElement", portrait.unit)
end
