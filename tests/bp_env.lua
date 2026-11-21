local env, root = ...

local ADDON = root .. "Blinkiis_Portraits/"
local LIBS = { "libs/LibStub/LibStub.lua", "libs/CallbackHandler-1.0/CallbackHandler-1.0.lua", "libs/AceDB-3.0/AceDB-3.0.lua", "libs/AceLocale-3.0/AceLocale-3.0.lua", "Locales/enUS.lua" }

local function loadInto(path, ...)
	local chunk, err = loadfile(path)
	if not chunk then error(err, 2) end
	setfenv(chunk, env)
	return chunk(...)
end

env.loadInto = loadInto

local libsLoaded = false

local function ensureLibs()
	if libsLoaded then return end
	for _, lib in ipairs(LIBS) do
		local file = io.open(ADDON .. lib, "r")
		if not file then error("missing " .. lib .. " - fetch the Ace3 libraries as described in Blinkiis_Portraits/libs/README.md", 0) end
		file:close()
		loadInto(ADDON .. lib, "Blinkiis_Portraits", {})
	end
	libsLoaded = true
end

function env.newBP(files)
	ensureLibs()

	local BP = { printed = {}, Portraits = {}, media = { portraits = {}, class = {}, spec = {} } }
	BP.options = { args = { plugins_group = { args = {} } } }

	function BP:Print(...)
		local parts = {}
		for i = 1, select("#", ...) do
			parts[#parts + 1] = tostring((select(i, ...)))
		end
		self.printed[#self.printed + 1] = table.concat(parts, " ")
	end

	env.BLINKIISPORTRAITS = BP
	env.BlinkiisPortraitsDB = {}
	BP.db = env.LibStub("AceDB-3.0"):New("BlinkiisPortraitsDB", { profile = {} }, true)

	for _, file in ipairs(files or {}) do
		loadInto(ADDON .. file, "Blinkiis_Portraits", {})
	end

	return BP
end
