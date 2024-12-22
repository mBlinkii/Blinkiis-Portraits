local function OnEvent(portrait, event, eventUnit)
	if (event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE") and portrait.unit ~= eventUnit then return end

	local unit = portrait.unit or portrait.parentFrame.unit

	if event == "UNIT_PET" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then
		unit = (UnitInVehicle("player") and UnitHasVehiclePlayerFrameUI("player")) and "player" or "pet"
	end

	portrait.unit = unit

	local color, isPlayer, isDead = BLINKIISPORTRAITS:GetUnitColor(portrait.unit)

	portrait.isPlayer = isPlayer

	if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

	local showCastIcon = BLINKIISPORTRAITS:UpdateCastIcon(portrait, event, portrait.db.cast)

	if not showCastIcon then
		SetPortraitTexture(portrait.portrait, portrait.unit, true)
		BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
	end

	BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.extra)
	BLINKIISPORTRAITS:Mirror(portrait.portrait, isPlayer and portrait.db.mirror)

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= portrait.unit then portrait:SetAttribute("unit", portrait.unit) end
end

function BLINKIISPORTRAITS:InitializePetPortrait()
	if not BLINKIISPORTRAITS.db.profile.pet.enable then return end

	local unitframe = BLINKIISPORTRAITS:GetUnitFrames("pet")
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_PET", "UNIT_EXITED_VEHICLE", "PET_UI_UPDATE" }
		local parent = _G[unitframe]
		local unit = "pet"
		local type = "pet"

		portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("pet", _G[unitframe])

		portraits[unit].events = {}
		portraits[unit].parentFrame = parent
		portraits[unit].unit = parent.unit
		portraits[unit].type = type
		portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
		portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
		portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
		portraits[unit].func = OnEvent

		BLINKIISPORTRAITS:UpdateSettings(portraits[unit], BLINKIISPORTRAITS.db.profile[type])
		BLINKIISPORTRAITS:UpdateTexturesFiles(portraits[unit], BLINKIISPORTRAITS.db.profile[type])
		BLINKIISPORTRAITS:UpdateSize(portraits[unit])
		BLINKIISPORTRAITS:UpdateCastSettings(portraits[unit])

		BLINKIISPORTRAITS:InitPortrait(portraits[unit], events)
	end
end

function BLINKIISPORTRAITS:KillPetPortrait()
	if BLINKIISPORTRAITS.Portraits.pet then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.pet)
		BLINKIISPORTRAITS.Portraits.pet = nil
	end
end
