local _G = _G
local C_Timer_After = C_Timer.After
local CreateFrame = CreateFrame
local StaticPopup_Show = StaticPopup_Show
local concat = table.concat
local gsub = gsub
local ipairs = ipairs
local next = next
local pairs = pairs
local sort = sort
local tostring = tostring
local type = type
local unpack = unpack

local addonName = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local PLUGIN_LABEL = "Blinkii's Portraits"
local APP_NAME = "EllesmereUI"
local DEFAULT_ORDER = 100
local DISABLED_ALPHA = 0.35
local ROW_H = 50
local MULTILINE_ROW_H = 170
local INPUT_W = 260
local TEXT_PAD = 10
local FONT_SIZES = { small = 11, medium = 13, large = 15 }
local UNITS_MODULE_KEY = "portraits"
-- one sidebar row with a tab per unit keeps the section short, EllesmereUI cannot collapse sidebar sections
local UNIT_GROUPS = {
	player_group = true,
	target_group = true,
	focus_group = true,
	targettarget_group = true,
	pet_group = true,
	party_group = true,
	boss_group = true,
	arena_group = true,
}

local pageSignatures = {}
local isRefreshScheduled = false
local OnValueChanged

local function StripCodes(text)
	text = gsub(text, "|c%x%x%x%x%x%x%x%x", "")
	text = gsub(text, "|r", "")
	text = gsub(text, "|T.-|t", "")
	text = gsub(text, "|A.-|a", "")
	return text
end

