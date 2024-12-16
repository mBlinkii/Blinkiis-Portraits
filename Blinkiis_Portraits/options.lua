-- options
local category, layout
local UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = UIDropDownMenu_SetText
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local unpack = unpack

local _G = _G

local function CreateCheckButton(parent, point, text, checked, func)
    local checkButton = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkButton:SetPoint(unpack(point))
    checkButton.Text:SetText(text)
    checkButton:SetChecked(checked)
    checkButton:HookScript("OnClick", func)
    return checkButton
end

local function CreateLabel(parent, point, text, size)
    local label = parent:CreateFontString(nil, "ARTWORK", size or "GameFontNormalLarge")
    label:SetPoint(unpack(point))
    label:SetText(text)
    return label
end

local function CreateDropDownMenu(parent, point, value, onChange)
    local dropDown = CreateFrame("FRAME", nil, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint(unpack(point))
    UIDropDownMenu_SetWidth(dropDown, 200)
    UIDropDownMenu_SetText(dropDown, value)

    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self, arg1, arg2, checked)
            onChange(arg1)
            UIDropDownMenu_SetText(dropDown, arg1)
            CloseDropDownMenus()
        end

        info.text, info.arg1, info.checked = "TEXTURE A", "TEXTA", value == "TEXTA"
        UIDropDownMenu_AddButton(info)

        info.text, info.arg1, info.checked = "TEXTURE B", "TEXTB", value == "TEXTB"
        UIDropDownMenu_AddButton(info)
    end)
    return dropDown
end

function BLINKIISPORTRAITS:InitializeOptions()
    self.Options = CreateFrame("Frame")
    self.Options.name = BLINKIISPORTRAITS.Name

    local portraitsLabel = CreateLabel(self.Options, { "TOPLEFT", 10, -10 }, "Portraits Settings")

    local function CreatePortraitOptions(name, point, dbField)
        local checkButton = CreateCheckButton(self.Options, point, name, dbField.enable, function(cb)
            dbField.enable = cb:GetChecked()
            BLINKIISPORTRAITS:InitializePortraits()
        end)

        local extraCheckButton = CreateCheckButton(self.Options, { "LEFT", checkButton.Text, "RIGHT", 30, 0 }, "Rare/Elite", dbField.extra, function(cb)
            dbField.extra = cb:GetChecked()
            BLINKIISPORTRAITS:InitializePortraits()
        end)

        local dropDownMenu = CreateDropDownMenu(self.Options, { "LEFT", extraCheckButton.Text, "RIGHT", 10, 0 }, dbField.texture, function(value)
            dbField.texture = value
        end)
        return checkButton, extraCheckButton, dropDownMenu
    end

    local playerCB, playerExtraCB, playerTexturDD = CreatePortraitOptions("Player", { "TOPLEFT", portraitsLabel, 10, -40 }, self.db.player)
    local petCB, petExtraCB, petTexturDD = CreatePortraitOptions("Pet", { "TOPLEFT", playerCB, 0, -30 }, self.db.pet)
    local targetCB, targetExtraCB, targetDD = CreatePortraitOptions("Target", { "TOPLEFT", petCB, 0, -30 }, self.db.target)
    local focusCB, focusExtraCB, focusDD = CreatePortraitOptions("Focus", { "TOPLEFT", targetCB, 0, -30 }, self.db.focus)
    local targettargetCB, targettargetExtraCB, targettargetDD = CreatePortraitOptions("TargetTarget", { "TOPLEFT", focusCB, 0, -30 }, self.db.targettarget)
    local partyCB, partyExtraCB, partyDD = CreatePortraitOptions("Party", { "TOPLEFT", targettargetCB, 0, -30 }, self.db.party)
    local arenaCB, arenaExtraCB, arenaDD = CreatePortraitOptions("Arena", { "TOPLEFT", partyCB, 0, -30 }, self.db.arena)
    local bossCB, bossExtraCB, bossDD = CreatePortraitOptions("Boss", { "TOPLEFT", arenaCB, 0, -30 }, self.db.boss)

    local extraLabel = CreateLabel(self.Options, { "TOPLEFT", bossCB, -10, -40 }, "Rare/ Elite/ Boss Settings")

    local function CreateExtraOptions(name, point, key)
        local lable = CreateLabel(self.Options, point, name, "GameFontNormal")

        local dropDownMenu = CreateDropDownMenu(self.Options, { "LEFT", lable, "RIGHT", 10, 0 }, self.db.misc[key], function(value)
            BLINKIISPORTRAITS.db.misc[key] = value
        end)
        return lable, dropDownMenu
    end

    local rareLabel, rareDD = CreateExtraOptions("Rare", { "TOPLEFT", extraLabel, 10, -40 }, "rare")
    local eliteLabel, eliteDD = CreateExtraOptions("Elite", { "TOPLEFT", rareLabel, 0, -30 }, "elite")
    local rareeliteLabel, rareeliteDD = CreateExtraOptions("Rare Elite", { "TOPLEFT", eliteLabel, 0, -30 }, "rareelite")
    local bossLabel, bossExtraDD = CreateExtraOptions("Boss", { "TOPLEFT", rareeliteLabel, 0, -30 }, "boss")
    local playerLabel, playerExtraDD = CreateExtraOptions("Player", { "TOPLEFT", bossLabel, 0, -30 }, "player")

    category, layout = _G.Settings.RegisterCanvasLayoutCategory(self.Options, self.Options.name, self.Options.name)
    category.ID = self.Options.name
    _G.Settings.RegisterAddOnCategory(category)
end


function BLINKIISPORTRAITS:ToggleOptions()
	Settings.OpenToCategory(category.ID)
end
