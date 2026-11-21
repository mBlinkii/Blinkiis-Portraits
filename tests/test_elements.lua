local BP = newBP({ "api.lua", "portraits/elements.lua" })

local order = {}
local function Log(entry)
	order[#order + 1] = entry
end

BP:DefineElement("E", {
	Update = function(element, portrait, event, unit)
		element.seen = unit
		Log("update")
		return 7, "x"
	end,
})

local portrait = { unit = "player" }
eq(BP:RunElement(portrait, "E", "Test", "player"), 7, "runner returns the element result without hooks")
eq(portrait.elements.E.seen, "player", "element state is kept per portrait")
eq(table.concat(order, ","), "update", "plain update without hooks")

order = {}
truthy(
	BP:HookElementInternal("A", "E", {
		PreUpdate = function()
			Log("pre")
		end,
		PostUpdate = function(_, _, _, a, b)
			Log("post" .. a .. b)
		end,
	}),
	"hook accepted"
)
BP.API:UpdateElement(portrait, "E")
eq(table.concat(order, ","), "pre,update,post7x", "pre, update, post with all results")

eq(BP:HookElementInternal("A", "Missing", { PostUpdate = noop }), false, "unknown element rejected")

order = {}
truthy(
	BP:HookElementInternal("A", "E", {
		Override = function()
			Log("override")
			return 1, "o"
		end,
	}),
	"first override accepted"
)
eq(BP:HookElementInternal("B", "E", { Override = noop }), false, "second override rejected")
local warning = BP.printed[#BP.printed] or ""
truthy(warning:find("A", 1, true) and warning:find("B", 1, true), "warning names both plugins")
BP.API:UpdateElement(portrait, "E")
eq(table.concat(order, ","), "pre,override,post1o", "override replaces update and feeds post")

local after = false
BP:HookElementInternal("C", "E", {
	PostUpdate = function()
		error("boom")
	end,
})
BP:HookElementInternal("D", "E", {
	PostUpdate = function()
		after = true
	end,
})
local errorsBefore = #reportedErrors
BP.API:UpdateElement(portrait, "E")
truthy(after, "failing hook does not stop later hooks")
eq(#reportedErrors, errorsBefore + 1, "failing hook is reported")

BP:DefineElement("Plain", {
	Update = function()
		return true
	end,
})
eq(BP:RunElement({}, "Missing", "Test"), nil, "running an unknown element is a no-op")
eq(BP:RunElement({}, "Plain", "Test"), true, "elements without hooks stay independent")

local BP2 = newBP({ "api.lua", "portraits/elements.lua" })
BP2:DefineElement("Color", {
	Update = function()
		return { r = 0 }
	end,
})
BP2:DefineElement("Extra", {
	Update = function(_, portrait)
		return portrait.elements.Color.result
	end,
})
local p2 = {}
BP2:RunElement(p2, "Color", "Test", "target")
eq(p2.elements.Color.result.r, 0, "first result kept as element.result")
BP2:HookElementInternal("Red", "Color", {
	Override = function()
		return { r = 1 }
	end,
})
BP2:RunElement(p2, "Color", "Test", "target")
eq(BP2:RunElement(p2, "Extra", "Test", "target").r, 1, "a later element sees the overridden result")

local BP3 = newBP({ "api.lua", "portraits/elements.lua" })
BP3:DefineElement("Color", { Update = noop })
BP3:DefineElement("Ring", { Update = noop })
local plugin = BP3.API:NewPlugin("P", { apiVersion = 1 })
local always = function()
	return true
end

truthy(BP3.API:RegisterElement(plugin, "X", { events = { "UNIT_HEALTH" }, Enable = always, Update = noop }), "element registered")
eq(BP3.API:RegisterElement(plugin, "Ring", { Enable = always, Update = noop }), false, "builtin name rejected")
eq(BP3.API:RegisterElement(plugin, "X", { Enable = always, Update = noop }), false, "duplicate name rejected")
eq(BP3.API:RegisterElement(plugin, "NoEnable", { Update = noop }), false, "element without Enable rejected")
eq(BP3.API:RegisterElement({ name = "Fake" }, "Y", { Enable = always, Update = noop }), false, "unregistered plugin rejected")
truthy(BP3.API:HookElement(plugin, "Color", { events = { "UNIT_HEALTH", "UNIT_POWER_UPDATE" }, PostUpdate = noop }), "hook with events accepted")
eq(BP3.API:HookElement({ name = "Fake" }, "Color", { PostUpdate = noop }), false, "hook from an unregistered plugin rejected")

local p3 = { unit = "player" }
BP3:BuildElementRouting(p3)
eq(table.concat(p3.elementEvents.UNIT_HEALTH, ","), "Color,X", "UNIT_HEALTH routes to both elements, sorted by name")
eq(#p3.elementEvents.UNIT_POWER_UPDATE, 1, "hook events routed")
eq(#p3.elementEventList, 2, "each routed event listed once for registration")

local enabled = true
local disabledCalls = 0
BP3.API:RegisterElement(plugin, "Z", {
	events = { "UNIT_AURA" },
	Enable = function()
		return enabled
	end,
	Disable = function()
		disabledCalls = disabledCalls + 1
	end,
	Update = noop,
})
BP3:BuildElementRouting(p3)
truthy(p3.elementEvents.UNIT_AURA, "enabled element routes its events")
enabled = false
BP3:BuildElementRouting(p3)
eq(p3.elementEvents.UNIT_AURA, nil, "disabled element routes nothing")
eq(disabledCalls, 1, "Disable runs when an element turns off")
BP3:BuildElementRouting(p3)
eq(disabledCalls, 1, "Disable runs only on the change")
