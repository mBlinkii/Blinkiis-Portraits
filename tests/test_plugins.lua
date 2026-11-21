local BP = newBP({ "api.lua" })
local API = BP.API

eq(API.version, 1, "api version")

local plugin, err = API:NewPlugin("P1", {
	apiVersion = 1,
	defaults = { profile = { enabled = true } },
	options = function()
		return { type = "group", name = "P1", args = {} }
	end,
})
truthy(plugin and not err, "NewPlugin returns plugin")
eq(plugin.name, "P1", "plugin name")
eq(plugin.db.profile.enabled, true, "namespace defaults")
truthy(BP.options.args.plugins_group.args.P1, "plugin options added to the Plugins tab")

eq(select(1, API:NewPlugin("P1", { apiVersion = 1 })), nil, "duplicate rejected")
eq(select(1, API:NewPlugin("P2", { apiVersion = 99 })), nil, "wrong apiVersion rejected")
eq(select(1, API:NewPlugin(nil, { apiVersion = 1 })), nil, "missing name rejected")
eq(#BP.printed, 3, "every rejection warned")

eq(API:GetPlugin("P1"), plugin, "GetPlugin")
eq(API:GetPlugin("P2"), nil, "rejected plugin not stored")

local count = 0
for name, p in API:IteratePlugins() do
	count = count + 1
	eq(p, plugin, "IteratePlugins yields " .. name)
end
eq(count, 1, "IteratePlugins count")

BP.db:SetProfile("other")
eq(plugin.db.profile.enabled, true, "namespace follows profile")

BP:SafeCall(function()
	error("boom")
end)
eq(#reportedErrors, 1, "SafeCall reports the error instead of raising")
eq(
	select(
		1,
		BP:SafeCall(function(a)
			return a + 1
		end, 1)
	),
	2,
	"SafeCall returns results"
)

local BP3 = newBP({ "api.lua" })
BP3.db = nil
eq(select(1, BP3.API:NewPlugin("Early", { apiVersion = 1 })), nil, "registration before the database is rejected")

local hidden = BP.options.args.plugins_group.hidden
local BP2 = newBP({ "api.lua" })
truthy(BP2.options.args.plugins_group.hidden(), "Plugins tab hidden without plugins")
truthy(not hidden(), "Plugins tab shown with a plugin")
