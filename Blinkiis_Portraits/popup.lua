local ReloadUI = ReloadUI

StaticPopupDialogs["BLINKIISPORTRAITS_RL"] = {
    text = "Some settings require you to reload the interface. Do you want to do that now?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }

  StaticPopupDialogs["BLINKIISPORTRAITS_PROFILE_EXISTS"] = {
    text = "Profile Exists, Overwrite?",
    button1 = "Yes",
    button2 = "No",
    OnShow = function (self, data)
        print(data)
        self.editBox:SetText(data)
    end,
    OnAccept = function (self, data, data2)
        local text = self.editBox:GetText()
        -- do whatever you want with it
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
