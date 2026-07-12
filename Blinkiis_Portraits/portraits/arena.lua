local tinsert = tinsert

local arenaEvents = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "ARENA_OPPONENT_UPDATE", "UPDATE_ACTIVE_BATTLEFIELD", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE" }
if BLINKIISPORTRAITS.Retail then tinsert(arenaEvents, "ARENA_PREP_OPPONENT_SPECIALIZATIONS") end

--- Creates or updates the arena portraits (arena1-arena5) based on the current profile settings.
-- @param demo toggles the demo mode of the portraits
function BLINKIISPORTRAITS:InitializeArenaPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.arena.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("arena", BLINKIISPORTRAITS.db.profile.arena.unitframe)
	if not unitframe then return end

	for i = 1, 5 do
		local parent = BLINKIISPORTRAITS:ResolveFrame(unitframe .. i)

		if parent then
			BLINKIISPORTRAITS:SetupUnitPortrait({
				key = "arena" .. i,
				type = "arena",
				parent = parent,
				parentFrame = parentFrame,
				events = arenaEvents,
				isGroup = true,
				demo = demo,
			})
		end
	end
end

--- Removes all arena portraits.
function BLINKIISPORTRAITS:KillArenaPortrait()
	for i = 1, 5 do
		BLINKIISPORTRAITS:KillPortrait("arena" .. i)
	end
end
