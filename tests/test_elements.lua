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
