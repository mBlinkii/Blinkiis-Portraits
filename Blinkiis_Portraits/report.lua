local _G = _G
local CreateFrame = CreateFrame
local UIParent = UIParent
local format = format
local ipairs, pairs = ipairs, pairs
local concat, sort = table.concat, table.sort
local select, tostring = select, tostring
local max, min = math.max, math.min
local GetBuildInfo, GetLocale, GetInstanceInfo = GetBuildInfo, GetLocale, GetInstanceInfo
local InCombatLockdown = InCombatLockdown
local UnitClass, UnitClassification, UnitExists, UnitGUID = UnitClass, UnitClassification, UnitExists, UnitGUID
local UnitIsDead, UnitIsPlayer, UnitLevel, UnitName, UnitReaction = UnitIsDead, UnitIsPlayer, UnitLevel, UnitName, UnitReaction
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata

local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local WINDOW_WIDTH = 560
local TOP_INSET, BOTTOM_INSET = 34, 38
local MIN_WINDOW_HEIGHT, MAX_HEIGHT_RATIO = 220, 0.92
local ROW_HEIGHT, SECTION_GAP, PADDING = 15, 10, 12
local LABEL_WIDTH = 170
local HEADING_COLOR = "|cff00c6ff"

local VALUE_COLOR = { r = 0.35, g = 0.9, b = 0.45 }
local WARN_COLOR = { r = 1, g = 0.4, b = 0.4 }

local reportUnits = { "player", "target", "targettarget", "pet", "focus", "party", "boss", "arena" }

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

local function YesNo(value)
	return value and "yes" or "no"
end

-- API results can be secret values (WoW 12.x), which must not be concatenated
local function Safe(value)
	if BLINKIISPORTRAITS:IsSecretValue(value) then return "secret" end

	return tostring(value)
end

