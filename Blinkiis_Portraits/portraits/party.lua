local _G = _G

local MAX_PARTY_MEMBERS = 5

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

-- keeps the unit filtered events on the button when a header reorders the group
local function HookParentUnitChanges(parent)
	if parent._bpUnitHooked then return end
	parent._bpUnitHooked = true

	parent:HookScript("OnAttributeChanged", function(self, name)
		if name ~= "unit" then return end

		local portrait = self._bpPortrait
		if not portrait then return end

		portrait.unit = BLINKIISPORTRAITS:ResolvePortraitUnit(portrait)
		BLINKIISPORTRAITS:ApplyUnitEvents(portrait)

		local onEvent = portrait:GetScript("OnEvent")
		if onEvent then onEvent(portrait, "ForceUpdate") end
	end)
end

-- nil while the button does not exist yet, header frames create them on demand
local function ResolvePartyParent(unitframe, parentFrame, index)
	if parentFrame == "bbf" then
		local partyFrame = _G.PartyFrame
		return partyFrame and partyFrame[unitframe .. index]
	end

	return BLINKIISPORTRAITS:ResolveFrame(unitframe .. index)
end

-- some layouts put the player next to the party frames instead of into them (EllesmereUI, UUF)
local function ResolvePartySelfFrame(parentFrame)
	local name = BLINKIISPORTRAITS:GetUnitFrameName("partyself", parentFrame)
	return name and BLINKIISPORTRAITS:ResolveFrame(name) or nil
end

local function IsPortraitOutdated(key, parent)
	local portrait = BLINKIISPORTRAITS.Portraits[key]
	return (not portrait) or (portrait.parentFrame ~= parent)
end

local function SetupPartyPortrait(key, parent, parentFrame, unitFallback, demo)
	local portrait = BLINKIISPORTRAITS:SetupUnitPortrait({
		key = key,
		type = "party",
		parent = parent,
		parentFrame = parentFrame,
		events = partyEvents,
		isGroup = true,
		isDynamicUnit = true,
		demo = demo,
		unitFallback = unitFallback,
	})

	if portrait then
		parent._bpPortrait = portrait
		HookParentUnitChanges(parent)
	end
end

function BLINKIISPORTRAITS:HasPendingPartyPortraits()
	if not BLINKIISPORTRAITS.db.profile.party.enable then return false end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if not unitframe then return false end

	for i = 1, MAX_PARTY_MEMBERS do
		local parent = ResolvePartyParent(unitframe, parentFrame, i)
		if parent and IsPortraitOutdated("party" .. i, parent) then return true end
	end

	local selfFrame = ResolvePartySelfFrame(parentFrame)
	if selfFrame and IsPortraitOutdated("partyself", selfFrame) then return true end

	return false
end

function BLINKIISPORTRAITS:InitializePartyPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.party.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if not unitframe then return end

	for i = 1, MAX_PARTY_MEMBERS do
		local parent = ResolvePartyParent(unitframe, parentFrame, i)

		-- only a fallback, a header may assign a different unit to this button
		if parent then SetupPartyPortrait("party" .. i, parent, parentFrame, "party" .. i, demo) end
	end

	local selfFrame = ResolvePartySelfFrame(parentFrame)
	if selfFrame then SetupPartyPortrait("partyself", selfFrame, parentFrame, "player", demo) end
end

function BLINKIISPORTRAITS:KillPartyPortrait()
	for i = 1, MAX_PARTY_MEMBERS do
		BLINKIISPORTRAITS:KillPortrait("party" .. i)
	end

	BLINKIISPORTRAITS:KillPortrait("partyself")
end
