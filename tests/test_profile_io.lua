local BP = newBP({ "api.lua", "profile_io.lua" })
BP.defaults = { profile = { player = { texture = "blizz", size = 80 }, misc = { zoom = 0 } } }
BP.Version = "1.64"

local plugin = BP.API:NewPlugin("P1", { apiVersion = 1, defaults = { profile = { marker = 0 } } })
plugin.db.profile.marker = 42

local data = BP:BuildExportData({ author = "A", name = "X", version = "2" })
eq(data.name, "X", "export keeps meta")
eq(data.bp_version, "1.64", "export stamps the BP version")
truthy(data.profile == BP.db.profile, "export carries the BP profile")
eq(data.plugins.P1.marker, 42, "export carries loaded plugin settings")

local BP2 = newBP({ "api.lua", "profile_io.lua" })
eq(BP2:BuildExportData({ name = "X" }).plugins, nil, "no plugins, no plugins field")

data.plugins.NotLoaded = { x = 1 }
local skipped = BP:ApplyImport("Imported", data)
eq(#skipped, 1, "one plugin skipped")
eq(skipped[1], "NotLoaded", "unloaded plugin named")
eq(BP.db.sv.namespaces and BP.db.sv.namespaces.NotLoaded, nil, "skipped settings not stored")
eq(BP.db:GetCurrentProfile(), "Imported", "import switches to the new profile")
eq(plugin.db.profile.marker, 42, "plugin settings imported into the new profile")

local legacy = dofile("tests/fixtures/legacy_export.lua")
eq(#BP:ApplyImport("Legacy", legacy), 0, "legacy data imports without skipped plugins")
eq(BP.db.profile.player.texture, "antik", "legacy profile values imported")
eq(BP.db.profile.player.size, 90, "legacy profile values kept")
eq(plugin.db.profile.marker, 0, "plugin keeps its defaults when the import has none")

BP.db:SetProfile("Copy")
BP.db:CopyProfile("Imported")
eq(plugin.db.profile.marker, 42, "copy profile carries plugin settings")

BP.db:SetProfile("Imported")
plugin.db.profile.marker = 7
local again = BP:BuildExportData({ name = "Imported" })
BP:ApplyImport("Imported", again)
eq(plugin.db.profile.marker, 7, "reimport over an existing profile keeps values")

local active = { profile = { player = { size = 55 } } }
BP.db.profile.player.size = 10
BP:ApplyImport("Imported", active)
eq(BP.db.profile.player.size, 55, "import over the active BP profile takes effect")
