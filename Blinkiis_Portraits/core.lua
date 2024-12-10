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
	if event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or (frame.typ == "target" and event == "PLAYER_TARGET_CHANGED") then
		BLINKIISPORTRAITS:Print(frame.unit)
		SetPortraitTexture(frame.portrait, frame.unit, true)
	end
end
function BLINKIISPORTRAITS:Initialize()
	local unitframes = nil
	local events = {
		player = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED" },
		target = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED"},
	}
	local BPP = BLINKIISPORTRAITS.Portraits

	if IsAddOnLoaded("ShadowedUnitFrames") then
		unitframes = unitframesDB.suf
	end

	if unitframes then
		if not BPP.player then
			BPP.player = CreateFrame("Button", "BP_Portrait_" .. "Player", _G[unitframes.player], "SecureUnitButtonTemplate")
			BPP.player.parentFrame = _G[unitframes.player]
			BPP.player.unit = _G[unitframes.player].unit
			BPP.player.typ = "player"

			BPP.player:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			BPP.player:RegisterEvent("PORTRAITS_UPDATED")

			BPP.player:SetScript("OnEvent", UpdatePortrait)

			for _, event in ipairs(events.player) do
				BPP.player:RegisterEvent(event)
			end

			if not InCombatLockdown() then
				BPP.player:SetSize(64, 64)
				BPP.player:ClearAllPoints()
				BPP.player:SetPoint("LEFT", BPP.player.parentFrame, "RIGHT", 0, 0)
			end

			BPP.player.texture = BPP.player:CreateTexture("BP_" .. "texture" .. "-" .. "Player", "OVERLAY", nil, 4)
			BPP.player.texture:SetAllPoints(BPP.player)
			BPP.player.texture:SetTexture(
				"Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
				"CLAMP",
				"CLAMP",
				"TRILINEAR"
			)

			BPP.player.portrait = BPP.player:CreateTexture("BP_" .. "portrait" .. "-" .. "Player", "OVERLAY", nil, 1)
			BPP.player.portrait:SetAllPoints(BPP.player)
			SetPortraitTexture(BPP.player.portrait, BPP.player.parentFrame.unit, true)

			BPP.player.mask = BPP.player:CreateMaskTexture()
			BPP.player.mask:SetAllPoints(BPP.player)
			BPP.player.mask:SetTexture(
				"Interface\\Addons\\Blinkiis_Portraits\\mask.tga",
				"CLAMPTOBLACKADDITIVE",
				"CLAMPTOBLACKADDITIVE"
			)
			BPP.player.portrait:AddMaskTexture(BPP.player.mask)
		end

		if not BPP.target then
			BPP.target = CreateFrame("Button", "BP_Portrait_" .. "Target", _G[unitframes.target], "SecureUnitButtonTemplate")
			BPP.target.parentFrame = _G[unitframes.target]
			BPP.target.unit = _G[unitframes.target].unit
			BPP.target.typ = "target"

			BPP.target:RegisterEvent("UNIT_PORTRAIT_UPDATE")
			BPP.target:RegisterEvent("PORTRAITS_UPDATED")

			BPP.target:SetScript("OnEvent", UpdatePortrait)

			for _, event in ipairs(events.target) do
				BPP.target:RegisterEvent(event)
			end

			if not InCombatLockdown() then
				BPP.target:SetSize(64, 64)
				BPP.target:ClearAllPoints()
				BPP.target:SetPoint("LEFT", BPP.target.parentFrame, "RIGHT", 0, 0)
			end

			BPP.target.texture = BPP.target:CreateTexture("BP_" .. "texture" .. "-" .. "Target", "OVERLAY", nil, 4)
			BPP.target.texture:SetAllPoints(BPP.target)
			BPP.target.texture:SetTexture(
				"Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
				"CLAMP",
				"CLAMP",
				"TRILINEAR"
			)

			BPP.target.portrait = BPP.target:CreateTexture("BP_" .. "portrait" .. "-" .. "Target", "OVERLAY", nil, 1)
			BPP.target.portrait:SetAllPoints(BPP.target)
			SetPortraitTexture(BPP.target.portrait, BPP.target.parentFrame.unit, true)

			BPP.target.mask = BPP.target:CreateMaskTexture()
			BPP.target.mask:SetAllPoints(BPP.target)
			BPP.target.mask:SetTexture(
				"Interface\\Addons\\Blinkiis_Portraits\\mask.tga",
				"CLAMPTOBLACKADDITIVE",
				"CLAMPTOBLACKADDITIVE"
			)
			BPP.target.portrait:AddMaskTexture(BPP.target.mask)
		end
	end
end
