local petEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE", "UNIT_EXITING_VEHICLE", "UNIT_ENTERED_VEHICLE" }

--- Creates or updates the pet portrait based on the current profile settings.
function BLINKIISPORTRAITS:InitializePetPortrait()
	if not BLINKIISPORTRAITS.db.profile.pet.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("pet", BLINKIISPORTRAITS.db.profile.pet.unitframe)
	local parent = unitframe and BLINKIISPORTRAITS:ResolveFrame(unitframe)
	if not parent then return end

	BLINKIISPORTRAITS:SetupUnitPortrait({
		key = "pet",
		type = "pet",
		parent = parent,
		parentFrame = parentFrame,
		unitOverride = BLINKIISPORTRAITS.EQOL and "pet" or nil,
		events = petEvents,
	})
end

--- Removes the pet portrait.
function BLINKIISPORTRAITS:KillPetPortrait()
	BLINKIISPORTRAITS:KillPortrait("pet")
end
