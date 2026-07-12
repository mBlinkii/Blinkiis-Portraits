local focusEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PLAYER_FOCUS_CHANGED" }

--- Creates or updates the focus portrait based on the current profile settings.
function BLINKIISPORTRAITS:InitializeFocusPortrait()
	if not BLINKIISPORTRAITS.db.profile.focus.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("focus", BLINKIISPORTRAITS.db.profile.focus.unitframe)
	local parent = unitframe and BLINKIISPORTRAITS:ResolveFrame(unitframe)
	if not parent then return end

	BLINKIISPORTRAITS:SetupUnitPortrait({
		key = "focus",
		type = "focus",
		parent = parent,
		parentFrame = parentFrame,
		unitOverride = BLINKIISPORTRAITS.EQOL and "focus" or nil,
		events = focusEvents,
	})
end

--- Removes the focus portrait.
function BLINKIISPORTRAITS:KillFocusPortrait()
	BLINKIISPORTRAITS:KillPortrait("focus")
end
