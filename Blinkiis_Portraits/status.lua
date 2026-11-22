local _G = _G
local BLINKIISPORTRAITS = BLINKIISPORTRAITS
local CreateFrame = CreateFrame
local UIParent = UIParent
local format = format
local ipairs, pairs = ipairs, pairs
local concat, sort = table.concat, table.sort
local tostring = tostring
local type = type
local GetBuildInfo, GetLocale = GetBuildInfo, GetLocale
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded
local GetNumAddOns = _G.C_AddOns and _G.C_AddOns.GetNumAddOns or _G.GetNumAddOns
local GetAddOnInfo = _G.C_AddOns and _G.C_AddOns.GetAddOnInfo or _G.GetAddOnInfo

local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local MAIN_WIDTH, PLUGIN_WIDTH = 360, 260
local ROW_HEIGHT, HEADING_HEIGHT, SECTION_GAP, PADDING = 25, 30, 6, 12
local TOP_INSET, BOTTOM_INSET = 40, 44
local ROW_FONT_SIZE, HEADING_FONT_SIZE = 14, 18
-- ElvUI's default value color, used when ElvUI does not provide its own
local DEFAULT_HEADING_COLOR = "|cfffe7b2c"
local DIVIDER_TEXTURE = "Interface\\Tooltips\\UI-Tooltip-Border"

local VALUE_COLOR = { r = 0.29, g = 0.92, b = 0.17 }
local WARN_COLOR = { r = 1, g = 0.2, b = 0.2 }
local MUTED_COLOR = { r = 0.53, g = 0.53, b = 0.53 }

local SINGLE_UNITS = { { "player", "Player" }, { "target", "Target" }, { "focus", "Focus" }, { "targettarget", "Target of Target" }, { "pet", "Pet" } }
local GROUP_UNITS = { { "party", "Party" }, { "boss", "Boss" }, { "arena", "Arena" } }
local GROUP_SIZE = 5

local SETTING_LABELS = {
	clickable = "Clickable",
	class_icon = "Class Icons",
	spec_icon = "Spec Icons",
	extratop = "Extra on Top",
	zoom = "Zoom",
	desaturate = "Desaturate",
	force_default = "Force Default Color",
	force_reaction = "Force Reaction Color",
}

local flavors = { "Retail", "Forever", "Mists", "Cata", "Wrath", "Classic" }

local function YesNo(value)
	return value and "yes" or "no"
end

