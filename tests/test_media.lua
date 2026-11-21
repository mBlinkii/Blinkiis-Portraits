local BP = newBP({ "api.lua" })
BP.media = { portraits = { antik = { texture = "a", mask = "m" } }, class = { blizzard = { name = "Blizzard", texture = "c", texCoords = {} } }, spec = {} }

local refreshes = 0
BP.LoadPortraits = function()
	refreshes = refreshes + 1
end

truthy(BP.API:RegisterStyle("s1", { name = "S1", texture = "t", mask = "m" }), "style registered")
eq(BP.media.portraits.s1.texture, "t", "style lands in media")
eq(BP:GetRegisteredStyles().s1.name, "S1", "style listed for the options")
eq(BP.API:RegisterStyle("antik", { name = "x", texture = "t", mask = "m" }), false, "builtin style id rejected")
eq(BP.API:RegisterStyle("s2", { name = "S2", texture = "t" }), false, "style without mask rejected")
eq(BP.API:RegisterStyle("s3", { texture = "t", mask = "m" }), false, "style without name rejected")

truthy(BP.API:RegisterClassIconSet("c1", { name = "C1", texture = "t", texCoords = { WARRIOR = { 0, 0, 0, 1, 1, 0, 1, 1 } } }), "class set registered")
eq(BP.media.class.c1.name, "C1", "class set lands in media")
eq(BP.API:RegisterClassIconSet("blizzard", { name = "x", texture = "t", texCoords = {} }), false, "builtin class set id rejected")
eq(BP.API:RegisterClassIconSet("c2", { name = "C2", texture = "t" }), false, "class set without coords rejected")

BP.SpecIconsSupported = false
eq(BP.API:RegisterSpecIconSet("sp", { name = "Sp", texture = "t", texCoords = {} }), false, "spec sets need spec support")
BP.SpecIconsSupported = true
truthy(BP.API:RegisterSpecIconSet("sp", { name = "Sp", texture = "t", texCoords = {} }), "spec set registered with support")

flushTimers()
eq(refreshes, 0, "registrations before the first load do not refresh")

BP:Fire("PortraitsLoaded")
BP.API:RegisterStyle("s4", { name = "S4", texture = "t", mask = "m" })
BP.API:RegisterStyle("s5", { name = "S5", texture = "t", mask = "m" })
flushTimers()
eq(refreshes, 1, "late registrations refresh once")

setCombat(true)
truthy(BP.API:RegisterStyle("s6", { name = "S6", texture = "t", mask = "m" }), "registration works in combat")
setCombat(false)

eq(select(2, BP:ResolveStyle("missing", "antik")), "antik", "unknown style falls back to default")
eq(select(1, BP:ResolveStyle("missing", "antik")).texture, "a", "fallback returns the default style table")
eq(select(2, BP:ResolveStyle("s1", "antik")), "s1", "registered style resolves")

BP.API:Refresh()
eq(refreshes, 2, "Refresh reloads the portraits")
