local ReloadUI = ReloadUI
local strlower = strlower

function BLINKIISPORTRAITS:CMD(msg)
	msg = strlower(msg)


	if msg == "resetdb" then
		BLINKIISPORTRAITS.db = nil
        BlinkiisPortraitsDB = nil
        BLINKIISPORTRAITS:Print("RESET")
	else

		BLINKIISPORTRAITS:ToggleOptions()
	end
end

BLINKIISPORTRAITS:RegisterChatCommand("bp", "CMD")

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end
