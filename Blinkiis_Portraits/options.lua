-- options
local category, layout
local _G = _G
function BLINKIISPORTRAITS:InitializeOptions()
	self.Options = CreateFrame("Frame")
	self.Options.name = BLINKIISPORTRAITS.Name

	local portraitsLable = self.Options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	portraitsLable:SetPoint("TOPLEFT", 10, -10)
	portraitsLable:SetText("Enable/ Disable Portraits")

	local playerCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	playerCB:SetPoint("TOPLEFT", 10, -40)
	playerCB.Text:SetText("Player")
	playerCB:SetChecked(self.db.player.enable)

	local petCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	petCB:SetPoint("LEFT", playerCB.Text, "RIGHT", 20, 0)
	petCB.Text:SetText("Pet")
	petCB:SetChecked(self.db.pet.enable)

	local targetCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	targetCB:SetPoint("TOPLEFT", playerCB, 0, -20)
	targetCB.Text:SetText("Target")
	targetCB:SetChecked(self.db.target.enable)

	local focusCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	focusCB:SetPoint("TOPLEFT", targetCB, 0, -20)
	focusCB.Text:SetText("Focus")
	focusCB:SetChecked(self.db.focus.enable)

	local targettargetCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	targettargetCB:SetPoint("TOPLEFT", focusCB, 0, -20)
	targettargetCB.Text:SetText("Target of Target")
	targettargetCB:SetChecked(self.db.targettarget.enable)

	local partyCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	partyCB:SetPoint("TOPLEFT", targettargetCB, 0, -20)
	partyCB.Text:SetText("Party")
	partyCB:SetChecked(self.db.party.enable)

	local arenaCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	arenaCB:SetPoint("TOPLEFT", partyCB, 0, -20)
	arenaCB.Text:SetText("Arena")
	arenaCB:SetChecked(self.db.arena.enable)

	local bossCB = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	bossCB:SetPoint("TOPLEFT", arenaCB, 0, -20)
	bossCB.Text:SetText("Boss")
	bossCB:SetChecked(self.db.boss.enable)

	local btn = CreateFrame("Button", nil, self.Options, "UIPanelButtonTemplate")
	btn:SetPoint("TOPLEFT", bossCB, 0, -40)
	btn:SetText("Click me")
	btn:SetWidth(100)
	btn:SetScript("OnClick", function()
		print("You clicked me!")
	end)

	category, layout = _G.Settings.RegisterCanvasLayoutCategory(self.Options, self.Options.name, self.Options.name)
	category.ID = self.Options.name
	_G.Settings.RegisterAddOnCategory(category)
end

function BLINKIISPORTRAITS:ToggleOptions()
    Settings.OpenToCategory(category.ID)
end
