local BLINKIISPORTRAITS = BLINKIISPORTRAITS
local LibStub = LibStub
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local format = format
local pairs = pairs
local type = type
local tostring = tostring
local xpcall = xpcall
local geterrorhandler = geterrorhandler
local securecallfunction = securecallfunction
local C_Timer = C_Timer

local API_VERSION = 1

local API = { version = API_VERSION }
BLINKIISPORTRAITS.API = API

local plugins = {}
local pluginOrder = {}

-- CallbackHandler returns early while an event has no subscriber, so firing in hot paths stays cheap
local callbacks = LibStub("CallbackHandler-1.0"):New(API)

function BLINKIISPORTRAITS:Fire(event, ...)
	callbacks:Fire(event, ...)
end

function API:IsSecretValue(value)
	return BLINKIISPORTRAITS:IsSecretValue(value)
end

function API:SafeValue(value)
	return BLINKIISPORTRAITS:SafeValue(value)
end

function API:GetUnitColor(unit, isDead, isPlayer, class, isSecret)
	return BLINKIISPORTRAITS:GetUnitColor(unit, isDead, isPlayer, class, isSecret)
end

function API:GetPortraits()
	return pairs(BLINKIISPORTRAITS.Portraits)
end

local function PackResults(ok, ...)
	if ok then return ... end
end

function BLINKIISPORTRAITS:SafeCall(fn, ...)
	if securecallfunction then return securecallfunction(fn, ...) end

	return PackResults(xpcall(fn, geterrorhandler(), ...))
end

local function Reject(reason)
	BLINKIISPORTRAITS:Print(reason)
	return nil, reason
end

local function NotifyOptions()
	local registry = LibStub("AceConfigRegistry-3.0", true)
	if registry then registry:NotifyChange("BLINKIISPORTRAITS") end
end

local function GetPluginsGroup()
	local args = BLINKIISPORTRAITS.options and BLINKIISPORTRAITS.options.args
	return args and args.plugins_group
end

local function AddPluginOptions(plugin, builder)
	local group = GetPluginsGroup()
	if not group or type(builder) ~= "function" then return end

	local options = builder()
	if type(options) ~= "table" then return end

	options.order = options.order or (#pluginOrder + 1)
	group.args[plugin.name] = options
end

function API:NewPlugin(name, opts)
	if type(name) ~= "string" or name == "" then return Reject(L["Plugin registration needs a name."]) end

	opts = opts or {}
	if plugins[name] then return Reject(format(L["Plugin %s is already registered."], name)) end
	if opts.apiVersion ~= API_VERSION then return Reject(format(L["Plugin %s needs API version %s, Blinkiis Portraits provides %d."], name, tostring(opts.apiVersion), API_VERSION)) end
	if not BLINKIISPORTRAITS.db then return Reject(format(L["Plugin %s registered before Blinkiis Portraits was initialized."], name)) end

	local plugin = { name = name }
	plugin.db = BLINKIISPORTRAITS.db:RegisterNamespace(name, opts.defaults)

	plugins[name] = plugin
	pluginOrder[#pluginOrder + 1] = name

	AddPluginOptions(plugin, opts.options)
	NotifyOptions()

	return plugin
end

function API:GetPlugin(name)
	return plugins[name]
end

function API:IteratePlugins()
	local index = 0
	return function()
		index = index + 1
		local name = pluginOrder[index]
		if name then return name, plugins[name] end
	end
end

function API:Refresh()
	BLINKIISPORTRAITS:LoadPortraits()
	NotifyOptions()
end

local registeredStyles = {}
local hasLoaded = false
local isRefreshScheduled = false

API.RegisterCallback(registeredStyles, "PortraitsLoaded", function()
	hasLoaded = true
end)

local function RunScheduledRefresh()
	isRefreshScheduled = false
	API:Refresh()
end

-- several registrations in one frame share a single reload
local function ScheduleRefresh()
	if not hasLoaded or isRefreshScheduled then return end

	isRefreshScheduled = true
	C_Timer.After(0, RunScheduledRefresh)
end

local function AddMedia(kind, id, def)
	local list = BLINKIISPORTRAITS.media[kind]
	if type(id) ~= "string" or list[id] ~= nil then return false end

	list[id] = def
	ScheduleRefresh()
	return true
end

local function HasTextureAndName(def)
	return type(def) == "table" and type(def.name) == "string" and def.texture ~= nil
end

function API:RegisterStyle(id, def)
	if not HasTextureAndName(def) or def.mask == nil then return false end
	if not AddMedia("portraits", id, def) then return false end

	registeredStyles[id] = def
	return true
end

function API:RegisterClassIconSet(id, def)
	if not HasTextureAndName(def) or type(def.texCoords) ~= "table" then return false end

	return AddMedia("class", id, def)
end

function API:RegisterSpecIconSet(id, def)
	if not BLINKIISPORTRAITS.SpecIconsSupported then return false end
	if not HasTextureAndName(def) or type(def.texCoords) ~= "table" then return false end

	return AddMedia("spec", id, def)
end

function BLINKIISPORTRAITS:GetRegisteredStyles()
	return registeredStyles
end

-- a style can vanish when the plugin that registered it is disabled
function BLINKIISPORTRAITS:ResolveStyle(id, defaultId)
	local styles = BLINKIISPORTRAITS.media.portraits
	if styles[id] then return styles[id], id end

	return styles[defaultId], defaultId
end

local pluginsGroup = GetPluginsGroup()
if pluginsGroup then pluginsGroup.hidden = function()
	return pluginOrder[1] == nil
end end
