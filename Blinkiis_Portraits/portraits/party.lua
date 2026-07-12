local _G = _G

local partyEvents = {
	"UNIT_PORTRAIT_UPDATE",
	"PORTRAITS_UPDATED",
	"UNIT_MODEL_CHANGED",
	"UNIT_CONNECTION",
	"PARTY_MEMBER_ENABLE",
	"PARTY_MEMBER_DISABLE",
	"GROUP_ROSTER_UPDATE",
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	"UNIT_NAME_UPDATE",
}

-- forwards "unit" attribute changes of header-based frames (EllesmereUI) to the portrait
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

local function SetupPartyPortrait(key, parent, parentFrame, demo)
	local isHeaderUnit = (parentFrame == "eui")

	local portrait = BLINKIISPORTRAITS:SetupUnitPortrait({
		key = key,
		type = "party",
		parent = parent,
		parentFrame = parentFrame,
		events = partyEvents,
		isGroup = true,
		demo = demo,
		isHeaderUnit = isHeaderUnit,
		cellFlag = BLINKIISPORTRAITS.Cell,
	})

	if portrait and isHeaderUnit then
		parent._bpPortrait = portrait
		HookHeaderUnitChanges(parent)
	end
end

--- Creates or updates the party portraits (party1-party5) based on the current profile settings.
-- @param demo toggles the demo mode of the portraits
function BLINKIISPORTRAITS:InitializePartyPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.party.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if not unitframe then return end

	for i = 1, 5 do
		local parent = (parentFrame == "bbf") and _G.PartyFrame[unitframe .. i] or BLINKIISPORTRAITS:ResolveFrame(unitframe .. i)

		if parent then SetupPartyPortrait("party" .. i, parent, parentFrame, demo) end
	end

	-- EllesmereUI helper
	if parentFrame == "eui" then
		local selfButton = _G.ERFPartySelfButton
		if selfButton then SetupPartyPortrait("partyself", selfButton, parentFrame, demo) end
	end
end

--- Removes all party portraits.
function BLINKIISPORTRAITS:KillPartyPortrait()
	for i = 1, 5 do
		BLINKIISPORTRAITS:KillPortrait("party" .. i)
	end

	BLINKIISPORTRAITS:KillPortrait("partyself")
end
