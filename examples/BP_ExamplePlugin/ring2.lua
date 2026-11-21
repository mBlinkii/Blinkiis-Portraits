local _, ns = ...

local API = ns.plugin and BLINKIISPORTRAITS.API
if not API then return end

local plugin = ns.plugin
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local PowerBarColor = PowerBarColor

local RADIAL = Enum.StatusBarRenderMode and Enum.StatusBarRenderMode.Radial
local INSET = 0.82

local function GetBar(state, portrait)
	if state.bar then return state.bar end

	local bar = CreateFrame("StatusBar", nil, portrait)
	bar:SetRenderMode(RADIAL)
	bar:SetFrameLevel(portrait:GetFrameLevel())
	state.bar = bar

	return bar
end

-- the frame texture doubles as the ring shape, so the second ring follows every style
local function Layout(bar, portrait)
	bar:SetStatusBarTexture(portrait.texture:GetTexture())
	bar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 7)

	local width, height = portrait.texture:GetSize()
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", portrait.texture, "CENTER")
	bar:SetSize(width * INSET, height * INSET)
end

local function UpdatePower(state, portrait, unit)
	unit = unit or portrait.unit
	if not unit then return end

	local bar = GetBar(state, portrait)
	local _, token = UnitPowerType(unit)
	local color = PowerBarColor[API:SafeValue(token) or "MANA"] or PowerBarColor.MANA

	bar:SetStatusBarColor(color.r, color.g, color.b, 0.9)
	bar:SetMinMaxValues(0, UnitPowerMax(unit))
	bar:SetValue(UnitPower(unit))
	bar:Show()
end

local registered = API:RegisterElement(plugin, "BPEX_Ring2", {
	events = { "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER" },
	Enable = function()
		return RADIAL ~= nil and plugin.db.profile.enabled
	end,
	Disable = function(state)
		if state.bar then state.bar:Hide() end
	end,
	Update = function(state, portrait, _, unit)
		UpdatePower(state, portrait, unit)
	end,
})
ns.Check("second ring element registered", registered == true)

API.RegisterCallback(ns.plugin, "PortraitSetup", function(_, portrait)
	local state = portrait.elements and portrait.elements.BPEX_Ring2
	if not (state and state.enabled) then return end

	Layout(GetBar(state, portrait), portrait)
	UpdatePower(state, portrait)
end)
