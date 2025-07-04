local UnitGUID = UnitGUID
local UnitExists = UnitExists

local function OnEvent(portrait, event, eventUnit)
	local unit = portrait.isCellParentFrame and portrait.parentFrame._unit or portrait.parentFrame.unit
	unit = (portrait.demo and not UnitExists(unit)) and "player" or unit
	unit = (unit == portrait.type) and "player" or unit

	if not unit or not UnitExists(unit) or ((event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_HEALTH") and unit ~= eventUnit) then return end

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

		BLINKIISPORTRAITS:UpdatePortrait(portrait, event, unit)
		BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.extra)

		portrait.forceUpdate = false
	else
		BLINKIISPORTRAITS:UpdatePortrait(portrait, event, unit)
	end

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
end

function BLINKIISPORTRAITS:InitializeArenaPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.arena.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("arena", BLINKIISPORTRAITS.db.profile.arena.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events =
			{ "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_NAME_UPDATE", "UPDATE_ACTIVE_BATTLEFIELD", "GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE" }

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
					portraits[unit].func = OnEvent

					if demo then
						portraits[unit].demo = not portraits[unit].demo
					else
						portraits[unit].demo = BLINKIISPORTRAITS.SUF and not ShadowUF.db.profile.locked
					end

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
