local BLINKIISPORTRAITS = BLINKIISPORTRAITS

local pairs = pairs
local rawset = rawset
local sort = table.sort
local type = type

local function CopyTable(src, dest)
	if type(dest) ~= "table" then dest = {} end
	if type(src) == "table" then
		for k, v in pairs(src) do
			if type(v) == "table" then
				-- index the key first so the metatable creates the defaults
				v = CopyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest
end

BLINKIISPORTRAITS.CopyProfileTable = CopyTable

function BLINKIISPORTRAITS:BuildExportData(meta)
	local data = {
		author = meta.author,
		name = meta.name,
		version = meta.version,
		bp_version = BLINKIISPORTRAITS.Version,
		profile = BLINKIISPORTRAITS.db.profile,
	}

	for name, plugin in BLINKIISPORTRAITS.API:IteratePlugins() do
		data.plugins = data.plugins or {}
		data.plugins[name] = plugin.db.profile
	end

	return data
end

-- AceDB ignores SetProfile on the active profile, so its cached profile has to be dropped by hand
local function ResetCachedProfile(db)
	rawset(db, "profile", nil)
end

function BLINKIISPORTRAITS:ApplyImport(name, data)
	local db = BLINKIISPORTRAITS.db
	local isActive = db:GetCurrentProfile() == name

	db.profiles[name] = CopyTable(data.profile, CopyTable(BLINKIISPORTRAITS.defaults.profile))

	local skipped = {}
	for pluginName, values in pairs(data.plugins or {}) do
		local plugin = BLINKIISPORTRAITS.API:GetPlugin(pluginName)
		if plugin then
			plugin.db.profiles[name] = CopyTable(values)
			if isActive then ResetCachedProfile(plugin.db) end
		else
			skipped[#skipped + 1] = pluginName
		end
	end
	sort(skipped)

	-- a plugin missing from the import starts the profile from its defaults
	for _, plugin in BLINKIISPORTRAITS.API:IteratePlugins() do
		if not (data.plugins and data.plugins[plugin.name]) then
			plugin.db.profiles[name] = nil
			if isActive then ResetCachedProfile(plugin.db) end
		end
	end

	if isActive then
		ResetCachedProfile(db)
		db.callbacks:Fire("OnProfileChanged", db, name)
	else
		db:SetProfile(name)
	end

	return skipped
end
