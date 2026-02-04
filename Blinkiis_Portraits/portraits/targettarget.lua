function BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
	if not BLINKIISPORTRAITS.db.profile.targettarget.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("targettarget", BLINKIISPORTRAITS.db.profile.targettarget.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "UNIT_TARGET", "PLAYER_TARGET_CHANGED" }
		local parent = _G[unitframe]

		if parent then
			local unit = "targettarget"
			local type = "targettarget"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("targettarget", _G[unitframe])

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
				portraits[unit].realUnit = "targettarget"

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

function BLINKIISPORTRAITS:KillTargetTargetPortrait()
	if BLINKIISPORTRAITS.Portraits.targettarget then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.targettarget)
		BLINKIISPORTRAITS.Portraits.targettarget = nil
	end
end
