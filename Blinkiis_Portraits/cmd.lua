local _G = _G
local ReloadUI = ReloadUI
local format = format
local ipairs, pairs = ipairs, pairs
local concat, sort = table.concat, table.sort
local print, select, tostring = print, select, tostring
local strlower, strtrim = strlower, strtrim
local GetBuildInfo, GetLocale, GetInstanceInfo = GetBuildInfo, GetLocale, GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local UnitClass, UnitClassification, UnitExists, UnitGUID = UnitClass, UnitClassification, UnitExists, UnitGUID
local UnitIsDead, UnitIsPlayer, UnitLevel, UnitName, UnitReaction = UnitIsDead, UnitIsPlayer, UnitLevel, UnitName, UnitReaction
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata

local debugUnits = { "player", "target", "targettarget", "pet", "focus", "party", "boss", "arena" }

-- flag on the namespace mapped to the addon folder the version is read from
local unitFrameAddons = {
	{ flag = "ELVUI", name = "ElvUI" },
	{ flag = "SUF", name = "ShadowedUnitFrames" },
	{ flag = "PB4", name = "PitBull4" },
	{ flag = "Cell", name = "Cell" },
	{ flag = "Cell_UF", name = "Cell_UnitFrames" },
	{ flag = "UUF", name = "UnhaltedUnitFrames" },
	{ flag = "NDUI", name = "NDui" },
	{ flag = "EQOL", name = "EnhanceQoL" },
	{ flag = "BBF", name = "BetterBlizzFrames" },
	{ flag = "EUI", name = "EllesmereUI" },
	{ flag = "STUF", name = "Stuf" },
	{ flag = "DF", name = "DandersFrames" },
}

local flavors = { "Retail", "Mists", "Cata", "Wrath", "Classic" }

-- reused so a repeated report does not allocate; GetExtraClassification only reads these fields
local targetProbe = {}

-- Prints which unit frame addon was resolved for every unit type.
local function PrintResolvedUnitFrames()
	BLINKIISPORTRAITS:Print("Resolved unit frames:")

	for _, unit in ipairs(debugUnits) do
		local configured = BLINKIISPORTRAITS.db.profile[unit].unitframe
		local frame, addon = BLINKIISPORTRAITS:GetUnitFrames(unit, configured)

		BLINKIISPORTRAITS:Print(format("  %s | configured: %s | addon: %s | frame: %s", unit, configured, tostring(addon), tostring(frame)))
	end
end

-- Prints parent frame and resolved unit of every active portrait.
-- A missing portrait texture on an otherwise visible frame means the unit could not be resolved.
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
				tostring(unit and UnitExists(unit) or false),
				tostring(portrait:IsShown())
			)
		)
	end
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- API results can be secret values (WoW 12.x), which must not be concatenated
local function Safe(value)
	if BLINKIISPORTRAITS:IsSecretValue(value) then return "secret" end
	return tostring(value)
end

local function GetFlavor()
	for _, flavor in ipairs(flavors) do
		if BLINKIISPORTRAITS[flavor] then return flavor end
	end

	return "unknown"
end

