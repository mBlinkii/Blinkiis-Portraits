local _, ns = ...

local Check = ns.Check
local API = BLINKIISPORTRAITS and BLINKIISPORTRAITS.API

Check("API exists", type(API) == "table")
Check("API version 1", API and API.version == 1)
if not API then return end

local function BuildOptions()
	return {
		type = "group",
		name = "Example",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = "Enable example elements",
				get = function()
					return ns.plugin.db.profile.enabled
				end,
				set = function(_, value)
					ns.plugin.db.profile.enabled = value
					if API.Refresh then API:Refresh() end
				end,
			},
		},
	}
end

local plugin = API:NewPlugin("BP_ExamplePlugin", { apiVersion = 1, defaults = { profile = { enabled = true } }, options = BuildOptions })
Check("NewPlugin returns plugin", plugin ~= nil)
ns.plugin = plugin

local playerFrame = CreateFrame("Frame", "BPEX_PlayerFrame", UIParent, "BackdropTemplate")
playerFrame:SetSize(100, 40)
playerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
playerFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
playerFrame:SetBackdropColor(0, 0, 0, 0.5)
playerFrame.unit = "player"

local registered = API:RegisterFrameProvider("bpex", { label = "BP Example", addons = { "BP_ExamplePlugin" }, units = { player = "BPEX_PlayerFrame" } })
Check("provider registered", registered == true)
Check("duplicate provider rejected", API:RegisterFrameProvider("bpex", { label = "x", addons = {}, units = {} }) == false)

ns.Later(function()
	local portrait
	for key, p in API:GetPortraits() do
		if key == "player" then portrait = p end
	end
	print("BP_ExamplePlugin: player portrait parent is " .. tostring(portrait and portrait.parentFrame and portrait.parentFrame:GetName()))
end)

local MEDIA = "Interface\\Addons\\Blinkiis_Portraits\\media\\"
Check("style registered", API:RegisterStyle("bpex_round", { name = "BPEX Round", texture = MEDIA .. "circle.tga", mask = MEDIA .. "circle_mask.tga" }) == true)
Check("builtin style id rejected", API:RegisterStyle("antik", { name = "x", texture = "x", mask = "x" }) == false)
Check("class icon set registered", API:RegisterClassIconSet("bpex_icons", {
	name = "BPEX Icons",
	texture = "Interface\\WorldStateFrame\\Icons-Classes",
	texCoords = CLASS_ICON_TCOORDS,
}) == true)

local seen = {}
local function Remember(event, portrait)
	seen[event] = portrait or true
end
for _, event in ipairs({ "PortraitCreated", "PortraitSetup", "PortraitUnitChanged", "PortraitUpdated", "PortraitsLoaded" }) do
	API.RegisterCallback(seen, event, Remember)
end
API.RegisterCallback(seen, "ProfileChanged", function()
	print("BP_ExamplePlugin: ProfileChanged")
end)

ns.Later(function()
	local setup = seen.PortraitSetup
	Check("PortraitSetup fired", setup ~= nil)
	Check("PortraitsLoaded fired", seen.PortraitsLoaded == true)
	Check("PortraitUpdated fired", seen.PortraitUpdated ~= nil)
	Check("PortraitUnitChanged fired", seen.PortraitUnitChanged ~= nil)
	Check("portrait.key set", type(setup) == "table" and setup.key ~= nil)
	Check("portrait.plugins table", type(setup) == "table" and type(setup.plugins) == "table")
	local count = 0
	for _ in API:GetPortraits() do
		count = count + 1
	end
	Check("GetPortraits iterates", count > 0)
end)

local results = {}
local function Capture(name)
	return function(_, _, _, ...)
		results[name] = { n = select("#", ...), ... }
	end
end

for _, name in ipairs({ "Desaturate", "Color", "Extra", "Portrait", "Frame", "Cast", "Ring" }) do
	Check("hook " .. name, API:HookElement(plugin, name, { PostUpdate = Capture(name) }) == true)
end
Check("hook from a fake plugin rejected", API:HookElement({ name = "Fake" }, "Color", { PostUpdate = Capture("Fake") }) == false)

local healthHits = 0
Check("element registered", API:RegisterElement(plugin, "BPEX_Counter", {
	events = { "UNIT_HEALTH" },
	Enable = function()
		return plugin.db.profile.enabled
	end,
	Update = function()
		healthHits = healthHits + 1
	end,
}) == true)
Check("builtin element name rejected", API:RegisterElement(plugin, "Ring", { Enable = function() end, Update = function() end }) == false)

ns.Later(function()
	Check("Desaturate PostUpdate result", results.Desaturate ~= nil and type(results.Desaturate[1]) == "boolean")
	Check("Color PostUpdate gets table", results.Color ~= nil and type(results.Color[1]) == "table")
	Check("Portrait PostUpdate ran", results.Portrait ~= nil)
	Check("Frame PostUpdate gets texture", results.Frame ~= nil and results.Frame[1] ~= nil)
	Check("Ring PostUpdate ran", results.Ring ~= nil)
	print(format("BP_ExamplePlugin: UNIT_HEALTH reached the counter element %d times, last cast icon: %s", healthHits, tostring(results.Cast and results.Cast[1])))
end)

ns.commands.red = function()
	local ok = API:HookElement(plugin, "Color", {
		Override = function(_, portrait)
			local color = { r = 1, g = 0, b = 0, a = 1 }
			portrait.texture:SetVertexColor(1, 0, 0, 1)
			return color
		end,
	})
	print("BP_ExamplePlugin: red frame override " .. (ok and "active, /reload to undo" or "rejected"))
	API:Refresh()
end

ns.commands.boom = function()
	API:HookElement(plugin, "Desaturate", {
		PostUpdate = function()
			error("BP_ExamplePlugin: intentional hook error")
		end,
	})
	print("BP_ExamplePlugin: failing Desaturate hook active, change target and check BugSack, /reload to undo")
end
