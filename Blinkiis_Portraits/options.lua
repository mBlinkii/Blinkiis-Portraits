-- options
local category, layout
local _G = _G
function BLINKIISPORTRAITS:InitializeOptions()
	self.Options = CreateFrame("Frame")
	self.Options.name = BLINKIISPORTRAITS.Name

	local cb = CreateFrame("CheckButton", nil, self.Options, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", 20, -20)
	cb.Text:SetText("Print when you jump")
	-- there already is an existing OnClick script that plays a sound, hook it
	cb:HookScript("OnClick", function(_, btn, down)
		self.db.test = cb:GetChecked()
	end)
	cb:SetChecked(self.db.test)

	local btn = CreateFrame("Button", nil, self.Options, "UIPanelButtonTemplate")
	btn:SetPoint("TOPLEFT", cb, 0, -40)
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
