local _, ns = ...

local API = ns.plugin and BLINKIISPORTRAITS.API
if not API then return end

local plugin = ns.plugin
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthMissing = UnitHealthMissing

-- the missing health darkens the portrait from the top, the bar sits between the unit image and the frame
local function GetFill(portrait)
	local data = portrait.plugins.BP_ExamplePlugin
	if not data then
		data = {}
		portrait.plugins.BP_ExamplePlugin = data
	end

	if not data.healthFill then
		local bar = CreateFrame("StatusBar", nil, portrait)
		bar:SetAllPoints(portrait.portrait)
		bar:SetOrientation("VERTICAL")
		bar:SetReverseFill(true)
		bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
		bar:SetStatusBarColor(0, 0, 0, 0.65)
		bar:SetFrameLevel(portrait:GetFrameLevel())

		local fill = bar:GetStatusBarTexture()
		fill:SetDrawLayer("ARTWORK", 3)
		fill:AddMaskTexture(portrait.mask)

		data.healthFill = bar
	end

	return data.healthFill
end

-- a secret health value is only handed to the bar, never compared or calculated with
local function GetMissing(unit)
	if UnitHealthMissing then return UnitHealthMissing(unit) end

	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if API:IsSecretValue(health) or API:IsSecretValue(maxHealth) then return 0 end
	return maxHealth - health
end

local function UpdateFill(portrait)
	local bar = GetFill(portrait)
	if not (plugin.db.profile.enabled and portrait.unit) then return bar:Hide() end

	bar:SetMinMaxValues(0, UnitHealthMax(portrait.unit))
	bar:SetValue(GetMissing(portrait.unit))
	bar:Show()
end

API:HookElement(plugin, "Portrait", {
	events = { "UNIT_HEALTH", "UNIT_MAXHEALTH" },
	PostUpdate = function(_, portrait)
		UpdateFill(portrait)
	end,
})

API.RegisterCallback(ns, "PortraitSetup", function(_, portrait)
	UpdateFill(portrait)
end)
