function BLINKIISPORTRAITS:InitializeArenaPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.arena.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("arena", BLINKIISPORTRAITS.db.profile.arena.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "ARENA_OPPONENT_UPDATE", "UPDATE_ACTIVE_BATTLEFIELD", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", }

		if BLINKIISPORTRAITS.Retail then tinsert(events, "ARENA_PREP_OPPONENT_SPECIALIZATIONS") end

		for i = 1, 5 do
			local parent = _G[unitframe .. i]

			if parent then
				local unit = "arena" .. i
				local type = "arena"

				portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait(unit, _G[unitframe .. i])

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
					portraits[unit].realUnit = "arena"

					if demo then
						portraits[unit].demo = not portraits[unit].demo
					else
						portraits[unit].demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
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

function BLINKIISPORTRAITS:KillArenaPortrait()
	for i = 1, 5 do
		local unit = "arena" .. i
		if BLINKIISPORTRAITS.Portraits[unit] then
			BLINKIISPORTRAITS:RemovePortrait(BLINKIISPORTRAITS.Portraits[unit])
			BLINKIISPORTRAITS.Portraits[unit] = nil
		end
	end
end
