local UnitGUID = UnitGUID

local function OnEvent(portrait, event, eventUnit)
	local unit = portrait.unit
	if not unit or not UnitExists(unit) or ((event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_HEALTH") and unit ~= eventUnit) then return end

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

		BLINKIISPORTRAITS:UpdatePortrait(portrait, event)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color)

		portrait.forceUpdate = false
	else
		BLINKIISPORTRAITS:UpdatePortrait(portrait, event)
	end

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
end

function BLINKIISPORTRAITS:InitializeFocusPortrait()
	if not BLINKIISPORTRAITS.db.profile.focus.enable then return end

	local unitframe = BLINKIISPORTRAITS:GetUnitFrames("focus")
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_FOCUS_CHANGED", "GROUP_ROSTER_UPDATE" }
		local parent = _G[unitframe]
		local unit = "focus"
		local type = "focus"

		portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("focus", _G[unitframe])

		if portraits[unit] then
			portraits[unit].events = {}
			portraits[unit].parentFrame = parent
			portraits[unit].unit = BLINKIISPORTRAITS.Cell and parent._unit or parent.unit
			portraits[unit].type = type
			portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
			portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
			portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
			portraits[unit].useClassIcon = BLINKIISPORTRAITS.db.profile.misc.class_icon ~= "none"
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

function BLINKIISPORTRAITS:KillFocusPortrait()
	if BLINKIISPORTRAITS.Portraits.focus then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.focus)
		BLINKIISPORTRAITS.Portraits.focus = nil
	end
end
