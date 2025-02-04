local UnitGUID = UnitGUID
local UnitExists = UnitExists

local function OnEvent(portrait, event, eventUnit, arg2)
	local unit = (portrait.demo and not UnitExists(portrait.parentFrame.unit)) and "player" or (portrait.unit or portrait.parentFrame.unit)

	if not unit or not UnitExists(unit) or ((event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_HEALTH") and unit ~= eventUnit) then return end

	if event == "VEHICLE_UPDATE" or event == "UNIT_EXITING_VEHICLE" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then
		unit = (UnitInVehicle("player") and arg2) and "player" or "pet"
	end

	portrait.unit = unit

	if event == "UNIT_HEALTH" then
		portrait.isDead = BLINKIISPORTRAITS:UpdateDeathStatus(unit)
		return
	end

	local guid = UnitGUID(unit)
	if portrait.lastGUID ~= guid or portrait.forceUpdate then
		local color, isPlayer, class = BLINKIISPORTRAITS:GetUnitColor(unit, portrait.isDead)

		portrait.isPlayer = isPlayer
		portrait.unitClass = class
		portrait.lastGUID = guid

		if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

		BLINKIISPORTRAITS:UpdatePortrait(portrait, event, portrait.demo and unit)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.forceExtra)

		portrait.forceUpdate = false
	else
		BLINKIISPORTRAITS:UpdatePortrait(portrait, event, portrait.demo and unit)
	end

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
end

function BLINKIISPORTRAITS:InitializePetPortrait()
	if not BLINKIISPORTRAITS.db.profile.pet.enable then return end

	local unitframe = BLINKIISPORTRAITS:GetUnitFrames("pet")
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_PET", "UNIT_EXITED_VEHICLE", "PET_UI_UPDATE", "VEHICLE_UPDATE" }
		local parent = _G[unitframe]

		if parent then
			local unit = "pet"
			local type = "pet"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("pet", _G[unitframe])

			if portraits[unit] then
				portraits[unit].events = {}
				portraits[unit].parentFrame = parent
				portraits[unit].unit = BLINKIISPORTRAITS.Cell and parent._unit or parent.unit
				portraits[unit].type = type
				portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
				portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
				portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
				portraits[unit].useClassIcon = BLINKIISPORTRAITS.db.profile.misc.class_icon ~= "none"
				portraits[unit].demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
				portraits[unit].func = OnEvent

				portraits[unit].isPlayer = nil
				portraits[unit].unitClass = nil
				portraits[unit].lastGUID = nil
				portraits[unit].forceUpdate = true

				BLINKIISPORTRAITS:UpdateTexturesFiles(portraits[unit], BLINKIISPORTRAITS.db.profile[type])
				BLINKIISPORTRAITS:UpdateSize(portraits[unit])
				BLINKIISPORTRAITS:UpdateCastSettings(portraits[unit])

				BLINKIISPORTRAITS:InitPortrait(portraits[unit], events)
			end
		end
	end
end

function BLINKIISPORTRAITS:KillPetPortrait()
	if BLINKIISPORTRAITS.Portraits.pet then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.pet)
		BLINKIISPORTRAITS.Portraits.pet = nil
	end
end
