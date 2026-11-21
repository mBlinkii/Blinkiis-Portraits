local BP = newBP({ "api.lua", "portraits/providers.lua" })

ElvUF_Player = {}
SUFUnitplayer = {}
MyUF_Player = {}

setLoadedAddons({ "ElvUI", "ShadowedUnitFrames" })
BP:RefreshProviderAvailability()
eq(BP.ELVUI, true, "builtin flag set from loaded folder")
eq(BP.LoadedAddons.ELVUI, "ElvUI", "loaded folder remembered")
eq(select(2, BP:GetUnitFrames("player", "auto")), "elvui", "auto keeps builtin priority")
eq(select(2, BP:GetUnitFrames("player", "suf")), "suf", "explicit setting wins")
eq(select(1, BP:GetUnitFrames("player", "suf")), "SUFUnitplayer", "frame name as before")

truthy(BP.API:RegisterFrameProvider("myuf", { label = "My UF", addons = { "MyUF" }, units = { player = "MyUF_Player" } }), "plugin provider registered")
eq(BP.API:RegisterFrameProvider("myuf", { label = "x", addons = {}, units = {} }), false, "duplicate provider rejected")
eq(BP.API:RegisterFrameProvider("elvui", { label = "x", addons = {}, units = {} }), false, "builtin id rejected")
eq(BP.API:RegisterFrameProvider("bad", { label = "x", units = {} }), false, "provider without addons rejected")

setLoadedAddons({ "MyUF", "ElvUI" })
BP:RefreshProviderAvailability()
eq(select(2, BP:GetUnitFrames("player", "auto")), "elvui", "builtin before plugin provider")
setLoadedAddons({ "MyUF" })
BP:RefreshProviderAvailability()
eq(select(2, BP:GetUnitFrames("player", "auto")), "myuf", "plugin provider used when alone")
eq(select(2, BP:GetUnitFrames("player", "gone")), "myuf", "unknown saved provider behaves like auto")
eq(BP:GetUnitFrames("target", "auto"), nil, "no provider for the unit")

setLoadedAddons({ "Cell" })
BP:RefreshProviderAvailability()
eq(select(2, BP:GetUnitFrames("party", "cell")), "cell", "cell party via flag Cell")
eq(BP:GetUnitFrames("player", "cell"), nil, "Cell alone has no player frame")
setLoadedAddons({ "Cell", "Cell_UnitFrames" })
BP:RefreshProviderAvailability()
eq(select(1, BP:GetUnitFrames("player", "cell")), "CUF_Player", "Cell_UnitFrames serves the rest under cell")

setLoadedAddons({ "PitBull4" })
BP:RefreshProviderAvailability()
PitBull4 = { db = { profile = { units = { Main = { unit = "player" } }, groups = { Grp = { unit_group = "party" } } } } }
eq(select(1, BP:GetUnitFrames("player", "auto")), "PitBull4_Frames_Main", "pb4 single unit from its profile")
eq(select(1, BP:GetUnitFrames("party", "auto")), "PitBull4_Groups_GrpUnitButton", "pb4 group from its profile")
eq(BP:GetUnitFrames("target", "pb4"), nil, "pb4 gap does not block")

PartyFrame = { MemberFrame2 = "bbf2" }
setLoadedAddons({ "BetterBlizzFrames" })
BP:RefreshProviderAvailability()
eq(BP:ResolveGroupFrame((BP:GetUnitFrames("party", "bbf")), 2), "bbf2", "bbf party through a dot path")

local frames = { "p1", "p2" }
BP.API:RegisterFrameProvider("fnuf", {
	label = "Fn UF",
	addons = { "FnUF" },
	units = {
		player = function()
			return "fnplayer"
		end,
		party = function(index)
			return frames[index]
		end,
	},
	getUnit = function(frame)
		return frame.myUnit
	end,
})
setLoadedAddons({ "FnUF" })
BP:RefreshProviderAvailability()
eq(BP:ResolveFrame((BP:GetUnitFrames("player", "auto"))), "fnplayer", "function unit entry resolves a frame")
eq(BP:ResolveGroupFrame((BP:GetUnitFrames("party", "auto")), 2), "p2", "function group entry receives the index")
eq(BP:GetFrameUnit({ myUnit = "party3" }, "fnuf"), "party3", "provider getUnit wins")
eq(BP:GetFrameUnit({ unit = "player" }, "elvui"), "player", "frame unit fallback unchanged")

local values = BP:GetProviderOptionValues()
eq(values.cell, "Cell", "cell listed once")
eq(values.fnuf, "Fn UF", "plugin provider listed")
truthy(values.auto, "auto listed")
