local _, ns = ...

local results = {}
local deferred = {}

function ns.Check(label, condition)
	results[#results + 1] = { label = label, ok = condition and true or false }
end

-- checks that need the world loaded run on /bpex test
function ns.Later(fn)
	deferred[#deferred + 1] = fn
end

local function RunChecks()
	local fromLoad = #results
	for _, fn in ipairs(deferred) do
		fn()
	end

	local passed, failed = 0, {}
	for _, result in ipairs(results) do
		if result.ok then
			passed = passed + 1
		else
			failed[#failed + 1] = result.label
		end
	end

	print(format("BP_ExamplePlugin: %d/%d checks passed", passed, #results))
	for _, label in ipairs(failed) do
		print("  FAIL " .. label)
	end

	for i = #results, fromLoad + 1, -1 do
		results[i] = nil
	end
end

SLASH_BPEXAMPLE1 = "/bpex"
SlashCmdList.BPEXAMPLE = function(msg)
	if strtrim(msg or "") == "test" then RunChecks() end
end
