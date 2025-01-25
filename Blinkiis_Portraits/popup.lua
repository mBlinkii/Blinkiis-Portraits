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

  StaticPopupDialogs["BLINKIISPORTRAITS_DELETE_ICON"] = {
    text = "Are you sure you want to delete this |cffff0000%s|r icon?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        BLINKIISPORTRAITS.db.global.custom_classicons[data] = nil
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
