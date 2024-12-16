local function OnEvent(frame, event, eventUnit)
	if (event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE") and frame.unit ~= eventUnit then return end
	-- #F85D0AFF
	BLINKIISPORTRAITS:DebugPrint(frame, event, eventUnit, "|CFFF85D0A")

	local color = BLINKIISPORTRAITS:GetUnitColor(frame.unit)

	if color then frame.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

	SetPortraitTexture(frame.portrait, frame.unit, true)
	BLINKIISPORTRAITS:UpdateExtraTexture(frame)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
end

function BLINKIISPORTRAITS:InitTargetPortrait(parentFrame)
    local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED" }
    BLINKIISPORTRAITS:InitPortrait("target", parentFrame, BLINKIISPORTRAITS.db.target, events, OnEvent)
end