local function AddRow(rows, label, value, warn, muted)
	rows[#rows + 1] = { label = label, value = value, warn = warn, muted = muted }
end

local function SortedKeys(tbl)
	local keys = {}
	for key in pairs(tbl) do
		keys[#keys + 1] = key
	end
	sort(keys)
	return keys
end

-- only plain values are compared, tables like colors would flood the window
function BLINKIISPORTRAITS:GetChangedSettings()
	local rows = {}
	local defaults = BLINKIISPORTRAITS.defaults.profile
	local profile = BLINKIISPORTRAITS.db.profile

	for _, key in ipairs(SortedKeys(defaults.misc or {})) do
		local value, default = profile.misc[key], defaults.misc[key]
		if type(default) ~= "table" and value ~= default then AddRow(rows, SETTING_LABELS[key] or key, type(value) == "boolean" and YesNo(value) or tostring(value)) end
	end

	if profile.custom and defaults.custom and profile.custom.enable ~= defaults.custom.enable then AddRow(rows, "Custom Textures", YesNo(profile.custom.enable)) end

	return rows
end

local function CountGroup(prefix)
	local count = 0
	for index = 1, GROUP_SIZE do
		local portrait = BLINKIISPORTRAITS.Portraits[prefix .. index]
		if portrait and portrait.parentFrame then count = count + 1 end
	end
	return count
end

function BLINKIISPORTRAITS:GetPortraitSummary()
	local rows = {}
	local profile = BLINKIISPORTRAITS.db.profile

	for _, entry in ipairs(SINGLE_UNITS) do
		local unit, label = entry[1], entry[2]
		local portrait = BLINKIISPORTRAITS.Portraits[unit]
		if not (profile[unit] and profile[unit].enable) then
			AddRow(rows, label, "off", nil, true)
		elseif portrait and portrait.parentFrame then
			AddRow(rows, label, "ok")
		else
			AddRow(rows, label, "missing", true)
		end
	end

	for _, entry in ipairs(GROUP_UNITS) do
		local unit, label = entry[1], entry[2]
		if not (profile[unit] and profile[unit].enable) then
			AddRow(rows, label, "off", nil, true)
		else
			AddRow(rows, label, format("%d/%d", CountGroup(unit), GROUP_SIZE))
		end
	end

	return rows
end

function BLINKIISPORTRAITS:GetPluginStatusRows()
	local rows = {}

	for name in BLINKIISPORTRAITS.API:IteratePlugins() do
		AddRow(rows, name, tostring(GetAddOnMetadata(name, "Version") or "?"))
	end

	for _, provider in ipairs(BLINKIISPORTRAITS:GetProviders()) do
		if not provider.flag then AddRow(rows, "Provider", provider.label) end
	end

	local styles = BLINKIISPORTRAITS:GetRegisteredStyles()
	for _, id in ipairs(SortedKeys(styles)) do
		AddRow(rows, "Style", styles[id].name)
	end

	return rows
end

local function GetUnitFrameAddons()
	local names, seen = {}, {}
	for _, provider in ipairs(BLINKIISPORTRAITS:GetProviders()) do
		local folder = provider.available and (provider.flag and BLINKIISPORTRAITS.LoadedAddons[provider.flag] or provider.addons[1])
		if folder and not seen[folder] then
			seen[folder] = true
			names[#names + 1] = format("%s %s", folder, tostring(GetAddOnMetadata(folder, "Version") or ""))
		end
	end
	return names[1] and concat(names, ", ") or nil
end

-- anything loaded beyond what debug mode would keep counts as another addon
local function HasOtherAddons()
	local keep = BLINKIISPORTRAITS:GetDebugModeKeepSet()
	for index = 1, GetNumAddOns() do
		local name = GetAddOnInfo(index)
		if name and not keep[name] and IsAddOnLoaded(name) then return true end
	end
	return false
end

local function GetFlavor()
	for _, flavor in ipairs(flavors) do
		if BLINKIISPORTRAITS[flavor] then return flavor end
	end
	return "unknown"
end

local function BuildAddonSection()
	local rows = {}
	local unitFrames = GetUnitFrameAddons()
	local others = HasOtherAddons()

	AddRow(rows, "Version", tostring(BLINKIISPORTRAITS.Version))
	AddRow(rows, "Profile", tostring(BLINKIISPORTRAITS.db:GetCurrentProfile()))
	AddRow(rows, "Unit Frames", unitFrames or "none", not unitFrames)
	AddRow(rows, "Other AddOns", YesNo(others), others)
	AddRow(rows, "Debug Mode", YesNo(BLINKIISPORTRAITS:IsDebugModeActive()))

	return { title = "AddOn Info", rows = rows }
end

local function BuildClientSection()
	local rows = {}
	local version, build = GetBuildInfo()

	AddRow(rows, "WoW", format("%s (%s) %s", tostring(version), tostring(build), GetFlavor()))
	AddRow(rows, "Language", tostring(GetLocale()))

	return { title = "WoW Info", rows = rows }
end

function BLINKIISPORTRAITS:BuildStatus()
	local main = {
		BuildAddonSection(),
		BuildClientSection(),
		{ title = "Portraits", rows = BLINKIISPORTRAITS:GetPortraitSummary() },
	}

	local changed = BLINKIISPORTRAITS:GetChangedSettings()
	if changed[1] then main[#main + 1] = { title = "Changed Settings", rows = changed } end

	return main, { { title = "Plugins", rows = BLINKIISPORTRAITS:GetPluginStatusRows() } }
end

local function AppendSections(lines, sections)
	for _, section in ipairs(sections) do
		lines[#lines + 1] = format("-- %s --", section.title)
		if not section.rows[1] then lines[#lines + 1] = "none" end
		for _, row in ipairs(section.rows) do
			lines[#lines + 1] = format("%s: %s", row.label, row.value)
		end
		lines[#lines + 1] = ""
	end
end

function BLINKIISPORTRAITS:GetStatusText()
	local main, plugins = BLINKIISPORTRAITS:BuildStatus()
	local lines = {}
	AppendSections(lines, main)
	AppendSections(lines, plugins)
	return concat(lines, "\n")
end

local window

-- with ElvUI the window copies its status window, without it the game's own frame look is used
local function GetElvUI()
	return BLINKIISPORTRAITS.ELVUI and _G.ElvUI and _G.ElvUI[1]
end

-- Expressway comes with ElvUI through LibSharedMedia
local function GetFontPath()
	local LSM = LibStub("LibSharedMedia-3.0", true)
	return (LSM and LSM:Fetch("font", "Expressway", true)) or STANDARD_TEXT_FONT
end

local function GetHeadingColor()
	local E = GetElvUI()
	return (E and E.media and E.media.hexvaluecolor) or DEFAULT_HEADING_COLOR
end

local ELVUI_STYLE = { rowHeight = ROW_HEIGHT, headingHeight = HEADING_HEIGHT, topInset = TOP_INSET }

function ELVUI_STYLE.Row(fontString)
	fontString:SetFont(GetFontPath(), ROW_FONT_SIZE, "OUTLINE")
end

function ELVUI_STYLE.Heading(fontString, title)
	fontString:SetFont(GetFontPath(), HEADING_FONT_SIZE, "OUTLINE")
	fontString:SetTextColor(1, 1, 1)
	fontString:SetText(GetHeadingColor() .. title .. "|r")
end

local WOW_STYLE = { rowHeight = 18, headingHeight = 26, topInset = 34, template = "BasicFrameTemplateWithInset" }

function WOW_STYLE.Row(fontString)
	fontString:SetFontObject(GameFontHighlight)
end

function WOW_STYLE.Heading(fontString, title)
	fontString:SetFontObject(GameFontNormalLarge)
	fontString:SetTextColor(GameFontNormalLarge:GetTextColor())
	fontString:SetText(title)
end

local style

local function CreateDivider(panel)
	local divider = panel:CreateTexture(nil, "ARTWORK")
	divider:SetTexture(DIVIDER_TEXTURE)
	divider:SetTexCoord(0.81, 0.94, 0.5, 1)
	divider:SetHeight(8)
	return divider
end

local function AcquireLine(panel, index)
	local line = panel.lines[index]
	if line then return line end

	line = {}
	line.label = panel:CreateFontString(nil, "OVERLAY")
	line.value = panel:CreateFontString(nil, "OVERLAY")
	style.Row(line.value)
	line.value:SetJustifyH("LEFT")
	line.value:SetWordWrap(false)

	line.left = CreateDivider(panel)
	line.right = CreateDivider(panel)

	panel.lines[index] = line
	return line
end

local function LayoutHeading(panel, line, title, offset)
	style.Heading(line.label, title)
	line.label:SetJustifyH("CENTER")
	line.label:ClearAllPoints()
	line.label:SetPoint("TOP", panel, "TOP", 0, -offset)
	line.label:Show()
	line.value:Hide()

	-- the dividers run from the panel edges up to the title, centered on it
	line.left:ClearAllPoints()
	line.left:SetPoint("LEFT", panel, "LEFT", PADDING, 0)
	line.left:SetPoint("RIGHT", line.label, "LEFT", -5, 0)
	line.left:SetPoint("TOP", line.label, "CENTER", 0, 4)
	line.right:ClearAllPoints()
	line.right:SetPoint("RIGHT", panel, "RIGHT", -PADDING, 0)
	line.right:SetPoint("LEFT", line.label, "RIGHT", 5, 0)
	line.right:SetPoint("TOP", line.label, "CENTER", 0, 4)
	line.left:Show()
	line.right:Show()
end

local function LayoutRow(panel, line, row, offset)
	local color = (row.warn and WARN_COLOR) or (row.muted and MUTED_COLOR) or VALUE_COLOR

	line.left:Hide()
	line.right:Hide()

	style.Row(line.label)
	line.label:SetTextColor(1, 1, 1)
	line.label:SetJustifyH("LEFT")
	line.label:SetText(row.label .. ":")
	line.label:ClearAllPoints()
	line.label:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING * 2, -offset)
	line.label:Show()

	line.value:SetText(row.value)
	line.value:SetTextColor(color.r, color.g, color.b)
	line.value:ClearAllPoints()
	line.value:SetPoint("LEFT", line.label, "RIGHT", 6, 0)
	line.value:SetPoint("RIGHT", panel, "RIGHT", -PADDING, 0)
	line.value:Show()
end

local function LayoutPanel(panel, sections, startOffset)
	local index, offset = 0, startOffset

	for _, section in ipairs(sections) do
		if section.title then
			index = index + 1
			LayoutHeading(panel, AcquireLine(panel, index), section.title, offset)
			offset = offset + style.headingHeight
		end

		if not section.rows[1] then
			index = index + 1
			LayoutRow(panel, AcquireLine(panel, index), { label = "None", value = "", muted = true }, offset)
			offset = offset + style.rowHeight
		end

		for _, row in ipairs(section.rows) do
			index = index + 1
			LayoutRow(panel, AcquireLine(panel, index), row, offset)
			offset = offset + style.rowHeight
		end

		offset = offset + SECTION_GAP
	end

	-- lines left over from a longer previous status
	for i = index + 1, #panel.lines do
		local line = panel.lines[i]
		line.label:Hide()
		line.value:Hide()
		line.left:Hide()
		line.right:Hide()
	end

	return offset
end

local function CreatePanel(name, parent, width)
	local panel
	if style.template then
		panel = CreateFrame("Frame", name, parent, style.template)
	else
		panel = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
		panel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
		panel:SetBackdropColor(0.06, 0.06, 0.07, 0.95)
		panel:SetBackdropBorderColor(0, 0, 0, 1)
	end

	panel:SetWidth(width)
	panel.lines = {}
	return panel
end

local SIMPLE_CORNER_ATLAS = "UI-Frame-TopCornerRightSimple"

-- the frame corner has a slot for the close button, a panel without one gets the plain corner Blizzard uses for that
local function RemoveCloseSlot(panel)
	if not panel.CloseButton then return end
	panel.CloseButton:Hide()

	local corner = panel.TopRightCorner
	if not corner then return end

	if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(SIMPLE_CORNER_ATLAS) then
		corner:SetAtlas(SIMPLE_CORNER_ATLAS, true)
	else
		corner:SetTexture("Interface\\FrameGeneral\\UI-Frame")
		corner:SetTexCoord(0.1328125, 0.21875, 0.984375, 0.8984375)
		corner:SetSize(11, 11)
	end

	if panel.TitleBg then
		panel.TitleBg:ClearAllPoints()
		panel.TitleBg:SetPoint("TOPLEFT", 2, -1)
		panel.TitleBg:SetPoint("TOPRIGHT", -2, -1)
	end
end

local function CreateCopyBox(parent)
	local scroll = CreateFrame("ScrollFrame", "BP_StatusCopyScroll", parent, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", PADDING, -TOP_INSET)
	scroll:SetPoint("BOTTOMRIGHT", -30, BOTTOM_INSET)
	scroll:Hide()

	local box = CreateFrame("EditBox", nil, scroll)
	box:SetMultiLine(true)
	box:SetAutoFocus(false)
	box:SetFontObject(ChatFontNormal)
	box:SetWidth(MAIN_WIDTH - 50)
	box:SetScript("OnEscapePressed", box.ClearFocus)
	scroll:SetScrollChild(box)

	scroll.box = box
	return scroll
end

-- ElvUI only skins AceGUI windows, so its skin functions are run over these plain frames
local function SkinWindow(frame)
	local E = GetElvUI()
	if not (E and E.private and E.private.skins and E.private.skins.ace3Enable) then return end

	local S = E.GetModule and E:GetModule("Skins", true)
	if not S then return end

	if S.HandleCloseButton then S:HandleCloseButton(frame.close) end
	if S.HandleButton then S:HandleButton(frame.button) end
	if S.HandleEditBox then S:HandleEditBox(frame.copy.box) end

	local bar = frame.copy.ScrollBar or _G[(frame.copy:GetName() or "") .. "ScrollBar"]
	if bar and S.HandleScrollBar then S:HandleScrollBar(bar) end

	if frame.SetTemplate then frame:SetTemplate("Transparent") end
	if frame.plugins.SetTemplate then frame.plugins:SetTemplate("Transparent") end
end

local function CreateStatusWindow()
	style = GetElvUI() and ELVUI_STYLE or WOW_STYLE

	local frame = CreatePanel("BP_StatusFrame", UIParent, MAIN_WIDTH)
	frame:SetPoint("CENTER", -PLUGIN_WIDTH / 2, 0)
	-- otherwise the window opens behind the AceGUI options window
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	local close
	if style.template then
		frame.TitleText:SetText(BLINKIISPORTRAITS.Name)
		close = frame.CloseButton
	else
		local title = frame:CreateFontString(nil, "OVERLAY")
		style.Heading(title, BLINKIISPORTRAITS.Name)
		title:SetPoint("TOP", 0, -12)

		close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 2, 2)
	end

	local plugins = CreatePanel("BP_StatusPlugins", frame, PLUGIN_WIDTH)
	plugins:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
	RemoveCloseSlot(plugins)
	if plugins.TitleText then plugins.TitleText:SetText(L["Plugins"]) end

	local copy = CreateCopyBox(frame)

	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(110, 22)
	button:SetPoint("BOTTOM", 0, 10)
	button:SetText(L["Copy Text"])
	button:SetScript("OnClick", function()
		if copy:IsShown() then
			copy:Hide()
			BLINKIISPORTRAITS:ShowStatus()
		else
			copy.box:SetText(BLINKIISPORTRAITS:GetStatusText())
			for _, line in ipairs(frame.lines) do
				line.label:Hide()
				line.value:Hide()
				line.left:Hide()
				line.right:Hide()
			end
			copy:Show()
			copy.box:SetFocus()
			copy.box:HighlightText()
			button:SetText(L["Back"])
		end
	end)

	frame.plugins = plugins
	frame.copy = copy
	frame.button = button
	frame.close = close

	tinsert(_G.UISpecialFrames, "BP_StatusFrame")

	SkinWindow(frame)

	return frame
end

function BLINKIISPORTRAITS:ShowStatus()
	window = window or CreateStatusWindow()

	window.copy:Hide()
	window.button:SetText(L["Copy Text"])

	local main, plugins = BLINKIISPORTRAITS:BuildStatus()
	window:SetHeight(LayoutPanel(window, main, style.topInset) + BOTTOM_INSET)

	-- the game frame look already names the plugin panel in its title bar
	if style.template then plugins[1].title = nil end
	local pluginTop = style.template and style.topInset or PADDING
	window.plugins:SetHeight(LayoutPanel(window.plugins, plugins, pluginTop) + PADDING)

	window:Show()
	window:Raise()
end
