local function OnEvent(frame, event, eventUnit)
	if (event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE") and frame.unit ~= eventUnit then return end

	local unit = frame.unit

	if event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then unit = UnitInVehicle("player") and UnitHasVehiclePlayerFrameUI("player") and "pet" or "player" end

	frame.unit = unit
	-- #F8A10AFF
	BLINKIISPORTRAITS:DebugPrint(frame, event, eventUnit, "|CFFF8A10A")

	local color = BLINKIISPORTRAITS:GetUnitColor(frame.unit)

	if color then frame.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

	SetPortraitTexture(frame.portrait, frame.unit, true)

	BLINKIISPORTRAITS:UpdateExtraTexture(frame, BLINKIISPORTRAITS.db.player.extra)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
end

function BLINKIISPORTRAITS:InitPlayerPortrait(parentFrame)
	local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_ENTERED_VEHICLE", "UNIT_EXITING_VEHICLE", "UNIT_EXITED_VEHICLE" }
	BLINKIISPORTRAITS:InitPortrait("player", parentFrame, BLINKIISPORTRAITS.db.player, events, OnEvent)
end
