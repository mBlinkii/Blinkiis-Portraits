local _G = _G
local ReloadUI = ReloadUI
local format = format
local ipairs, pairs = ipairs, pairs
local sort = table.sort
local tostring = tostring
local strlower, strtrim = strlower, strtrim
local UnitExists = UnitExists

local debugUnits = { "player", "target", "targettarget", "pet", "focus", "party", "boss", "arena" }

local function PrintResolvedUnitFrames()
	BLINKIISPORTRAITS:Print("Resolved unit frames:")

	for _, unit in ipairs(debugUnits) do
		local configured = BLINKIISPORTRAITS.db.profile[unit].unitframe
		local frame, addon = BLINKIISPORTRAITS:GetUnitFrames(unit, configured)

		BLINKIISPORTRAITS:Print(format("  %s | configured: %s | addon: %s | frame: %s", unit, configured, tostring(addon), tostring(frame)))
	end
end

local function PrintPortraitState()
	local keys = {}
	for key in pairs(BLINKIISPORTRAITS.Portraits) do
		keys[#keys + 1] = key
	end
	sort(keys)

	BLINKIISPORTRAITS:Print(format("Active portraits: %d", #keys))

	for _, key in ipairs(keys) do
		local portrait = BLINKIISPORTRAITS.Portraits[key]
		local parent = portrait.parentFrame
		local unit = portrait.unit

		BLINKIISPORTRAITS:Print(
			format(
				"  %s | parent: %s | unit: %s | exists: %s | shown: %s",
				key,
				(parent and (parent:GetName() or "unnamed")) or "none",
				tostring(unit),
				tostring(unit and BLINKIISPORTRAITS:SafeValue(UnitExists(unit)) or false),
				tostring(portrait:IsShown())
			)
		)
	end
end

local function ToggleDebugLog()
	BLINKIISPORTRAITS.DebugEnabled = not BLINKIISPORTRAITS.DebugEnabled

	BLINKIISPORTRAITS:Print(BLINKIISPORTRAITS.DebugEnabled and "Debug log |cff40ff40ON|r - run /bp log again to stop." or "Debug log |cffff4040OFF|r.")
end

function BLINKIISPORTRAITS:CMD(msg)
	local command = strlower(strtrim(msg or ""))

	if command == "report" then
		BLINKIISPORTRAITS:ShowReport()
	elseif command == "debug" then
		PrintResolvedUnitFrames()
		PrintPortraitState()
	elseif command == "log" then
		ToggleDebugLog()
	else
		LibStub("AceConfigDialog-3.0"):Open("BLINKIISPORTRAITS")
	end
end

BLINKIISPORTRAITS:RegisterChatCommand("bp", "CMD")

if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end
