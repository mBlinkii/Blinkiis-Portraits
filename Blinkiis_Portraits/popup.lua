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
