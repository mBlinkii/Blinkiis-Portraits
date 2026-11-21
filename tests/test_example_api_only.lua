local STABLE_FIELDS = {}
for field in ("unit type key db isPlayer isDead isSecret unitClass parentFrame parentAddon texture portrait mask bg extra ring plugins elements"):gmatch("%S+") do
	STABLE_FIELDS[field] = true
end

local files = {}
local pipe = io.popen("dir /b \"examples\\BP_ExamplePlugin\\*.lua\" 2>nul")
for name in pipe:lines() do
	files[#files + 1] = name
end
pipe:close()
truthy(#files > 0, "example plugin files found")

for _, name in ipairs(files) do
	local file = io.open("examples/BP_ExamplePlugin/" .. name, "r")
	local source = file:read("*a")
	file:close()

	local internal = {}
	for rest in source:gmatch("BLINKIISPORTRAITS([%.:]?[%w_]*)") do
		if rest ~= ".API" and rest ~= "" then internal[#internal + 1] = rest end
	end
	eq(table.concat(internal, " "), "", name .. " uses only BLINKIISPORTRAITS.API")

	local fields = {}
	for field in source:gmatch("portrait%.([%a_]+)") do
		if not STABLE_FIELDS[field] then fields[#fields + 1] = field end
	end
	eq(table.concat(fields, " "), "", name .. " reads only stable portrait fields")
end