local function GetLoadedUnitFrameAddons()
	local loaded = {}

	for _, addon in ipairs(unitFrameAddons) do
		if BLINKIISPORTRAITS[addon.flag] then loaded[#loaded + 1] = format("%s (%s)", addon.name, tostring(GetAddOnMetadata(addon.name, "Version") or "?")) end
	end

	return loaded[1] and concat(loaded, ", ") or "none"
end

local function GetGroupState()
	if _G.IsInRaid and _G.IsInRaid() then return format("raid (%d)", _G.GetNumGroupMembers()) end
	if _G.IsInGroup and _G.IsInGroup() then return format("party (%d)", _G.GetNumGroupMembers()) end

	return "solo"
end

local function GetInstanceState()
	local name, instanceType, difficultyID, difficultyName = GetInstanceInfo()
	if instanceType == "none" then return "world" end

	return format("%s [%s/%s]", tostring(name), tostring(instanceType), tostring(difficultyName ~= "" and difficultyName or difficultyID))
end

local function AddHeaderLines(lines)
	local version, build, _, tocVersion = GetBuildInfo()
	local profile = BLINKIISPORTRAITS.db.profile
	local misc = profile.misc

	lines[#lines + 1] = format("Addon: %s | WoW: %s.%s (toc %s) | Flavor: %s | Locale: %s", tostring(BLINKIISPORTRAITS.Version), tostring(version), tostring(build), tostring(tocVersion), GetFlavor(), GetLocale())
	lines[#lines + 1] = format(
		"Profile: %s | ElvUI options: %s | Encoding API: %s | Combat: %s",
		tostring(BLINKIISPORTRAITS.db:GetCurrentProfile()),
		YesNo(BLINKIISPORTRAITS.db.global.elvui_options),
		YesNo(_G.C_EncodingUtil ~= nil),
		YesNo(InCombatLockdown())
	)
	lines[#lines + 1] = format("Group: %s | Instance: %s", GetGroupState(), GetInstanceState())
	lines[#lines + 1] = format("Unit frames: %s", GetLoadedUnitFrameAddons())
	lines[#lines + 1] = format(
		"Global: clickable=%s classIcons=%s custom=%s extraOnTop=%s zoom=%s desaturate=%s forceDefault=%s forceReaction=%s",
		YesNo(misc.clickable),
		tostring(misc.class_icon),
		YesNo(profile.custom.enable),
		YesNo(misc.extratop),
		tostring(misc.zoom),
		YesNo(misc.desaturate),
		YesNo(misc.force_default),
		YesNo(misc.force_reaction)
	)
end

-- "model" is the state of the last texture attempt: ok = model was ready, pending = kept the old
-- texture and is retrying, icon = a class icon replaced the unit portrait
local function GetModelState(portrait)
	if portrait.portraitSet == nil then return "icon" end

	return portrait.portraitSet and "ok" or "pending"
end

local function AddPortraitLines(lines)
	local keys = {}
	for key in pairs(BLINKIISPORTRAITS.Portraits) do
		keys[#keys + 1] = key
	end
	sort(keys)

	lines[#lines + 1] = format("Portraits: %d active", #keys)

	for _, key in ipairs(keys) do
		local portrait = BLINKIISPORTRAITS.Portraits[key]
		local parent = portrait.parentFrame
		local unit = portrait.unit

		lines[#lines + 1] = format(
			"  %s | addon=%s parent=%s unit=%s reg=%s exists=%s style=%s size=%s shown=%s visible=%s cast=%s model=%s",
			key,
			tostring(portrait.parentAddon),
			(parent and (parent:GetName() or "unnamed")) or "none",
			tostring(unit),
			tostring(portrait.registeredUnit),
			unit and Safe(UnitExists(unit)) or "false",
			tostring(portrait.db and portrait.db.texture),
			tostring(portrait.db and portrait.db.size),
			YesNo(portrait:IsShown()),
			YesNo(portrait:IsVisible()),
			YesNo(portrait.db and portrait.db.cast),
			GetModelState(portrait)
		)
	end

	local disabled = {}
	for _, unit in ipairs(debugUnits) do
		if not BLINKIISPORTRAITS.db.profile[unit].enable then disabled[#disabled + 1] = unit end
	end

	lines[#lines + 1] = format("Disabled: %s", disabled[1] and concat(disabled, ", ") or "none")
end

local function AddTargetLines(lines)
	if not UnitExists("target") then
		lines[#lines + 1] = "Target: none"
		return
	end

	local guid = UnitGUID("target")
	targetProbe.unit = "target"
	targetProbe.type = "report"
	targetProbe.isPlayer = UnitIsPlayer("target") or false
	targetProbe.lastGUID = BLINKIISPORTRAITS:IsSecretValue(guid) and " " or guid

	lines[#lines + 1] = format(
		'Target: "%s" | player=%s class=%s level=%s classification=%s extra=%s reaction=%s dead=%s vehicle=%s guid=%s',
		Safe(UnitName("target")),
		YesNo(targetProbe.isPlayer),
		tostring(select(2, UnitClass("target")) or "-"),
		Safe(UnitLevel("target")),
		Safe(UnitClassification("target")),
		tostring(BLINKIISPORTRAITS:GetExtraClassification(targetProbe) or "none"),
		Safe(UnitReaction("target", "player")),
		YesNo(UnitIsDead("target")),
		YesNo(_G.UnitInVehicle and _G.UnitInVehicle("target")),
		Safe(guid)
	)
end

--- Collects a diagnostic snapshot of addon, client, unit frame and portrait state.
-- @return a table of report lines
function BLINKIISPORTRAITS:BuildReport()
	local lines = {}

	AddHeaderLines(lines)
	AddPortraitLines(lines)
	AddTargetLines(lines)

	local cachedBossIDs = 0
	for _ in pairs(BLINKIISPORTRAITS.CachedBossIDs) do
		cachedBossIDs = cachedBossIDs + 1
	end
	lines[#lines + 1] = format("Cached boss IDs: %d | Debug log: %s", cachedBossIDs, YesNo(BLINKIISPORTRAITS.DebugEnabled))

	return lines
end

--- Returns the diagnostic report as a single copyable block of text.
function BLINKIISPORTRAITS:GetReportText()
	return concat(BLINKIISPORTRAITS:BuildReport(), "\n")
end

local function PrintReport()
	BLINKIISPORTRAITS:Print("|cff40ff40report|r - the same text sits in the About tab of the options, ready to copy.")

	for _, line in ipairs(BLINKIISPORTRAITS:BuildReport()) do
		print(line)
	end
end

-- Toggles the live event log and reports the new state.
local function ToggleDebugLog()
	BLINKIISPORTRAITS.DebugEnabled = not BLINKIISPORTRAITS.DebugEnabled

	BLINKIISPORTRAITS:Print(BLINKIISPORTRAITS.DebugEnabled and "Debug log |cff40ff40ON|r - run /bp log again to stop." or "Debug log |cffff4040OFF|r.")
end

--- Handles the /bp chat command. Without arguments the options dialog is opened.
-- @param msg "report" prints the diagnostic snapshot, "debug" prints the short frame overview,
--            "log" toggles the live event log
function BLINKIISPORTRAITS:CMD(msg)
	local command = strlower(strtrim(msg or ""))

	if command == "report" then
		PrintReport()
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

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end
