function BLINKIISPORTRAITS:InitializeTargetPortrait()
	if not BLINKIISPORTRAITS.db.profile.target.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("target", BLINKIISPORTRAITS.db.profile.target.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PLAYER_TARGET_CHANGED" }
		local parent = _G[unitframe]

		if parent then
			local unit = "target"
			local type = "target"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("target", _G[unitframe])

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
				portraits[unit].realUnit = "target"

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

function BLINKIISPORTRAITS:KillTargetPortrait()
	if BLINKIISPORTRAITS.Portraits.target then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.target)
		BLINKIISPORTRAITS.Portraits.target = nil
	end
end
