function BLINKIISPORTRAITS:CMD(msg)
	msg = strlower(msg)

	if msg == "debug" then
		BLINKIISPORTRAITS:DebugPrintTable(BLINKIISPORTRAITS.db)
	elseif msg == "test" then
		BLINKIISPORTRAITS:TEST()
	elseif msg == "reset" then
		BLINKIISPORTRAITS.db = nil
        BlinkiisPortraitsDB = nil
        BLINKIISPORTRAITS:Print("RESET")
	else
        BLINKIISPORTRAITS:Print("uff")
		--BLINKIISPORTRAITS:ToggleOptions()
	end
end

BLINKIISPORTRAITS:RegisterChatCommand("bp", "CMD")

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end