local function AddRow(rows, label, value, warn)
	rows[#rows + 1] = { label = label, value = value, warn = warn }
end

local function GetFlavor()
	for _, flavor in ipairs(flavors) do
		if BLINKIISPORTRAITS[flavor] then return flavor end
	end

	return "unknown"
end

local function GetGroupState()
	if _G.IsInRaid and _G.IsInRaid() then return format("raid (%d)", _G.GetNumGroupMembers()) end
	if _G.IsInGroup and _G.IsInGroup() then return format("party (%d)", _G.GetNumGroupMembers()) end

	return "solo"
end

local function GetInstanceState()
	local name, instanceType, difficultyID, difficultyName = GetInstanceInfo()
	if instanceType == "none" then return "world" end

	return format("%s [%s/%s]", tostring(name), tostring(instanceType), tostring((difficultyName and difficultyName ~= "") and difficultyName or difficultyID))
end

local function CountBossIDs()
	local count = 0
	for _ in pairs(BLINKIISPORTRAITS.CachedBossIDs) do
		count = count + 1
	end

	return count
end

-- "ok" = the model was ready, "pending" = the old texture was kept and a retry is running,
-- "icon" = a class icon replaced the unit portrait
local function GetModelState(portrait)
	if portrait.portraitSet == nil then return "icon" end

	return portrait.portraitSet and "ok" or "pending"
end

local function BuildAddonSection()
	local rows = {}
	local hasEncoding = _G.C_EncodingUtil ~= nil

	AddRow(rows, "Version", tostring(BLINKIISPORTRAITS.Version))
	AddRow(rows, "Profile", tostring(BLINKIISPORTRAITS.db:GetCurrentProfile()))
	AddRow(rows, "ElvUI Options", YesNo(BLINKIISPORTRAITS.db.global.elvui_options))
	AddRow(rows, "Import/Export API", YesNo(hasEncoding), not hasEncoding)
	AddRow(rows, "Debug Log", YesNo(BLINKIISPORTRAITS.DebugEnabled))
	AddRow(rows, "JiberishIcons", YesNo(BLINKIISPORTRAITS.JI))
	AddRow(rows, "Cached Boss IDs", tostring(CountBossIDs()))

	return { title = "AddOn Info", rows = rows }
end

local function BuildClientSection()
	local rows = {}
	local version, build, _, tocVersion = GetBuildInfo()

	AddRow(rows, "Version of WoW", format("%s (build %s)", tostring(version), tostring(build)))
	AddRow(rows, "Interface", tostring(tocVersion))
	AddRow(rows, "Game Mode", GetFlavor())
	AddRow(rows, "Client Language", GetLocale())
	AddRow(rows, "Group", GetGroupState())
	AddRow(rows, "Zone", GetInstanceState())
	AddRow(rows, "In Combat", YesNo(InCombatLockdown()))

	return { title = "WoW Info", rows = rows }
end

local function BuildUnitFrameSection()
	local rows = {}

	for _, addon in ipairs(unitFrameAddons) do
		if BLINKIISPORTRAITS[addon.flag] then AddRow(rows, addon.name, tostring(GetAddOnMetadata(addon.name, "Version") or "?")) end
	end

	if not rows[1] then AddRow(rows, "Loaded", "none", true) end

	return { title = "Unit Frame AddOns", rows = rows }
end

local function BuildSettingsSection()
	local rows = {}
	local profile = BLINKIISPORTRAITS.db.profile
	local misc = profile.misc

	AddRow(rows, "Clickable Portraits", YesNo(misc.clickable))
	AddRow(rows, "Class Icons", tostring(misc.class_icon))
	AddRow(rows, "Custom Textures", YesNo(profile.custom.enable))
	AddRow(rows, "Extra on Top", YesNo(misc.extratop))
	AddRow(rows, "Zoom", tostring(misc.zoom))
	AddRow(rows, "Desaturate", YesNo(misc.desaturate))
	AddRow(rows, "Force Default Color", YesNo(misc.force_default))
	AddRow(rows, "Force Reaction Color", YesNo(misc.force_reaction))

	return { title = "Global Settings", rows = rows }
end

local function BuildPortraitSection()
	local rows = {}
	local keys = {}

	for key in pairs(BLINKIISPORTRAITS.Portraits) do
		keys[#keys + 1] = key
	end
	sort(keys)

	for _, key in ipairs(keys) do
		local portrait = BLINKIISPORTRAITS.Portraits[key]
		local parent = portrait.parentFrame
		local model = GetModelState(portrait)
		local isBroken = (not portrait.unit) or (model == "pending")

		AddRow(
			rows,
			key,
			format(
				"%s | %s | %s | %s | %s | %s",
				tostring(portrait.parentAddon),
				(parent and (parent:GetName() or "unnamed")) or "no parent",
				tostring(portrait.unit),
				tostring(portrait.db and portrait.db.texture),
				portrait:IsVisible() and "visible" or "hidden",
				model
			),
			isBroken
		)
	end

	local disabled = {}
	for _, unit in ipairs(reportUnits) do
		if not BLINKIISPORTRAITS.db.profile[unit].enable then disabled[#disabled + 1] = unit end
	end

	AddRow(rows, "Active", tostring(#keys))
	AddRow(rows, "Disabled", disabled[1] and concat(disabled, ", ") or "none")

	return { title = "Portraits", rows = rows }
end

local function BuildTargetSection()
	local rows = {}

	if not UnitExists("target") then
		AddRow(rows, "Target", "none")

		return { title = "Target Info", rows = rows }
	end

	local guid = UnitGUID("target")
	targetProbe.unit = "target"
	targetProbe.type = "report"
	targetProbe.isPlayer = UnitIsPlayer("target") or false
	targetProbe.lastGUID = BLINKIISPORTRAITS:IsSecretValue(guid) and " " or guid

	AddRow(rows, "Name", Safe(UnitName("target")))
	AddRow(rows, "Is Player", YesNo(targetProbe.isPlayer))
	AddRow(rows, "Class", tostring(select(2, UnitClass("target")) or "-"))
	AddRow(rows, "Level", Safe(UnitLevel("target")))
	AddRow(rows, "Classification", Safe(UnitClassification("target")))
	AddRow(rows, "Extra Texture", tostring(BLINKIISPORTRAITS:GetExtraClassification(targetProbe) or "none"))
	AddRow(rows, "Reaction", Safe(UnitReaction("target", "player")))
	AddRow(rows, "Dead", YesNo(UnitIsDead("target")))
	AddRow(rows, "In Vehicle", YesNo(_G.UnitInVehicle and _G.UnitInVehicle("target")))
	AddRow(rows, "GUID", Safe(guid))

	return { title = "Target Info", rows = rows }
end

--- Collects a diagnostic snapshot of addon, client, unit frame, portrait and target state.
-- @return an array of { title, rows = { { label, value, warn } } }
function BLINKIISPORTRAITS:BuildReport()
	return {
		BuildAddonSection(),
		BuildClientSection(),
		BuildUnitFrameSection(),
		BuildSettingsSection(),
		BuildPortraitSection(),
		BuildTargetSection(),
	}
end

--- Returns the diagnostic report as plain text, without any color codes, ready to be pasted.
function BLINKIISPORTRAITS:GetReportText()
	local lines = {}

	for _, section in ipairs(BLINKIISPORTRAITS:BuildReport()) do
		lines[#lines + 1] = format("-- %s --", section.title)

		for _, row in ipairs(section.rows) do
			lines[#lines + 1] = format("%s: %s", row.label, row.value)
		end

		lines[#lines + 1] = ""
	end

	return concat(lines, "\n")
end

local window
local linePool = {}

local function AcquireLine(content, index)
	local line = linePool[index]
	if line then return line end

	line = {}
	line.label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	line.label:SetJustifyH("LEFT")

	line.value = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	line.value:SetJustifyH("LEFT")
	line.value:SetWordWrap(false)

	line.divider = content:CreateTexture(nil, "ARTWORK")
	line.divider:SetColorTexture(1, 1, 1, 0.15)
	line.divider:SetHeight(1)

	linePool[index] = line

	return line
end

local function LayoutHeading(content, line, title, offset, width)
	line.label:SetWidth(width)
	line.label:SetJustifyH("CENTER")
	line.label:SetText(HEADING_COLOR .. title .. "|r")
	line.label:ClearAllPoints()
	line.label:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -offset)
	line.label:Show()

	line.value:Hide()

	line.divider:ClearAllPoints()
	line.divider:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(offset + ROW_HEIGHT))
	line.divider:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(offset + ROW_HEIGHT))
	line.divider:Show()
end

local function LayoutRow(content, line, row, offset, width)
	local color = row.warn and WARN_COLOR or VALUE_COLOR

	line.divider:Hide()

	line.label:SetWidth(LABEL_WIDTH)
	line.label:SetJustifyH("LEFT")
	line.label:SetText(row.label .. ":")
	line.label:ClearAllPoints()
	line.label:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, -offset)
	line.label:Show()

	line.value:SetWidth(width - LABEL_WIDTH - PADDING * 2)
	line.value:SetText(row.value)
	line.value:SetTextColor(color.r, color.g, color.b)
	line.value:ClearAllPoints()
	line.value:SetPoint("TOPLEFT", line.label, "TOPRIGHT", 6, 0)
	line.value:Show()
end

local function LayoutReport(content, width)
	local index, offset = 0, 0

	for _, section in ipairs(BLINKIISPORTRAITS:BuildReport()) do
		index = index + 1
		LayoutHeading(content, AcquireLine(content, index), section.title, offset, width)
		offset = offset + ROW_HEIGHT + 6

		for _, row in ipairs(section.rows) do
			index = index + 1
			LayoutRow(content, AcquireLine(content, index), row, offset, width)
			offset = offset + ROW_HEIGHT
		end

		offset = offset + SECTION_GAP
	end

	-- entries left over from a longer previous report
	for i = index + 1, #linePool do
		local line = linePool[i]
		line.label:Hide()
		line.value:Hide()
		line.divider:Hide()
	end

	content:SetHeight(offset)
end

local function CreateCopyBox(parent)
	local scroll = CreateFrame("ScrollFrame", "BP_ReportCopyScroll", parent, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", PADDING, -TOP_INSET)
	scroll:SetPoint("BOTTOMRIGHT", -30, BOTTOM_INSET)
	scroll:Hide()

	local box = CreateFrame("EditBox", nil, scroll)
	box:SetMultiLine(true)
	box:SetAutoFocus(false)
	box:SetFontObject(ChatFontNormal)
	box:SetWidth(WINDOW_WIDTH - 60)
	box:SetScript("OnEscapePressed", box.ClearFocus)
	scroll:SetScrollChild(box)

	scroll.box = box

	return scroll
end

local function GetScrollBar(scroll)
	return scroll.ScrollBar or _G[(scroll:GetName() or "") .. "ScrollBar"]
end

-- ElvUI only skins AceGUI windows, this one is a plain frame - run the same skin functions over its
-- widgets so it does not sit next to the skinned options looking like a different addon
local function SkinWindow(frame)
	if not BLINKIISPORTRAITS.ELVUI then return end

	local E = _G.ElvUI and _G.ElvUI[1]
	if not (E and E.private and E.private.skins and E.private.skins.ace3Enable) then return end

	local S = E.GetModule and E:GetModule("Skins", true)
	if not S then return end

	if S.HandleCloseButton then S:HandleCloseButton(frame.close) end
	if S.HandleButton then S:HandleButton(frame.button) end
	if S.HandleEditBox then S:HandleEditBox(frame.copy.box) end

	if S.HandleScrollBar then
		local reportBar, copyBar = GetScrollBar(frame.scroll), GetScrollBar(frame.copy)
		if reportBar then S:HandleScrollBar(reportBar) end
		if copyBar then S:HandleScrollBar(copyBar) end
	end

	if frame.SetTemplate then frame:SetTemplate("Transparent") end
end

local function CreateReportWindow()
	local frame = CreateFrame("Frame", "BP_ReportFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	frame:SetSize(WINDOW_WIDTH, MIN_WINDOW_HEIGHT)
	frame:SetPoint("CENTER")
	-- same strata as the AceGUI options window, otherwise the report opens behind it
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 1,
	})
	frame:SetBackdropColor(0.06, 0.06, 0.07, 0.95)
	frame:SetBackdropBorderColor(0, 0.64, 1, 0.8)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", PADDING, -12)
	title:SetText(format("%s |cffffffff%s|r", BLINKIISPORTRAITS.Name, tostring(BLINKIISPORTRAITS.Version)))

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 2)

	local scroll = CreateFrame("ScrollFrame", "BP_ReportScroll", frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", PADDING, -TOP_INSET)
	scroll:SetPoint("BOTTOMRIGHT", -30, BOTTOM_INSET)

	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(WINDOW_WIDTH - PADDING - 34, 1)
	scroll:SetScrollChild(content)

	local copy = CreateCopyBox(frame)

	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(120, 22)
	button:SetPoint("BOTTOMLEFT", PADDING, 10)
	button:SetText(L["Copy Text"])
	button:SetScript("OnClick", function()
		if copy:IsShown() then
			copy:Hide()
			scroll:Show()
			button:SetText(L["Copy Text"])
		else
			copy.box:SetText(BLINKIISPORTRAITS:GetReportText())
			scroll:Hide()
			copy:Show()
			copy.box:SetFocus()
			copy.box:HighlightText()
			button:SetText(L["Back"])
		end
	end)

	local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("BOTTOMRIGHT", -PADDING, 16)
	hint:SetText(L["Select the text and press Ctrl+C to copy it."])

	frame.content = content
	frame.scroll = scroll
	frame.copy = copy
	frame.button = button
	frame.close = close

	tinsert(_G.UISpecialFrames, "BP_ReportFrame")

	SkinWindow(frame)

	return frame
end

--- Opens the diagnostic window, rebuilding its content from the current state.
function BLINKIISPORTRAITS:ShowReport()
	window = window or CreateReportWindow()

	window.copy:Hide()
	window.scroll:Show()
	window.button:SetText(L["Copy Text"])

	LayoutReport(window.content, window.content:GetWidth())

	-- grow with the content so the report needs no scrolling, capped at the screen height
	local height = window.content:GetHeight() + TOP_INSET + BOTTOM_INSET
	window:SetHeight(min(max(height, MIN_WINDOW_HEIGHT), UIParent:GetHeight() * MAX_HEIGHT_RATIO))

	window.scroll:SetVerticalScroll(0)
	window:Show()
	window:Raise()
end
