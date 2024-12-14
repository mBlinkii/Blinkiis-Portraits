local function OnEvent(frame, event, eventUnit)
	-- #F85D0AFF
	BLINKIISPORTRAITS:DebugPrint(frame, event, eventUnit, "|CFFF85D0A")

	local color = BLINKIISPORTRAITS:GetUnitColor(frame.unit)

	if color then frame.texture:SetVertexColor(color.a.r, color.a.g, color.a.b, color.a.a or 1) end

	SetPortraitTexture(frame.portrait, frame.unit, true)

	if not InCombatLockdown() and frame:GetAttribute("unit") ~= frame.unit then frame:SetAttribute("unit", frame.unit) end
end

function BLINKIISPORTRAITS:InitTargetPortrait(parentFrame)
	local events = { "UNIT_PORTRAIT_UPDATE", "PORTRAITS_UPDATED", "PLAYER_TARGET_CHANGED" }

	if BLINKIISPORTRAITS.db.target.enable then
		BLINKIISPORTRAITS:CreatePortrait("target", parentFrame, BLINKIISPORTRAITS.db.target, "target")

		-- update textures
		local textureFiles = {
			textureFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
			bgFile = "Interface\\Addons\\Blinkiis_Portraits\\blank.tga",
			maskFile = "Interface\\Addons\\Blinkiis_Portraits\\mask.tga",
			rareFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
			eliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
			rareeliteFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
			bossFile = "Interface\\Addons\\Blinkiis_Portraits\\texture.tga",
		}

		if _G.BP_Portrait_target then
			for key, value in pairs(textureFiles) do
				_G.BP_Portrait_target[key] = value
			end

			BLINKIISPORTRAITS:UpdateTextures(_G.BP_Portrait_target)

			BLINKIISPORTRAITS:RegisterEvents(_G.BP_Portrait_target, events)

			_G.BP_Portrait_target:SetScript("OnEvent", OnEvent)
		end
	elseif _G.BP_Portrait_target then
		BLINKIISPORTRAITS:RemovePortrait(_G.BP_Portrait_target, events)
	end
end
