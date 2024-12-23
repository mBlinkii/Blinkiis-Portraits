local ReloadUI = ReloadUI
local strlower = strlower

function BLINKIISPORTRAITS:CMD(msg)
	LibStub("AceConfigDialog-3.0"):Open("BLINKIISPORTRAITS")
end

BLINKIISPORTRAITS:RegisterChatCommand("bp", "CMD")

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end
