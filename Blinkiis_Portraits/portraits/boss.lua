local format = format

local bossEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_TARGETABLE_CHANGED", "INSTANCE_ENCOUNTER_ENGAGE_UNIT" }

--- Creates or updates the boss portraits (boss1-boss5) based on the current profile settings.
-- @param demo toggles the demo mode of the portraits
function BLINKIISPORTRAITS:InitializeBossPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.boss.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("boss", BLINKIISPORTRAITS.db.profile.boss.unitframe)
	local isEQOL_Frame = parentFrame == "eqol" and BLINKIISPORTRAITS.EQOL

	if not (unitframe or isEQOL_Frame) then return end

	for i = 1, 5 do
		local frameName = isEQOL_Frame and format("%s%sFrame", unitframe, i) or (unitframe .. i)
		local parent = BLINKIISPORTRAITS:ResolveFrame(frameName)

		if parent then
			BLINKIISPORTRAITS:SetupUnitPortrait({
				key = "boss" .. i,
				type = "boss",
				parent = parent,
				parentFrame = parentFrame,
				events = bossEvents,
				isGroup = true,
				demo = demo,
			})
		end
	end
end

--- Removes all boss portraits.
function BLINKIISPORTRAITS:KillBossPortrait()
	for i = 1, 5 do
		BLINKIISPORTRAITS:KillPortrait("boss" .. i)
	end
end
