local playerEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "UNIT_ENTERED_VEHICLE", "UNIT_EXITING_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE" }

--- Creates or updates the player portrait based on the current profile settings.
function BLINKIISPORTRAITS:InitializePlayerPortrait()
	if not BLINKIISPORTRAITS.db.profile.player.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("player", BLINKIISPORTRAITS.db.profile.player.unitframe)
	local parent = unitframe and BLINKIISPORTRAITS:ResolveFrame(unitframe)
	if not parent then return end

	BLINKIISPORTRAITS:SetupUnitPortrait({
		key = "player",
		type = "player",
		parent = parent,
		parentFrame = parentFrame,
		unitOverride = BLINKIISPORTRAITS.EQOL and "player" or nil,
		events = playerEvents,
	})
end

--- Removes the player portrait.
function BLINKIISPORTRAITS:KillPlayerPortrait()
	BLINKIISPORTRAITS:KillPortrait("player")
end
