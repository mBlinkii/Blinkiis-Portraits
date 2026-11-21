local BP = newBP({ "api.lua", "portraits/providers.lua", "debugmode.lua", "status.lua" })

local function find(rows, label)
	for _, row in ipairs(rows) do
		if row.label == label then return row end
	end
end

BP.defaults = { profile = { misc = { zoom = 0, class_icon = "none", desaturate = false }, custom = { enable = false } } }
BP.db.profile.misc = { zoom = 0.1, class_icon = "none", desaturate = false }
BP.db.profile.custom = { enable = true }

local changed = BP:GetChangedSettings()
eq(#changed, 2, "only settings that differ from the defaults")
eq(find(changed, "Zoom").value, "0.1", "changed zoom listed with its value")
eq(find(changed, "Custom Textures").value, "yes", "custom textures listed")
eq(find(changed, "Class Icons"), nil, "default class icons not listed")

for _, unit in ipairs({ "player", "target", "focus", "targettarget", "pet", "party", "boss", "arena" }) do
	BP.db.profile[unit] = { enable = true }
end
BP.db.profile.focus.enable = false
BP.Portraits = {
	player = { parentFrame = {} },
	party1 = { parentFrame = {} },
	party2 = { parentFrame = {} },
	partyself = { parentFrame = {} },
}

local summary = BP:GetPortraitSummary()
eq(find(summary, "Player").value, "ok", "attached single portrait is ok")
eq(find(summary, "Target").value, "missing", "enabled portrait without frame is missing")
truthy(find(summary, "Target").warn, "missing is a warning")
eq(find(summary, "Focus").value, "off", "disabled portrait is off")
truthy(find(summary, "Focus").muted, "off is muted")
eq(find(summary, "Party").value, "2/5", "party counts party1-5 only")
eq(find(summary, "Boss").value, "0/5", "no boss portraits")
eq(find(summary, "Boss").warn, nil, "an empty group is not a warning")

eq(#BP:GetPluginStatusRows(), 0, "no plugins, no rows")
setAddOnMetadata("P1", "Version", "1.2")
BP.API:NewPlugin("P1", { apiVersion = 1 })
BP.API:NewPlugin("P2", { apiVersion = 1 })
BP.API:RegisterFrameProvider("myuf", { label = "My UF", addons = { "MyUF" }, units = {} })
BP.API:RegisterStyle("st", { name = "Plugin Style", texture = "t", mask = "m" })
local plugins = BP:GetPluginStatusRows()
eq(find(plugins, "P1").value, "1.2", "plugin version from its TOC")
eq(find(plugins, "P2").value, "?", "plugin without version")
eq(find(plugins, "Provider").value, "My UF", "plugin providers listed")
eq(find(plugins, "Style").value, "Plugin Style", "plugin styles listed")

BP.Version = "1.64"
local text = BP:GetStatusText()
truthy(text:find("Zoom: 0.1", 1, true), "copy text contains changed settings")
truthy(text:find("P1: 1.2", 1, true), "copy text contains plugins")
