BLINKIISPORTRAITS.unitFrames = {
		elvui = {
			player = "ElvUF_Player",
			target = "ElvUF_Target",
			pet = "ElvUF_Pet",
			targettarget = "ElvUF_TargetTarget",
			focus = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Focus",
			party = "ElvUF_PartyGroup1UnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "ElvUF_Boss",
			arena = "ElvUF_Arena",
		},
		suf = {
			player = "SUFUnitplayer",
			target = "SUFUnittarget",
			pet = "SUFUnitpet",
			targettarget = "SUFUnittargettarget",
			focus = BLINKIISPORTRAITS.Classic and nil or "SUFUnitfocus",
			party = "SUFHeaderpartyUnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "SUFHeaderbossUnitButton",
			arena = "SUFHeaderarenaUnitButton",
		},
		cell = {
			player = BLINKIISPORTRAITS.Cell_UF and "CUF_Player",
			target = BLINKIISPORTRAITS.Cell_UF and "CUF_Target",
			pet = BLINKIISPORTRAITS.Cell_UF and "CUF_Pet",
			targettarget = BLINKIISPORTRAITS.Cell_UF and "CUF_TargetTarget",
			focus = BLINKIISPORTRAITS.Classic and nil or (BLINKIISPORTRAITS.Cell_UF and "CUF_Focus"),
			party = "CellPartyFrameHeaderUnitButton",
			boss = BLINKIISPORTRAITS.Cell_UF and "CUF_Boss",
			arena = BLINKIISPORTRAITS.Cell_UF and "CUF_Arena",
		},
		pb4 = {
			singleUnits = function()
				local PitBull4 = _G.PitBull4
				local PB4_SingleUnits = PitBull4.db.profile.units
				local validSingleUnits = {
					player = true,
					target = true,
					pet = true,
					targettarget = true,
					focus = BLINKIISPORTRAITS.Classic and nil or true,
				}

				local frames = {}
				for singleName, value in pairs(PB4_SingleUnits) do
					if value and validSingleUnits[value.unit] then frames[value.unit] = "PitBull4_Frames_" .. singleName end
				end
				return frames
			end,
			groupUnits = function()
				local PitBull4 = _G.PitBull4
				local PB4_GroupUnits = PitBull4.db.profile.groups
				local validGroupUnits = {
					party = true,
					boss = BLINKIISPORTRAITS.Classic and nil or true,
					arena = BLINKIISPORTRAITS.Classic and nil or true,
				}

				local frames = {}
				for groupName, value in pairs(PB4_GroupUnits) do
					if value and validGroupUnits[value.unit_group] then frames[value.unit_group] = format("PitBull4_Groups_%sUnitButton", groupName) end
				end
				return frames
			end,
		},
		uuf = {
			player = "UUF_Player",
			target = "UUF_Target",
			pet = "UUF_Pet",
			targettarget = "UUF_TargetTarget",
			focus = "UUF_Focus",
			party = nil, -- uff has no party frames
			boss = "UUF_Boss",
			arena = nil, -- uff has no arena frames
		},
		ndui = {
			player = "oUF_Player",
			target = "oUF_Target",
			pet = "oUF_Pet",
			targettarget = "oUF_ToT",
			focus = BLINKIISPORTRAITS.Classic and nil or "oUF_Focus",
			party = "oUF_PartyUnitButton",
			boss = BLINKIISPORTRAITS.Classic and nil or "oUF_Boss",
			arena = BLINKIISPORTRAITS.Classic and nil or "oUF_Arena",
		},
        eqol = {
			player = "EQOLUFPlayerFrame",
			target = "EQOLUFTargetFrame",
			pet = "EQOLUFPetFrame",
			targettarget = "EQOLUFToTFrame",
			focus = "EQOLUFFocusFrame",
			party = nil,
			boss = "EQOLUFBoss",
			arena = nil,
		},
	}
