local function HookHeaderUnitChanges(parent)
	if parent._bpUnitHooked then return end
	parent._bpUnitHooked = true

	parent:HookScript("OnAttributeChanged", function(self, name)
		if name ~= "unit" then return end

		local portrait = self._bpPortrait
		if not portrait then return end

		local onEvent = portrait:GetScript("OnEvent")
		if onEvent then onEvent(portrait, "ForceUpdate") end
	end)
end

local function SetupPartyPortrait(portraits, key, parent, parentFrame, events, demo)
	local type = "party"
	local db = BLINKIISPORTRAITS.db.profile
	if not db then return end

	portraits[key] = BLINKIISPORTRAITS:EnsurePortrait(key, key, parent)

	local portrait = portraits[key]
	if not portrait then return end

	if db[type].unitframe ~= "auto" then portrait:SetParent(parent) end

	local isCellParentFrame = (parentFrame == "cell") and BLINKIISPORTRAITS.Cell
	local isHeaderUnit = (parentFrame == "eui")

	if isHeaderUnit then
		parent._bpPortrait = portrait
		HookHeaderUnitChanges(parent)
	end

	portrait.events = {}
	portrait.parentFrame = parent
	portrait.isCellParentFrame = isCellParentFrame
	portrait.isHeaderUnit = isHeaderUnit
	portrait.unit = (isCellParentFrame and parent._unit) or (isHeaderUnit and parent:GetAttribute("unit")) or parent.unit
	portrait.type = type
	portrait.db = db[type]
	portrait.size = db[type].size
	portrait.point = db[type].point
	portrait.useClassIcon = db.misc.class_icon ~= "none"
	portrait.realUnit = "party"

	if demo then
		portrait.demo = not portrait.demo
	elseif BLINKIISPORTRAITS.SUF then
		portrait.demo = not ShadowUF.db.profile.locked
	end

	portrait.isPlayer = nil
	portrait.unitClass = nil
	portrait.lastGUID = nil

	BLINKIISPORTRAITS:UpdateTexturesFiles(portrait, db[type])
	BLINKIISPORTRAITS:UpdateSize(portrait)
	BLINKIISPORTRAITS:UpdateCastSettings(portrait)

	BLINKIISPORTRAITS:InitPortrait(portrait, events)
end

function BLINKIISPORTRAITS:InitializePartyPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.party.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if unitframe then
		local portraits = BLINKIISPORTRAITS.Portraits
		local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_MODEL_CHANGED", "UNIT_CONNECTION", "PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE", "GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "UNIT_NAME_UPDATE"}

		for i = 1, 5 do
			local parent = parentFrame == "bbf" and _G.PartyFrame[unitframe .. i] or _G[unitframe .. i]

			if parent then
				SetupPartyPortrait(portraits, "party" .. i, parent, parentFrame, events, demo)
			end
		end

		-- EllesmereUI helper
		if parentFrame == "eui" then
			local selfButton = _G.ERFPartySelfButton
			if selfButton then
				SetupPartyPortrait(portraits, "partyself", selfButton, parentFrame, events, demo)
			end
		end
	end
end

local function ReleasePartyPortrait(key)
	local portrait = BLINKIISPORTRAITS.Portraits[key]
	if not portrait then return end

	if portrait.parentFrame and portrait.parentFrame._bpPortrait == portrait then
		portrait.parentFrame._bpPortrait = nil
	end

	BLINKIISPORTRAITS:RemovePortrait(portrait)
	BLINKIISPORTRAITS.Portraits[key] = nil
end

function BLINKIISPORTRAITS:KillPartyPortrait()
	for i = 1, 5 do
		ReleasePartyPortrait("party" .. i)
	end

	ReleasePartyPortrait("partyself")
end
