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

-- Resolves the parent unit button of a party index for the given unit frame addon.
-- Returns nil while the button does not exist yet (header-based frames create them on demand).
local function ResolvePartyParent(unitframe, parentFrame, index)
	if parentFrame == "bbf" then
		local partyFrame = _G.PartyFrame
		return partyFrame and partyFrame[unitframe .. index]
	end

	return BLINKIISPORTRAITS:ResolveFrame(unitframe .. index)
end

-- Resolves the optional standalone player frame of a party layout (EllesmereUI, UUF), which sits
-- next to the party frames instead of being one of them. Returns nil if the addon has none or if
-- the frame is disabled in its settings.
local function ResolvePartySelfFrame(parentFrame)
	local name = BLINKIISPORTRAITS:GetUnitFrameName("partyself", parentFrame)
	return name and BLINKIISPORTRAITS:ResolveFrame(name) or nil
end

-- True if no portrait exists for the key yet, or if it is attached to a different unit button.
local function IsPortraitOutdated(key, parent)
	local portrait = BLINKIISPORTRAITS.Portraits[key]
	return (not portrait) or (portrait.parentFrame ~= parent)
end

local function SetupPartyPortrait(key, parent, parentFrame, unitFallback, demo)
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
		unitFallback = unitFallback,
		cellFlag = BLINKIISPORTRAITS.Cell,
	})

	if portrait and isHeaderUnit then
		parent._bpPortrait = portrait
		HookHeaderUnitChanges(parent)
	end
end

--- Returns true if a party unit button exists that has no up to date portrait.
-- Header-based unit frame addons (EllesmereUI, Cell, EQOL, ...) create their unit buttons lazily,
-- so buttons appearing after login need a portrait without re-running the full initialization.
-- @return true if InitializePartyPortrait has work to do
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

--- Creates or updates the party portraits (party1-party5) based on the current profile settings.
-- @param demo toggles the demo mode of the portraits
function BLINKIISPORTRAITS:InitializePartyPortrait(demo)
	if not BLINKIISPORTRAITS.db.profile.party.enable then return end

	local unitframe, parentFrame = BLINKIISPORTRAITS:GetUnitFrames("party", BLINKIISPORTRAITS.db.profile.party.unitframe)
	if not unitframe then return end

	for i = 1, MAX_PARTY_MEMBERS do
		local parent = ResolvePartyParent(unitframe, parentFrame, i)

		-- the party token is only a fallback; a header may assign a different unit to this button
		if parent then SetupPartyPortrait("party" .. i, parent, parentFrame, "party" .. i, demo) end
	end

	-- standalone player frame of the party layout, if the addon has one
	local selfFrame = ResolvePartySelfFrame(parentFrame)
	if selfFrame then SetupPartyPortrait("partyself", selfFrame, parentFrame, "player", demo) end
end

--- Removes all party portraits.
function BLINKIISPORTRAITS:KillPartyPortrait()
	for i = 1, MAX_PARTY_MEMBERS do
		BLINKIISPORTRAITS:KillPortrait("party" .. i)
	end

	BLINKIISPORTRAITS:KillPortrait("partyself")
end