local function NewContext(parent, key, option)
	local path = {}
	for i = 1, #parent.path do
		path[i] = parent.path[i]
	end
	path[#path + 1] = key

	return {
		path = path,
		handler = option.handler or parent.handler,
		get = option.get == nil and parent.get or option.get,
		set = option.set == nil and parent.set or option.set,
		func = option.func == nil and parent.func or option.func,
		confirm = option.confirm == nil and parent.confirm or option.confirm,
		disabled = parent.disabled,
	}
end

local function BuildInfo(ctx, option)
	local info = { options = BLINKIISPORTRAITS.options, option = option, handler = ctx.handler, type = option.type, arg = option.arg, appName = APP_NAME }
	for i = 1, #ctx.path do
		info[i] = ctx.path[i]
	end
	return info
end

-- AceConfig callbacks are functions, handler method names or plain values
local function Call(member, info, ...)
	if type(member) == "function" then return member(info, ...) end
	if type(member) == "string" and info.handler and type(info.handler[member]) == "function" then return info.handler[member](info.handler, info, ...) end
	return member
end

local function GetText(member, info)
	if type(member) == "function" then return member(info) or "" end
	return member or ""
end

local function IsHidden(option, info)
	return Call(option.hidden, info) or Call(option.dialogHidden, info)
end

local function IsDisabled(option, ctx, info)
	return ctx.disabled or Call(option.disabled, info) or false
end

local function SortedArgs(group)
	local list = {}
	for key, option in pairs(group.args or {}) do
		if type(option) == "table" and option.type then list[#list + 1] = { key = key, option = option } end
	end

	sort(list, function(a, b)
		local orderA, orderB = a.option.order or DEFAULT_ORDER, b.option.order or DEFAULT_ORDER
		if orderA == orderB then return a.key < b.key end
		return orderA < orderB
	end)

	return list
end

local function SortedValueKeys(values, sorting)
	if sorting then return sorting end

	local keys = {}
	for key in pairs(values) do
		keys[#keys + 1] = key
	end
	sort(keys, function(a, b)
		return StripCodes(tostring(values[a])) < StripCodes(tostring(values[b]))
	end)
	return keys
end

local function Getter(ctx, info)
	return function()
		if not ctx.get then return nil end
		return Call(ctx.get, info)
	end
end

-- a confirmed change only runs after the popup is accepted
local function Setter(ctx, option, info, member)
	return function(...)
		local args = { ... }
		local function Apply()
			Call(member, info, unpack(args))
			OnValueChanged()
		end

		local confirm = ctx.confirm and Call(ctx.confirm, info, ...)
		if confirm then
			local text = type(confirm) == "string" and confirm or GetText(option.confirmText, info)
			if text == "" then text = StripCodes(GetText(option.name, info)) end
			StaticPopup_Show("BLINKIISPORTRAITS_CONFIRM", text, nil, Apply)
		else
			Apply()
		end
	end
end

local function BlockDisabledRow(frame)
	if not (frame and frame.SetAlpha) then return end

	frame:SetAlpha(DISABLED_ALPHA)
	local blocker = CreateFrame("Frame", nil, frame)
	blocker:SetAllPoints(frame)
	blocker:SetFrameLevel(frame:GetFrameLevel() + 20)
	blocker:EnableMouse(true)
end

local function CreateRow(parent, y, height)
	local pad = _G.EllesmereUI.CONTENT_PAD or 20
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(parent:GetWidth() - pad * 2, height)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", pad, y)
	return frame
end

local function CreateText(frame, size)
	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFont(_G.EllesmereUI.EXPRESSWAY or STANDARD_TEXT_FONT, size, "")
	text:SetTextColor(1, 1, 1)
	text:SetJustifyH("LEFT")
	return text
end

local function BuildDescription(parent, y, name, option)
	local frame = CreateRow(parent, y, 1)
	local text = CreateText(frame, FONT_SIZES[option.fontSize] or FONT_SIZES.medium)
	text:SetPoint("TOPLEFT", frame, "TOPLEFT", TEXT_PAD * 2, -TEXT_PAD)
	text:SetWidth(frame:GetWidth() - TEXT_PAD * 4)
	text:SetText(name)

	local height = text:GetStringHeight() + TEXT_PAD * 2
	frame:SetHeight(height)
	return frame, height
end

local function CreateEditBox(frame, multiline)
	local box = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
	box:SetFont(_G.EllesmereUI.EXPRESSWAY or STANDARD_TEXT_FONT, 13, "")
	box:SetAutoFocus(false)
	box:SetMultiLine(multiline)
	box:SetTextInsets(8, 8, 6, 6)
	box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
	box:SetBackdropColor(0, 0, 0, 0.5)
	box:SetBackdropBorderColor(1, 1, 1, 0.1)
	box:SetScript("OnEscapePressed", box.ClearFocus)
	return box
end

-- EllesmereUI has no text input widget, so single and multi line inputs are drawn here
local function BuildInput(parent, y, name, option, get, set)
	local multiline = option.multiline and true or false
	local frame = CreateRow(parent, y, multiline and MULTILINE_ROW_H or ROW_H)

	local label = CreateText(frame, 14)
	label:SetText(name)

	local box = CreateEditBox(frame, multiline)
	box:SetText(tostring(get() or ""))
	box:SetCursorPosition(0)

	if multiline then
		label:SetPoint("TOPLEFT", frame, "TOPLEFT", TEXT_PAD * 2, -TEXT_PAD)
		box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -TEXT_PAD)
		box:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -TEXT_PAD * 2, TEXT_PAD)
		-- a pasted string is read right away, the import box of the standalone dialog does the same
		box:SetScript("OnTextChanged", function(self, userInput)
			if userInput then set(self:GetText()) end
		end)
	else
		label:SetPoint("LEFT", frame, "LEFT", TEXT_PAD * 2, 0)
		box:SetSize(INPUT_W, 30)
		box:SetPoint("RIGHT", frame, "RIGHT", -TEXT_PAD * 2, 0)
		box:SetScript("OnEnterPressed", function(self)
			set(self:GetText())
			self:ClearFocus()
		end)
	end

	return frame, multiline and MULTILINE_ROW_H or ROW_H
end

local BuildArgs

local function BuildOption(W, parent, y, key, option, parentCtx, isPrebuild)
	local ctx = NewContext(parentCtx, key, option)
	local info = BuildInfo(ctx, option)
	if IsHidden(option, info) then return y end

	local name = StripCodes(GetText(option.name, info))
	local desc = GetText(option.desc, info)
	local disabled = IsDisabled(option, ctx, info)
	local optionType = option.type
	local frame, height

	if optionType == "group" then
		ctx.disabled = disabled
		if name ~= "" then
			local _, headerHeight = W:SectionHeader(parent, name, y)
			y = y - headerHeight
		end
		return BuildArgs(W, parent, y, option, ctx, isPrebuild)
	elseif optionType == "header" then
		if name == "" then return y end
		frame, height = W:SectionHeader(parent, name, y)
	elseif optionType == "description" then
		if isPrebuild or name == "" then return y end
		frame, height = BuildDescription(parent, y, GetText(option.name, info), option)
	elseif optionType == "toggle" then
		frame, height = W:Toggle(parent, name, y, Getter(ctx, info), Setter(ctx, option, info, ctx.set), desc)
	elseif optionType == "range" then
		local min, max, step = option.softMin or option.min or 0, option.softMax or option.max or 1, option.step or option.bigStep or 1
		frame, height = W:Slider(parent, name, y, min, max, step, Getter(ctx, info), Setter(ctx, option, info, ctx.set), desc)
	elseif optionType == "select" then
		local values = {}
		for valueKey, label in pairs(Call(option.values, info) or {}) do
			values[valueKey] = label
		end
		local order = SortedValueKeys(values, option.sorting)
		-- the labels are already localized by AceLocale
		values._noLoc = true
		frame, height = W:Dropdown(parent, name, y, values, Getter(ctx, info), Setter(ctx, option, info, ctx.set), order, desc)
	elseif optionType == "color" then
		frame, height = W:ColorPicker(parent, name, y, Getter(ctx, info), Setter(ctx, option, info, ctx.set), option.hasAlpha)
	elseif optionType == "execute" then
		local run = Setter(ctx, option, info, ctx.func)
		frame, height = W:Button(parent, name, y, function()
			run()
		end)
	elseif optionType == "input" then
		if isPrebuild then return y end
		frame, height = BuildInput(parent, y, name, option, Getter(ctx, info), Setter(ctx, option, info, ctx.set))
	else
		return y
	end

	if disabled and not isPrebuild then BlockDisabledRow(frame) end

	return y - (height or 0)
end

function BuildArgs(W, parent, y, group, ctx, isPrebuild)
	for _, entry in ipairs(SortedArgs(group)) do
		y = BuildOption(W, parent, y, entry.key, entry.option, ctx, isPrebuild)
	end
	return y
end

-- hidden, disabled and generated texts decide the page layout, a value change that flips one needs a rebuild
local function CollectSignature(group, ctx, parts)
	for _, entry in ipairs(SortedArgs(group)) do
		local option = entry.option
		local childCtx = NewContext(ctx, entry.key, option)
		local info = BuildInfo(childCtx, option)
		local hidden = IsHidden(option, info) and true or false
		parts[#parts + 1] = entry.key .. (hidden and "-" or "+")

		if not hidden then
			parts[#parts + 1] = tostring(IsDisabled(option, childCtx, info))
			if type(option.name) == "function" then parts[#parts + 1] = GetText(option.name, info) end
			if option.type == "select" and option.values then
				for valueKey in pairs(Call(option.values, info) or {}) do
					parts[#parts + 1] = tostring(valueKey)
				end
			end
			if option.type == "group" then
				childCtx.disabled = IsDisabled(option, childCtx, info)
				CollectSignature(option, childCtx, parts)
			end
		end
	end
	return parts
end

local function RootContext()
	return { path = {}, handler = BLINKIISPORTRAITS.options.handler }
end

local function BuildPageGroup(page)
	return { args = page.args }
end

local function GetPageSignature(page)
	return concat(CollectSignature(BuildPageGroup(page), page.ctx, {}), ",")
end

-- the first page also carries the loose options of the module, the enable toggle of a unit for example
local function BuildPages(moduleKey, module)
	local pages, loose = {}, {}
	local root = RootContext()
	local moduleCtx = NewContext(root, moduleKey, module)
	local moduleInfo = BuildInfo(moduleCtx, module)

	for _, entry in ipairs(SortedArgs(module)) do
		local option = entry.option
		if option.type == "group" then
			local info = BuildInfo(NewContext(moduleCtx, entry.key, option), option)
			-- client capabilities like the radial ring do not change at runtime, so hidden pages are left out for good
			if not IsHidden(option, info) then
				local childCtx = NewContext(moduleCtx, entry.key, option)
				pages[#pages + 1] = { name = StripCodes(GetText(option.name, info)), ctx = childCtx, args = option.args or {} }
			end
		else
			loose[entry.key] = option
		end
	end

	if #pages == 0 then
		pages[1] = { name = StripCodes(GetText(module.name, moduleInfo)), ctx = moduleCtx, args = module.args or {} }
	elseif next(loose) then
		pages[1].loose = { ctx = moduleCtx, args = loose }
	end

	return pages
end

local function BuildUnitPages(units)
	local pages = {}
	local root = RootContext()

	for _, entry in ipairs(units) do
		local ctx = NewContext(root, entry.key, entry.option)
		local info = BuildInfo(ctx, entry.option)
		pages[#pages + 1] = { name = StripCodes(GetText(entry.option.name, info)), ctx = ctx, args = entry.option.args or {} }
	end

	return pages
end

local function BuildModuleSpec(moduleKey, title, pages)
	local seen = {}
	for _, page in ipairs(pages) do
		local name = page.name ~= "" and page.name or moduleKey
		while seen[name] do
			name = name .. " "
		end
		seen[name] = true
		page.name = name
	end

	local pageNames, pageLookup = {}, {}
	for i, page in ipairs(pages) do
		pageNames[i] = page.name
		pageLookup[page.name] = page
	end

	local signatureKey = moduleKey .. "::"

	local spec = {
		key = moduleKey,
		title = title,
		pages = pageNames,
		buildPage = function(pageName, parent, yOffset)
			local page = pageLookup[pageName]
			if not page then return 0 end

			local W = _G.EllesmereUI.Widgets
			local isPrebuild = _G.EllesmereUI.IsSearchPrebuild()
			local y = yOffset

			if page.loose then y = BuildArgs(W, parent, y, { args = page.loose.args }, page.loose.ctx, isPrebuild) end
			y = BuildArgs(W, parent, y, BuildPageGroup(page), page.ctx, isPrebuild)

			if not isPrebuild then pageSignatures[signatureKey .. pageName] = GetPageSignature(page) end

			return -y
		end,
		onPageCacheRestore = function(pageName)
			local page = pageLookup[pageName]
			if not page then return end

			if pageSignatures[signatureKey .. pageName] ~= GetPageSignature(page) then
				_G.EllesmereUI:RefreshPage(true)
			else
				_G.EllesmereUI:RefreshPage()
			end
		end,
	}

	return spec, pageLookup
end

local modulePages = {}

-- the active page is rebuilt only when its layout changed, a rebuild mid drag would drop the slider
function OnValueChanged()
	if isRefreshScheduled then return end
	isRefreshScheduled = true

	C_Timer_After(0, function()
		isRefreshScheduled = false

		local EllesmereUI = _G.EllesmereUI
		local active = EllesmereUI:GetActiveModule()

		local activePage = EllesmereUI:GetActivePage()

		for moduleKey, pageLookup in pairs(modulePages) do
			local page = pageLookup[activePage]
			if page and active == EllesmereUI.GetPluginModuleKey(addonName, moduleKey) then
				EllesmereUI:RefreshPage(pageSignatures[moduleKey .. "::" .. activePage] ~= GetPageSignature(page))
				return
			end
		end
	end)
end

local function AddModule(modules, moduleKey, title, pages)
	local spec, pageLookup = BuildModuleSpec(moduleKey, title, pages)
	modules[#modules + 1] = spec
	modulePages[moduleKey] = pageLookup
end

-- the unit module takes the place of the first unit group
local function BuildPluginSpec()
	local entries, units = {}, {}
	for _, entry in ipairs(SortedArgs(BLINKIISPORTRAITS.options)) do
		if entry.option.type == "group" then
			if UNIT_GROUPS[entry.key] then
				if #units == 0 then entries[#entries + 1] = { key = UNITS_MODULE_KEY } end
				units[#units + 1] = entry
			else
				entries[#entries + 1] = entry
			end
		end
	end

	local modules = {}
	for _, entry in ipairs(entries) do
		if entry.key == UNITS_MODULE_KEY then
			AddModule(modules, UNITS_MODULE_KEY, L["Portraits"], BuildUnitPages(units))
		else
			local info = BuildInfo(NewContext(RootContext(), entry.key, entry.option), entry.option)
			AddModule(modules, entry.key, StripCodes(GetText(entry.option.name, info)), BuildPages(entry.key, entry.option))
		end
	end

	return { label = PLUGIN_LABEL, modules = modules }
end

function BLINKIISPORTRAITS:SetupEllesmereUIOptions()
	if not BLINKIISPORTRAITS.EUI then return end

	local EllesmereUI = _G.EllesmereUI
	if not (EllesmereUI and EllesmereUI.RegisterPlugin) then return end
	if EllesmereUI.IsPluginRegistered(addonName) then return end

	EllesmereUI.RegisterPlugin(addonName, BuildPluginSpec())
end
