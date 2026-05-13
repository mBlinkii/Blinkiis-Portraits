local ReloadUI = ReloadUI
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local function GetPopupEditBox(frame)
	return frame and (frame.editBox or frame.EditBox)
end

StaticPopupDialogs["BLINKIISPORTRAITS_RL"] = {
	text = L["Some settings require you to reload the interface. Do you want to do that now?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["BLINKIISPORTRAITS_DELETE_ICON"] = {
	text = L["Are you sure you want to delete this |cffff0000%s|r icon?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, data)
		BLINKIISPORTRAITS.db.global.custom_classicons[data] = nil
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["BLINKIISPORTRAITS_EDITBOX"] = {
	text = BLINKIISPORTRAITS.Name,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		local editBox = GetPopupEditBox(self)
		if not editBox then return end

		editBox:SetAutoFocus(false)
		editBox.width = editBox:GetWidth()
		editBox:SetWidth(280)
		editBox:AddHistoryLine("text")
		editBox.temptxt = data
		editBox:SetText(data)
		editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		local editBox = GetPopupEditBox(self)
		if not editBox then return end

		editBox:SetWidth(editBox.width or 50)
		editBox.width = nil
		editBox.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self.temptxt and self:GetText() ~= self.temptxt then self:SetText(self.temptxt) end

		self:HighlightText()
	end,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}
