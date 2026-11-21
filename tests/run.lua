local root = (arg and arg[0] or ""):match("^(.-)tests[/\\]run%.lua$") or ""

local passed, failed = 0, 0

local function listTests()
	local files = {}
	local pipe = io.popen("dir /b \"" .. (root ~= "" and root or ".\\") .. "tests\\test_*.lua\" 2>nul")
	if pipe then
		for name in pipe:lines() do
			files[#files + 1] = name
		end
		pipe:close()
	end
	table.sort(files)
	return files
end

local function newEnv()
	local env = setmetatable({}, { __index = _G })
	env._G = env

	local function report(ok, label, detail)
		if ok then
			passed = passed + 1
			print("  ok    " .. label)
		else
			failed = failed + 1
			print("  FAIL  " .. label .. (detail and ("  (" .. detail .. ")") or ""))
		end
	end

	function env.eq(actual, expected, label)
		report(actual == expected, label, actual ~= expected and ("expected " .. tostring(expected) .. ", got " .. tostring(actual)) or nil)
	end

	function env.truthy(value, label)
		report(value and true or false, label)
	end

	function env.errors(fn, label)
		report(not pcall(fn), label, "did not raise")
	end

	local stubs = assert(loadfile(root .. "tests/wow_stubs.lua"))
	stubs(env)
	local bp = assert(loadfile(root .. "tests/bp_env.lua"))
	bp(env, root)

	return env, report
end

for _, name in ipairs(listTests()) do
	print(name)
	local env, report = newEnv()
	local chunk, err = loadfile(root .. "tests/" .. name)
	if not chunk then
		report(false, "load", err)
	else
		setfenv(chunk, env)
		local ok, runErr = pcall(chunk)
		if not ok then report(false, "runs without error", tostring(runErr)) end
	end
end

print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
