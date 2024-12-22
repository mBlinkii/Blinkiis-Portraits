local function OnEvent(portrait, event, eventUnit)
	if (event == "PORTRAITS_UPDATED" or event == "UNIT_PORTRAIT_UPDATE") and portrait.unit ~= eventUnit then return end

	portrait.unit = portrait.parentFrame.unit
	local unit = portrait.unit == portrait.type and "player" or portrait.unit

	if not unit then return end

	-- #F85D0AFF
	BLINKIISPORTRAITS:DebugPrint(portrait, event, eventUnit, "|CFFF85D0A")

	local color, isPlayer, isDead = BLINKIISPORTRAITS:GetUnitColor(unit)

	portrait.isPlayer = isPlayer

	if color then portrait.texture:SetVertexColor(color.r, color.g, color.b, color.a or 1) end

	local showCastIcon = BLINKIISPORTRAITS:UpdateCastIcon(portrait, event, portrait.db.cast)

	if not showCastIcon then
		SetPortraitTexture(portrait.portrait, unit, true)
		BLINKIISPORTRAITS:UpdateDesaturated(portrait, isDead)
	end

	BLINKIISPORTRAITS:UpdateExtraTexture(portrait, portrait.db.unitcolor and color, portrait.db.extra)
	BLINKIISPORTRAITS:Mirror(portrait.portrait, isPlayer and portrait.db.mirror)

	if not InCombatLockdown() and portrait:GetAttribute("unit") ~= unit then portrait:SetAttribute("unit", unit) end
end

function BLINKIISPORTRAITS:InitializeArenaPortrait()
	if not BLINKIISPORTRAITS.db.profile.arena.enable then return end

	if BLINKIISPORTRAITS.SUF and ShadowUF then
		if not BLINKIISPORTRAITS.SUF_Arena_Hook then
			hooksecurefunc(ShadowUF, "LoadUnits", BLINKIISPORTRAITS.InitializeArenaPortrait)

			BLINKIISPORTRAITS.SUF_Arena_Hook = true
		end
	end

	local unitframe = BLINKIISPORTRAITS:GetUnitFrames("arena")
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_NAME_UPDATE", "UPDATE_ACTIVE_BATTLEFIELD", "GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE" }

		for i = 1, 5 do
			local parent = _G[unitframe .. i]
			local unit = "arena" .. i
			local type = "arena"

			portraits[unit] = portraits[unit] or BLINKIISPORTRAITS:CreatePortrait(unit, _G[unitframe .. i])

			if portraits[unit] then
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
			else
				-- #F90505FF
				BLINKIISPORTRAITS:Print("|CFFF90505ERROR|r", "CANT CREATE", unit)
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
