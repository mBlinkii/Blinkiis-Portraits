local _, ns = ...

local Check = ns.Check
local API = BLINKIISPORTRAITS and BLINKIISPORTRAITS.API

Check("API exists", type(API) == "table")
Check("API version 1", API and API.version == 1)
if not API then return end

local function BuildOptions()
	return {
		type = "group",
		name = "Example",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = "Enable example elements",
				get = function()
					return ns.plugin.db.profile.enabled
				end,
				set = function(_, value)
					ns.plugin.db.profile.enabled = value
					if API.Refresh then API:Refresh() end
				end,
			},
		},
	}
end

local plugin = API:NewPlugin("BP_ExamplePlugin", { apiVersion = 1, defaults = { profile = { enabled = true } }, options = BuildOptions })
Check("NewPlugin returns plugin", plugin ~= nil)
ns.plugin = plugin

local playerFrame = CreateFrame("Frame", "BPEX_PlayerFrame", UIParent, "BackdropTemplate")
playerFrame:SetSize(100, 40)
playerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
playerFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
playerFrame:SetBackdropColor(0, 0, 0, 0.5)
playerFrame.unit = "player"

local registered = API:RegisterFrameProvider("bpex", { label = "BP Example", addons = { "BP_ExamplePlugin" }, units = { player = "BPEX_PlayerFrame" } })
Check("provider registered", registered == true)
Check("duplicate provider rejected", API:RegisterFrameProvider("bpex", { label = "x", addons = {}, units = {} }) == false)

ns.Later(function()
	local portrait
	for key, p in API:GetPortraits() do
		if key == "player" then portrait = p end
	end
	print("BP_ExamplePlugin: player portrait parent is " .. tostring(portrait and portrait.parentFrame and portrait.parentFrame:GetName()))
end)

local MEDIA = "Interface\\Addons\\Blinkiis_Portraits\\media\\"
Check("style registered", API:RegisterStyle("bpex_round", { name = "BPEX Round", texture = MEDIA .. "circle.tga", mask = MEDIA .. "circle_mask.tga" }) == true)
Check("builtin style id rejected", API:RegisterStyle("antik", { name = "x", texture = "x", mask = "x" }) == false)
Check("class icon set registered", API:RegisterClassIconSet("bpex_icons", {
	name = "BPEX Icons",
	texture = "Interface\\WorldStateFrame\\Icons-Classes",
	texCoords = CLASS_ICON_TCOORDS,
}) == true)

local seen = {}
local function Remember(event, portrait)
	seen[event] = portrait or true
end
for _, event in ipairs({ "PortraitCreated", "PortraitSetup", "PortraitUnitChanged", "PortraitUpdated", "PortraitsLoaded" }) do
	API.RegisterCallback(seen, event, Remember)
end
API.RegisterCallback(seen, "ProfileChanged", function()
	print("BP_ExamplePlugin: ProfileChanged")
end)

ns.Later(function()
	local setup = seen.PortraitSetup
	Check("PortraitSetup fired", setup ~= nil)
	Check("PortraitsLoaded fired", seen.PortraitsLoaded == true)
	Check("PortraitUpdated fired", seen.PortraitUpdated ~= nil)
	Check("PortraitUnitChanged fired", seen.PortraitUnitChanged ~= nil)
	Check("portrait.key set", type(setup) == "table" and setup.key ~= nil)
	Check("portrait.plugins table", type(setup) == "table" and type(setup.plugins) == "table")
	local count = 0
	for _ in API:GetPortraits() do
		count = count + 1
	end
	Check("GetPortraits iterates", count > 0)
end)
