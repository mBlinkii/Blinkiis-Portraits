local function OnEvent(frame, event, eventUnit)
	local unit = frame.unit

	if event == "UNIT_EXITED_VEHICLE" or event == "PET_UI_UPDATE" then unit = UnitInVehicle("player") and UnitHasVehiclePlayerFrameUI("player") and "pet" or "player" end

	frame.unit = unit
	-- #F8A10AFF
	BLINKIISPORTRAITS:DebugPrint(frame, event, eventUnit, "|CFFF8A10A")

	local color = BLINKIISPORTRAITS:GetUnitColor(frame.unit)

	if color then
		frame.texture:SetVertexColor(color.a.r, color.a.g, color.a.b, color.a.a or 1)
	end

	SetPortraitTexture(frame.portrait, frame.unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
end

function BLINKIISPORTRAITS:InitPlayerPortrait(parentFrame)
	local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "UNIT_ENTERED_VEHICLE", "UNIT_EXITING_VEHICLE", "UNIT_EXITED_VEHICLE" }

	if BLINKIISPORTRAITS.db.player.enable then
		BLINKIISPORTRAITS:CreatePortrait("player", parentFrame, BLINKIISPORTRAITS.db.player, "player")

		-- update textures
		local textureFiles = {
			textureFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
			bgFile = "Interface\\Addons\\Blinkiis_Portraits\\blank.tga",
			maskFile = "Interface\\Addons\\Blinkiis_Portraits\\mask.tga",
			extraMaskFile = "Interface\\Addons\\Blinkiis_Portraits\\extramask.tga",
			rareFile = "Interface\\Addons\\Blinkiis_Portraits\\rare.tga",
			eliteFile = "Interface\\Addons\\Blinkiis_Portraits\\elite.tga",
			rareeliteFile = "Interface\\Addons\\Blinkiis_Portraits\\rareelite.tga",
			bossFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
		}

		if _G.BP_Portrait_player then
			for key, value in pairs(textureFiles) do
				_G.BP_Portrait_player[key] = value
			end

			BLINKIISPORTRAITS:UpdateTextures(_G.BP_Portrait_player)

			BLINKIISPORTRAITS:RegisterEvents(_G.BP_Portrait_player, events)

			_G.BP_Portrait_player:SetScript("OnEvent", OnEvent)
		end
	elseif _G.BP_Portrait_player then
		BLINKIISPORTRAITS:RemovePortrait(_G.BP_Portrait_player, events)
	end
end
