local _G = _G
local GetAddOnMetadata = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local ReloadUI = ReloadUI
local strlower = strlower

-- addon name and namespace
local addonName, _ = ...

-- defaults
local defaults = {
	test = true,
	test_tbl = { a = "aaaa", b = "bbb" },
}

-- main function/ db loader
local function OnEvent(self, event, addOnName)
	if event == "ADDON_LOADED" and addOnName == "Blinkiis_Portraits" then
		BlinkiisPortraitsDB = BlinkiisPortraitsDB or {}
		self.db = BlinkiisPortraitsDB
		for k, v in pairs(defaults) do
			if self.db[k] == nil then
				self.db[k] = v
			end
		end

		self:InitializeOptions()
	elseif event == "PLAYER_LOGOUT" then
		BlinkiisPortraitsDB = BLINKIISPORTRAITS.DB
	else
		BLINKIISPORTRAITS:Initialize()
	end
end

-- main frame module
BLINKIISPORTRAITS = CreateFrame("Frame")

BLINKIISPORTRAITS:RegisterEvent("ADDON_LOADED")
BLINKIISPORTRAITS:RegisterEvent("PLAYER_LOGOUT")
BLINKIISPORTRAITS:RegisterEvent("PLAYER_ENTERING_WORLD")
BLINKIISPORTRAITS:SetScript("OnEvent", OnEvent)

-- settings
BLINKIISPORTRAITS.Version = GetAddOnMetadata(addonName, "Version")
BLINKIISPORTRAITS.Name = "Blinkiis Portraits"
BLINKIISPORTRAITS.Icon = "|TInterface\\Addons\\ElvUI_mMediaTag\\media\\logo\\mmt_icon_round.tga:14:14|t"
BLINKIISPORTRAITS.Media = {}
BLINKIISPORTRAITS.Config = {}
BLINKIISPORTRAITS.Portraits = {}

-- slash commands
SLASH_BLINKII1 = "/bp"

SlashCmdList.BLINKII = function(msg, editBox)
	msg = strlower(msg)
	BLINKIISPORTRAITS:Print(msg, editBox)

	if msg == "debug" then
		BLINKIISPORTRAITS:DebugPrintTable(BLINKIISPORTRAITS.db)
	elseif msg == "test" then
		BLINKIISPORTRAITS:TEST()
	else
		BLINKIISPORTRAITS:ToggleOptions()
	end
end

-- reloadui shortcut
if not SlashCmdList.RELOADUI then
	SLASH_RELOADUI1 = "/rl"
	SLASH_RELOADUI2 = "/reloadui"

	SlashCmdList.RELOADUI = ReloadUI
end

-- debug/ default functions
function GetTableLng(tbl)
	local getN = 0
	for n in pairs(tbl) do
		getN = getN + 1
	end
	return getN
end

