local targetTargetEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "UNIT_TARGET", "PLAYER_TARGET_CHANGED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }

--- Creates or updates the target-of-target portrait based on the current profile settings.
function BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
	if not BLINKIISPORTRAITS.db.profile.targettarget.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("targettarget", BLINKIISPORTRAITS.db.profile.targettarget.unitframe)
	local parent = unitframe and BLINKIISPORTRAITS:ResolveFrame(unitframe)
	if not parent then return end

	BLINKIISPORTRAITS:SetupUnitPortrait({
		key = "targettarget",
		type = "targettarget",
		parent = parent,
		parentFrame = parentFrame,
		unitOverride = BLINKIISPORTRAITS.EQOL and "targettarget" or nil,
		events = targetTargetEvents,
	})
end

--- Removes the target-of-target portrait.
function BLINKIISPORTRAITS:KillTargetTargetPortrait()
	BLINKIISPORTRAITS:KillPortrait("targettarget")
end
