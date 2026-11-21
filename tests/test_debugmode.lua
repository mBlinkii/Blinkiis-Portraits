local BP = newBP({ "api.lua", "portraits/providers.lua", "debugmode.lua" })

local function list()
	return {
		{ name = "Blinkiis_Portraits", enabled = true },
		{ name = "BugSack", enabled = true },
		{ name = "!BugGrabber", enabled = true },
		{ name = "ElvUI", enabled = true, deps = { "ElvUI_Libraries" } },
		{ name = "ElvUI_Libraries", enabled = true },
		{ name = "ElvUI_Options", enabled = true, lod = true, deps = { "ElvUI" } },
		{ name = "ElvUI_MerathilisUI", enabled = true, deps = { "ElvUI" } },
		{ name = "BP_ExamplePlugin", enabled = true, deps = { "Blinkiis_Portraits" } },
		{ name = "BP_LodPlugin", enabled = true, lod = true, deps = { "Blinkiis_Portraits" } },
		{ name = "Details", enabled = true },
		{ name = "Cell", enabled = false },
		{ name = "CycleA", enabled = true, deps = { "CycleB" } },
		{ name = "CycleB", enabled = true, deps = { "CycleA" } },
	}
end

setAddOnList(list())
local keep = BP:GetDebugModeKeepSet("Blinkiis_Portraits")
for _, name in ipairs({ "Blinkiis_Portraits", "BugSack", "!BugGrabber", "ElvUI", "ElvUI_Libraries", "ElvUI_Options" }) do
	truthy(keep[name], "keeps " .. name)
end
for _, name in ipairs({ "ElvUI_MerathilisUI", "BP_ExamplePlugin", "BP_LodPlugin", "Details", "Cell", "CycleA" }) do
	eq(keep[name], nil, "does not keep " .. name)
end

eq(BP:IsDebugModeActive(), false, "inactive at start")
local disabled = BP:EnableDebugMode("Blinkiis_Portraits")
eq(disabled, 6, "turns off every other enabled addon")
eq(isAddOnEnabled("Details"), false, "Details turned off")
eq(isAddOnEnabled("ElvUI"), true, "ElvUI stays on")
eq(isAddOnEnabled("Cell"), false, "a disabled supported addon stays off")
eq(BP:IsDebugModeActive(), true, "active after enabling")

local saved = #BP.db.char.debugMode.disabled
eq(BP:EnableDebugMode("Blinkiis_Portraits"), 0, "a second enable turns nothing off")
eq(#BP.db.char.debugMode.disabled, saved, "a second enable keeps the saved list")

local current = list()
for i = #current, 1, -1 do
	if current[i].name == "Details" then table.remove(current, i) end
end
for _, addon in ipairs(current) do
	if not ({ ["Blinkiis_Portraits"] = 1, BugSack = 1, ["!BugGrabber"] = 1, ElvUI = 1, ElvUI_Libraries = 1, ElvUI_Options = 1 })[addon.name] then addon.enabled = false end
end
setAddOnList(current)
eq(BP:DisableDebugMode(), 5, "restores the saved addons that still exist")
eq(isAddOnEnabled("ElvUI_MerathilisUI"), true, "plugin of ElvUI back on")
eq(isAddOnEnabled("Cell"), false, "an addon that was off stays off")
eq(BP:IsDebugModeActive(), false, "inactive after restoring")
eq(BP:DisableDebugMode(), nil, "restoring twice does nothing")
