local _G = _G
local ipairs = ipairs
local strmatch = strmatch
local tonumber = tonumber
local UnitClass = UnitClass
local UnitIsUnit = UnitIsUnit
local UnitSex = UnitSex

local C_SpecializationInfo = _G.C_SpecializationInfo
local C_TooltipInfo = _G.C_TooltipInfo
local GetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or _G.GetSpecializationInfo
local GetNumSpecializationsForClassID = C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializationsForClassID or _G.GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID = _G.GetSpecializationInfoForClassID
local GetSpecializationInfoForSpecID = _G.GetSpecializationInfoForSpecID
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec

-- classic talent trees have no specializations
BLINKIISPORTRAITS.SpecIconsSupported = BLINKIISPORTRAITS.Retail and C_TooltipInfo and GetSpecializationInfoForClassID and GetSpecializationInfoForSpecID and true or false

local function SafeValue(value)
	return BLINKIISPORTRAITS:SafeValue(value)
end

local function HasLine(lines, text)
	for _, line in ipairs(lines) do
		if SafeValue(line.leftText) == text then return true end
	end
	return false
end

-- the tooltip of a player reads "<spec> <class>" in the unit's own gender, so only its own class has to be tried
local function GetTooltipSpecID(unit)
	local className, _, classID = UnitClass(unit)
	className, classID = SafeValue(className), SafeValue(classID)
	local sex = SafeValue(UnitSex(unit))
	if not (className and classID and sex) then return nil end

	local data = C_TooltipInfo.GetUnit(unit)
	local lines = data and data.lines
	if not lines then return nil end

	for index = 1, GetNumSpecializationsForClassID(classID) do
		local specID = GetSpecializationInfoForClassID(classID, index)
		local _, specName = GetSpecializationInfoForSpecID(specID, sex)
		if specName and HasLine(lines, specName .. " " .. className) then return specID end
	end
end

-- the own spec comes from the API, arena opponents from the opponent list, everyone else from inspect data or the tooltip
function BLINKIISPORTRAITS:GetUnitSpecID(unit)
	if not (unit and BLINKIISPORTRAITS.SpecIconsSupported) then return nil end

	if SafeValue(UnitIsUnit(unit, "player")) then
		local index = GetSpecialization()
		return index and GetSpecializationInfo(index) or nil
	end

	local arenaIndex = tonumber(strmatch(unit, "^arena(%d)$"))
	if arenaIndex and GetArenaOpponentSpec then
		local specID = SafeValue(GetArenaOpponentSpec(arenaIndex))
		if specID and specID > 0 then return specID end
	end

	local inspected = GetInspectSpecialization and SafeValue(GetInspectSpecialization(unit))
	if inspected and inspected > 0 then return inspected end

	return GetTooltipSpecID(unit)
end

-- a style without a sheet uses the icon the game ships for the specialization
function BLINKIISPORTRAITS:GetSpecIcon(style, specID)
	if style.texture then
		local coords = style.texCoords[specID]
		if coords then return style.texture, coords end
		return nil
	end

	local _, _, _, icon = GetSpecializationInfoByID(specID)
	return icon
end
