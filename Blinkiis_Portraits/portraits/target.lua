local targetEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PLAYER_TARGET_CHANGED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }

--- Creates or updates the target portrait based on the current profile settings.
function BLINKIISPORTRAITS:InitializeTargetPortrait()
	if not BLINKIISPORTRAITS.db.profile.target.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("target", BLINKIISPORTRAITS.db.profile.target.unitframe)
	local parent = unitframe and BLINKIISPORTRAITS:ResolveFrame(unitframe)
	if not parent then return end

	BLINKIISPORTRAITS:SetupUnitPortrait({
		key = "target",
		type = "target",
		parent = parent,
		parentFrame = parentFrame,
		unitOverride = BLINKIISPORTRAITS.EQOL and "target" or nil,
		events = targetEvents,
	})
end

--- Removes the target portrait.
function BLINKIISPORTRAITS:KillTargetPortrait()
	BLINKIISPORTRAITS:KillPortrait("target")
end
