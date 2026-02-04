function BLINKIISPORTRAITS:InitializeFocusPortrait()
	if not BLINKIISPORTRAITS.db.profile.focus.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("focus", BLINKIISPORTRAITS.db.profile.focus.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PLAYER_FOCUS_CHANGED" }
		local parent = _G[unitframe]

		if parent then
			local unit = "focus"
			local type = "focus"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("focus", _G[unitframe])

			if portraits[unit] then
				if BLINKIISPORTRAITS.db.profile[type].unitframe ~= "auto" then portraits[unit]:SetParent(_G[unitframe]) end
				local isCellParentFrame = (parentFrame == "cell") and BLINKIISPORTRAITS.Cell_UF
				portraits[unit].events = {}
				portraits[unit].parentFrame = parent
				portraits[unit].isCellParentFrame = isCellParentFrame
				portraits[unit].unit = isCellParentFrame and parent._unit or parent.unit
				portraits[unit].type = type
				portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
				portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
				portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
				portraits[unit].useClassIcon = BLINKIISPORTRAITS.db.profile.misc.class_icon ~= "none"
				portraits[unit].demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
				portraits[unit].realUnit = "focus"

				portraits[unit].isPlayer = nil
				portraits[unit].unitClass = nil

				BLINKIISPORTRAITS:UpdateTexturesFiles(portraits[unit], BLINKIISPORTRAITS.db.profile[type])
				BLINKIISPORTRAITS:UpdateSize(portraits[unit])
				BLINKIISPORTRAITS:UpdateCastSettings(portraits[unit])

				BLINKIISPORTRAITS:InitPortrait(portraits[unit], events)
			end
		end
	end
end

function BLINKIISPORTRAITS:KillFocusPortrait()
	if BLINKIISPORTRAITS.Portraits.focus then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.focus)
		BLINKIISPORTRAITS.Portraits.focus = nil
	end
end
