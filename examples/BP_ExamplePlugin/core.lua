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
