local function OnEvent(portrait, event, eventUnit)
	if (event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE") and portrait.unit ~= eventUnit then return end

	local color, isPlayer, isDead = BLINKIISPORTRAITS:GetUnitColor(portrait.unit)

	portrait.isPlayer = isPlayer

	if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

	local showCastIcon = BLINKIISPORTRAITS:UpdateCastIcon(portrait, event, portrait.db.cast)

	if not showCastIcon then
		SetPortraitTexture(portrait.portrait, portrait.unit, true)
		BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
	end

	BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color)
	BLINKIISPORTRAITS:Mirror(portrait.portrait, isPlayer and portrait.db.mirror)

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= portrait.unit then portrait:SetAttribute("unit", portrait.unit) end
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

function BLINKIISPORTRAITS:KillFocusPortrait()
	if BLINKIISPORTRAITS.Portraits.focus then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.focus)
		BLINKIISPORTRAITS.Portraits.focus = nil
	end
end
