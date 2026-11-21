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
