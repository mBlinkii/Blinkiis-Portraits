local _G = _G
local LibStub = LibStub
local pairs = pairs

local addonName = ...

local ELVUI_OPTIONS_KEY = "blinkiis_portraits"
local ELVUI_OPTIONS_ORDER = 100

local isOptionsInserted = false

-- ElvUI writes key and func onto every group it lists in its left menu, and AceConfigRegistry
-- rejects key. Its own root table takes those writes, args stays the shared one.
local function BuildElvUIOptions()
	local options = {}
	for key, value in pairs(BLINKIISPORTRAITS.options) do
		options[key] = value
	end

	options.order = ELVUI_OPTIONS_ORDER

	return options
end

-- ElvUI keeps its options in the on demand addon ElvUI_Options, LibElvUIPlugin fires this once it is loaded
local function InsertOptions()
	if isOptionsInserted then return end

	local E = _G.ElvUI and _G.ElvUI[1]
	if not (E and E.Options and E.Options.args) then return end

	E.Options.args[ELVUI_OPTIONS_KEY] = BuildElvUIOptions()
	isOptionsInserted = true
end

-- The args table is shared with the standalone AceConfig registration, so both dialogs stay in sync
function BLINKIISPORTRAITS:SetupElvUIOptions()
	if not BLINKIISPORTRAITS.ELVUI then return end
	if not BLINKIISPORTRAITS.db.global.elvui_options then return end

	local EP = LibStub("LibElvUIPlugin-1.0", true)
	if not EP then return end

	EP:RegisterPlugin(addonName, InsertOptions)
end
