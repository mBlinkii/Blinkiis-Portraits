function BLINKIISPORTRAITS:InitializePartyPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.party.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PARTY_MEMBER_ENABLE", "GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", }

		for i = 1, 5 do
			local parent = _G[unitframe .. i]

			if parent then
				local unit = "party" .. i
				local type = "party"

				portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait(unit, parent)

				if portraits[unit] then
					if BLINKIISPORTRAITS.db.profile[type].unitframe ~= "auto" then portraits[unit]:SetParent(_G[unitframe .. i]) end
					local isCellParentFrame = (parentFrame == "cell") and BLINKIISPORTRAITS.Cell
					portraits[unit].events = {}
					portraits[unit].parentFrame = parent
					portraits[unit].isCellParentFrame = isCellParentFrame
					portraits[unit].unit = isCellParentFrame and parent._unit or parent.unit
					portraits[unit].type = type
					portraits[unit].db = BLINKIISPORTRAITS.db.profile[type]
					portraits[unit].size = BLINKIISPORTRAITS.db.profile[type].size
					portraits[unit].point = BLINKIISPORTRAITS.db.profile[type].point
					portraits[unit].useClassIcon = BLINKIISPORTRAITS.db.profile.misc.class_icon ~= "none"
					portraits[unit].realUnit = "party"

					if demo then
						portraits[unit].demo = not portraits[unit].demo
					elseif BLINKIISPORTRAITS.SUF then
						portraits[unit].demo = not ShadowUF.db.profile.locked
					end

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
end

function BLINKIISPORTRAITS:KillPartyPortrait()
	for i = 1, 5 do
		local unit = "party" .. i
		if BLINKIISPORTRAITS.Portraits[unit] then
			BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits[unit])
			BLINKIISPORTRAITS.Portraits[unit] = nil
		end
	end
end