local function PrintTable(tbl, indent, simple, noFunctions)
	--if not indent then indent = "   " end
	if type(tbl) == "table" then
		for entry, value in pairs(tbl) do
			if (type(value) == "table") and not simple then
				print(indent and indent .. "   " or "", "|cff60ffc3 [" .. entry .. "]|r", value)
				PrintTable(value, indent and indent .. "   " or "   ", true, noFunctions)
			else
				if type(value) == "table" then
					print(indent and indent .. "   " or "", "|cff60ffc3 [" .. entry .. "]|r", " > ", value)
				elseif type(value) == "number" then
					print(indent and indent .. "   " or "", "|cfff5b062 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "string" then
					print(indent and indent .. "   " or "", "|cffd56ef5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) == "boolean" then
					print(
						indent and indent .. "   " or "",
						"|cff96e1ff[" .. entry .. "]|r",
						" = ",
						(value and "|cffabff87true|r" or "|cffff8787false|r")
					)
				elseif (type(value) == "function") and not noFunctions then
					print(indent and indent .. "   " or "", "|cffb5b3f5 [" .. entry .. "]|r", " = ", value)
				elseif type(value) ~= "function" then
					print(indent and indent .. "   " or "", "|cfffbd7f9 [" .. entry .. "]|r", " = ", value)
				end
			end
		end
	else
		print(tostring(tbl))
	end
end

function BLINKIISPORTRAITS:DebugPrintTable(tbl, simple, noFunctions)
	if type(tbl) == "table" then
		local tblLength = GetTableLng(tbl)
		BLINKIISPORTRAITS:Print(
			": Table Start >>>",
			tbl,
			"Entries:",
			tblLength,
			"Options:",
			"Simple:",
			simple,
			"Functions:",
			noFunctions
		)
		PrintTable(tbl, nil, (tblLength > 50), noFunctions)
	else
		BLINKIISPORTRAITS:Print("Not a Table:", tbl)
	end
end

function BLINKIISPORTRAITS:Print(...)
	print(BLINKIISPORTRAITS.Name .. ":", ...)
end

function BLINKIISPORTRAITS:TEST(...)
	-- local unitframes = { "PlayerFrame" }
	-- --_G.PlayerFrame.portrait:Hide()
	-- -- .unit

	-- local frameTexture = _G.PlayerFrame.PlayerFrameContainer.FrameTexture
	-- frameTexture:SetTexture("Interface\\Addons\\Blinkiis_Portraits\\frame.tga")
	-- -- frameTexture:Hide()

	-- -- _G.PlayerFrame.PlayerFrameContainer = textures
	-- -- AlternatePowerFrameTexture
	-- -- FrameFlash
	-- -- FrameTexture
	-- -- PlayerPortrait
	-- -- VehicleFrameTexture
	-- -- PlayerPortraitMask
	-- BLINKIISPORTRAITS:DebugPrintTable(_G.PlayerFrame, nil, true)

	BLINKIISPORTRAITS:Initialize()
end

local unitframesDB = {
	elvui = {
		player = "ElvUF_Player",
		target = "ElvUF_Target",
		pet = "ElvUF_Pet",
		targettarget = "ElvUF_TargetTarget",
		focus = "ElvUF_Focus",
		party = "ElvUF_PartyGroup1UnitButton",
		boss = "ElvUF_Boss",
		arena = "Arena",
	},
	suf = {
		player = "SUFUnitplayer",
		target = "SUFUnittarget",
		pet = "SUFUnitpet",
		targettarget = "SUFUnittargettarget",
		focus = "SUFUnitocus",
		party = "SUFHeaderpartyUnitButton",
		boss = "SUFHeaderboss",
		arena = "SUFHeaderArena",
	},
}

local function UpdatePortrait(frame, event, c, d, e, f)
	BLINKIISPORTRAITS:Print(frame, event, c, d, e, f)
	BLINKIISPORTRAITS:Print("Typ", frame.typ, "Condition", (frame.typ == "target" and event == "PLAYER_TARGET_CHANGED"))
	if
		event == "UNIT_PORTRAIT_UPDATE"
		or event == "PORTRAITS_UPDATED"
		or (frame.typ == "target" and event == "PLAYER_TARGET_CHANGED")
	then
		BLINKIISPORTRAITS:Print(frame.unit)
		SetPortraitTexture(frame.portrait, frame.unit, true)

		if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", unit) end
	end
end

-- portraits
local function CreatePortrait(unitType, unitframes, events)
	local unitFrame = _G[unitframes[unitType]]
	local BPP = BLINKIISPORTRAITS.Portraits

	if not BPP[unitType] and unitFrame then
		local portrait = CreateFrame("Button", "BP_Portrait_" .. unitType, unitFrame, "SecureUnitButtonTemplate")
		portrait.parentFrame = unitFrame
		portrait.unit = unitFrame.unit
		portrait.typ = unitType

		for _, event in ipairs(events) do
			portrait:RegisterEvent(event)
		end

		portrait:SetScript("OnEvent", UpdatePortrait)

		if not InCombatLockdown() then
			portrait:SetSize(64, 64)
			portrait:ClearAllPoints()
			portrait:SetPoint("LEFT", portrait.parentFrame, "RIGHT", 0, 0)
		end

		portrait.texture = portrait:CreateTexture("BP_texture-" .. unitType, "OVERLAY", nil, 4)
		portrait.texture:SetAllPoints(portrait)
		portrait.texture:SetTexture("Interface\\Addons\\Blinkiis_Portraits\\texture.tga", "CLAMP", "CLAMP", "TRILINEAR")

		portrait.portrait = portrait:CreateTexture("BP_portrait-" .. unitType, "OVERLAY", nil, 1)
		portrait.portrait:SetAllPoints(portrait)
		SetPortraitTexture(portrait.portrait, portrait.parentFrame.unit, true)

		portrait.mask = portrait:CreateMaskTexture()
		portrait.mask:SetAllPoints(portrait)
		portrait.mask:SetTexture(
			"Interface\\Addons\\Blinkiis_Portraits\\mask.tga",
			"CLAMPTOBLACKADDITIVE",
			"CLAMPTOBLACKADDITIVE"
		)
		portrait.portrait:AddMaskTexture(portrait.mask)

		-- scripts to interact with mouse
		portrait:SetAttribute("unit", portrait.unit)
		portrait:SetAttribute("*type1", "target")
		portrait:SetAttribute("*type2", "togglemenu")
		portrait:SetAttribute("type3", "focus")
		portrait:SetAttribute("toggleForVehicle", true)
		portrait:SetAttribute("ping-receiver", true)
		portrait:RegisterForClicks("AnyUp")

		BPP[unitType] = portrait
	end
end
function BLINKIISPORTRAITS:Initialize()
	local unitframes = nil
	local events = {
		player = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED" },
		target = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED" },
	}

	if IsAddOnLoaded("ShadowedUnitFrames") then
		unitframes = unitframesDB.suf
	end

	if unitframes then
		CreatePortrait("player", unitframes, events.player)
		CreatePortrait("target", unitframes, events.target)
	end
end
