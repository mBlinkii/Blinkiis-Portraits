function BLINKIISPORTRAITS:InitializePlayerPortrait()
	if not BLINKIISPORTRAITS.db.profile.player.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("player", BLINKIISPORTRAITS.db.profile.player.unitframe)

	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "UNIT_ENTERED_VEHICLE", "UNIT_EXITING_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_UPDATE" }
		local parent = _G[unitframe]

		if parent then
			local unit = "player"
			local type = "player"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait("player", _G[unitframe])

			if portraits[unit] then
				if BLINKIISPORTRAITS.db.profile[type].unitframe ~= "auto" then portraits[unit]:SetParent(_G[unitframe]) end
				local isCellParentFrame = (parentFrame == "cell") and BLINKIISPORTRAITS.Cell_UF
				portraits[unit].events = {}
				portraits[unit].parentFrame = parent
				portraits[unit].isCellParentFrame = isCellParentFrame
				portraits[unit].unit = isCellParentFrame and parent._unit or (BLINKIISPORTRAITS.EQOL and unit or parent.unit)
				portraits[unit].type = type -- frameType or frame.type
				portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
				portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
				portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
				portraits[unit].useClassIcon = BLINKIISPORTRAITS.db.profile.misc.class_icon ~= "none"
				portraits[unit].demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
				portraits[unit].realUnit = "player"

				portraits[unit].isPlayer = nil
				portraits[unit].unitClass = nil
				portraits[unit].lastGUID = nil

				BLINKIISPORTRAITS:UpdateTexturesFiles(portraits[unit], BLINKIISPORTRAITS.db.profile[type])
				BLINKIISPORTRAITS:UpdateSize(portraits[unit])
				BLINKIISPORTRAITS:UpdateCastSettings(portraits[unit])

				BLINKIISPORTRAITS:InitPortrait(portraits[unit], events)
			end
		end
	end
end

function BLINKIISPORTRAITS:KillPlayerPortrait()
	if BLINKIISPORTRAITS.Portraits.player then
		BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits.player)
		BLINKIISPORTRAITS.Portraits.player = nil
	end
end
