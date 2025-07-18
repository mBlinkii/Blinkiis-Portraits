local CopyTable = CopyTable
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local L = LibStub("AceLocale-3.0"):GetLocale("Blinkiis_Portraits", true)

local credits = {
	"Huchang47",
	"Cbogolin",
}

local form = {
	blizz = L["Blizz"],
	blizz_up = L["Blizz Up"],
	circle = L["Circle"],
	diagonal = L["Diagonal"],
	diagonal_mirror = L["Diagonal Mirror"],
	diamond = L["Diamond"],
	drop = L["Drop"],
	drop_mirror = L["Drop Mirror"],
	drop_side = L["Drop side"],
	drop_side_mirror = L["Drop side Mirror"],
	egg = L["Egg"],
	hexa = L["Hexa"],
	pad = L["Pad"],
	page = L["Page"],
	page_mirror = L["Page Mirror"],
	square = L["Square"],
	square_round = L["Square Round"],
	oval = L["Oval"],
}
local extra = {
	extra_a = L["Extra A"],
	extra_b = L["Extra B"],
	extra_c = L["Extra C"],
	extra_d = L["Extra D"],
	extra_e = L["Extra E"],
	extra_f = L["Extra F"],
	extra_g = L["Extra G"],
	extra_h = L["Extra H"],
	extra_i = L["Extra I"],
	extra_j = L["Extra J"],
	extra_k = L["Extra K"],
	extra_l = L["Extra L"],
	extra_m = L["Extra M"],

	animal = L["Animal"],
	dragon_a = L["Dragon A"],
	dragon_b = L["Dragon B"],
	fire = L["Fire"],
	leaf = L["Leaf"],
	micro = L["Micro"],
	misc = L["Misc"],
	pen = L["Pen"],
	star = L["Star"],

	egg_dragon = L["Egg Dragon"],
	egg_leaf = L["Egg Leaf"],
	egg_micro = L["Egg Micro"],

	pad_animal = L["Pad Animal"],
	pad_dragon = L["Pad Dragon"],
	pad_dragon_b = L["Pad Dragon B"],
	pad_fire = L["Pad Fire"],
	pad_leaf = L["Pad Leaf"],
	pad_micro = L["Pad Micro"],
	pad_misc = L["Pad Misc"],
	pad_pen = L["Pad Pen"],
	pad_star = L["Pad Star"],

	page_dragon_a = L["Page Dragon A"],
	page_dragon_b = L["Page Dragon B"],

	blizz_gold = L["Blizz Gold"],
	blizz_silver = L["Blizz Silver"],
	blizz_boss = L["Blizz Boss"],
	blizz_neutral = L["Blizz Neutral"],
	blizz_boss_neutral = L["Blizz Boss Neutral"],
}

local frameStrata = {
	BACKGROUND = L["BACKGROUND"],
	LOW = L["LOW"],
	MEDIUM = L["MEDIUM"],
	HIGH = L["HIGH"],
	DIALOG = L["DIALOG"],
	TOOLTIP = L["TOOLTIP"],
	AUTO = L["AUTO"],
}

local custom_classicons = {
	selected = nil,
	name = nil,
	path = nil,
	texCoords = nil,
}

local parentFrames = {
	elvui = "ElvUI",
	suf = "Shadowed Unit Frames",
	pb4 = "PitBull 4",
	cell = "Cell",
	uuf = "Unhalted Unit Frames",
	ndui = "NDui",
	auto = L["AUTO"],
}

local exportProfile = {
	author = nil,
	name = nil,
	version = nil,
	bp_version = nil,
	profile = nil,
}

local exportString = nil
local importInfos = {
	author = nil,
	name = nil,
	version = nil,
	bp_version = nil,
	profile = nil,
}

local function copyTable(src, dest)
	if type(dest) ~= "table" then dest = {} end
	if type(src) == "table" then
		for k, v in pairs(src) do
			if type(v) == "table" then
				-- try to index the key first so that the metatable creates the defaults, if set, and use that table
				v = copyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest
end

StaticPopupDialogs["BLINKIISPORTRAITS_PROFILE_EXISTS"] = {
	text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(frame, data)
		if importInfos and importInfos.success then
			BLINKIISPORTRAITS.db.profiles[importInfos.name] = copyTable(BLINKIISPORTRAITS.defaults)
			copyTable(importInfos.profile, BLINKIISPORTRAITS.db.profiles[importInfos.name])
			BLINKIISPORTRAITS.db:SetProfile(importInfos.name)

			importInfos = {}
		end
	end,
	EditBoxOnTextChanged = function(frame)
		local validInput = frame:GetText() ~= ""
		frame:GetParent().button1:SetEnabled(validInput)
		importInfos.name = validInput and frame:GetText() or importInfos.name
	end,
	OnShow = function(frame, data)
		frame.editBox:SetText(data)
		frame.editBox:SetFocus()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

BLINKIISPORTRAITS.options = {
	name = BLINKIISPORTRAITS.Name,
	handler = BLINKIISPORTRAITS,
	type = "group",
	childGroups = "tab",
	args = {
		general_group = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				misc_group = {
					order = 1,
					type = "group",
					inline = true,
					name = L["Misc"],
					args = {
						zoom_range = {
							order = 1,
							name = L["Zoom/ Offset"],
							type = "range",
							min = -1,
							max = 1,
							step = 0.001,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.zoom
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.zoom = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						enable_force_desaturate = {
							order = 2,
							type = "toggle",
							name = L["Desaturate"],
							desc = L["Will always desaturate the portraits."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.desaturate
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.desaturate = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
					},
				},
				custom_textures_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["Custom Textures"],
					args = {
						enable_custom_textures_toggle = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							desc = L["Enable Custom Textures for Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.enable
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.enable = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						description = {
							order = 2,
							type = "description",
							name = L["Put your custom textures in the Addon folder and add the path here (example MyMediaFolder\\MyTexture.tga)."],
						},
						texture_input = {
							order = 3,
							name = L["Texture"],
							type = "input",
							width = "smal",
							disabled = function()
								return not BLINKIISPORTRAITS.db.profile.custom.enable
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.texture = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						mask_input = {
							order = 4,
							name = L["Mask"],
							type = "input",
							width = "smal",
							disabled = function()
								return not BLINKIISPORTRAITS.db.profile.custom.enable
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.mask
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.mask = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						extra_mask_input = {
							order = 5,
							name = L["Extra Mask"],
							type = "input",
							width = "smal",
							disabled = function()
								return not BLINKIISPORTRAITS.db.profile.custom.enable
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.extra_mask
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.extra_mask = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						space_description = {
							order = 6,
							type = "description",
							name = "\n\n",
						},
						enable_custom_extra_toggle = {
							order = 7,
							type = "toggle",
							name = L["Custom Extra Texture"],
							desc = L["Enable Custom extra Textures for Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.extra = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						rare_input = {
							order = 8,
							name = L["Rare"],
							type = "input",
							width = "smal",
							disabled = function()
								return not (BLINKIISPORTRAITS.db.profile.custom.enable and BLINKIISPORTRAITS.db.profile.custom.extra)
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.rare
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.rare = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						elite_input = {
							order = 9,
							name = L["Elite"],
							type = "input",
							width = "smal",
							disabled = function()
								return not (BLINKIISPORTRAITS.db.profile.custom.enable and BLINKIISPORTRAITS.db.profile.custom.extra)
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.elite
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.elite = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						rareelite_input = {
							order = 10,
							name = L["Rare Elite"],
							type = "input",
							width = "smal",
							disabled = function()
								return not (BLINKIISPORTRAITS.db.profile.custom.enable and BLINKIISPORTRAITS.db.profile.custom.extra)
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.rareelite
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.rareelite = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						boss_input = {
							order = 11,
							name = L["Boss"],
							type = "input",
							width = "smal",
							disabled = function()
								return not (BLINKIISPORTRAITS.db.profile.custom.enable and BLINKIISPORTRAITS.db.profile.custom.extra)
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.boss
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.boss = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
						player_input = {
							order = 12,
							name = L["Player"],
							type = "input",
							width = "smal",
							disabled = function()
								return not (BLINKIISPORTRAITS.db.profile.custom.enable and BLINKIISPORTRAITS.db.profile.custom.extra)
							end,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.custom.player
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.custom.player = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
					},
				},
			},
		},
		player_group = {
			order = 3,
			type = "group",
			name = L["Player"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Player Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.player.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.player.enable = value

						if value then
							BLINKIISPORTRAITS:InitializePlayerPortrait()
						else
							BLINKIISPORTRAITS:KillPlayerPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.texture = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.size = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.cast = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Player Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.extra = value
								BLINKIISPORTRAITS.db.profile.player.forceExtra = value and "player" or "none"
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.unitcolor = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.unitframe = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.player.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.player.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.player.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.player.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.player.point.point = value
									BLINKIISPORTRAITS.db.profile.player.mirror = false
								end

								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.point.x = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.point.y = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.strata = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.level = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
					},
				},
			},
		},
		target_group = {
			order = 4,
			type = "group",
			name = L["Target"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Target Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.target.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.target.enable = value

						if value then
							BLINKIISPORTRAITS:InitializeTargetPortrait()
						else
							BLINKIISPORTRAITS:KillTargetPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.texture = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.size = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.cast = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Target Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.extra = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.unitcolor = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						force_extra_toggle = {
							order = 6,
							type = "select",
							name = L["Force Extra Texture"],
							desc = L["It will override the default extra texture, but will take care of rare/elite/boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.forceExtra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.forceExtra = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
							values = {
								none = L["None"],
								player = L["Player"],
								rare = L["Rare"],
								elite = L["Elite"],
								rareelite = L["Rare Elite"],
								boss = L["Boss"],
							},
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.unitframe = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.target.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.target.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.target.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.target.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.target.point.point = value
									BLINKIISPORTRAITS.db.profile.target.mirror = false
								end

								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.point.x = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.point.y = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.strata = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.level = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
					},
				},
			},
		},
		focus_group = {
			order = 5,
			type = "group",
			name = L["Focus"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Focus Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.focus.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.focus.enable = value

						if value then
							BLINKIISPORTRAITS:InitializeFocusPortrait()
						else
							BLINKIISPORTRAITS:KillFocusPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.texture = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.size = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.cast = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Focus Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.extra = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.unitcolor = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						force_extra_toggle = {
							order = 6,
							type = "select",
							name = L["Force Extra Texture"],
							desc = L["It will override the default extra texture, but will take care of rare/elite/boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.forceExtra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.forceExtra = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
							values = {
								none = L["None"],
								player = L["Player"],
								rare = L["Rare"],
								elite = L["Elite"],
								rareelite = L["Rare Elite"],
								boss = L["Boss"],
							},
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.unitframe = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.focus.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.focus.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.focus.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.focus.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.focus.point.point = value
									BLINKIISPORTRAITS.db.profile.focus.mirror = false
								end

								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.point.x = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.point.y = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.strata = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.level = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
					},
				},
			},
		},
		targettarget_group = {
			order = 6,
			type = "group",
			name = L["Target of Target"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Target of Target Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.targettarget.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.targettarget.enable = value

						if value then
							BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
						else
							BLINKIISPORTRAITS:KillTargetTargetPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.texture = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.size = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.cast = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Target of Target Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.extra = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.unitcolor = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						force_extra_toggle = {
							order = 6,
							type = "select",
							name = L["Force Extra Texture"],
							desc = L["It will override the default extra texture, but will take care of rare/elite/boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.forceExtra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.forceExtra = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
							values = {
								none = L["None"],
								player = L["Player"],
								rare = L["Rare"],
								elite = L["Elite"],
								rareelite = L["Rare Elite"],
								boss = L["Boss"],
							},
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.unitframe = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.targettarget.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.targettarget.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.targettarget.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.targettarget.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.targettarget.point.point = value
									BLINKIISPORTRAITS.db.profile.targettarget.mirror = false
								end

								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.point.x = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.point.y = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.strata = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.level = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
					},
				},
			},
		},
		pet_group = {
			order = 7,
			type = "group",
			name = L["Pet"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Pet Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.pet.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.pet.enable = value

						if value then
							BLINKIISPORTRAITS:InitializePetPortrait()
						else
							BLINKIISPORTRAITS:KillPetPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.texture = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.size = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.cast = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Pet Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.extra = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.unitcolor = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						force_extra_toggle = {
							order = 6,
							type = "select",
							name = L["Force Extra Texture"],
							desc = L["It will override the default extra texture, but will take care of rare/elite/boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.forceExtra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.forceExtra = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
							values = {
								none = L["None"],
								player = L["Player"],
								rare = L["Rare"],
								elite = L["Elite"],
								rareelite = L["Rare Elite"],
								boss = L["Boss"],
							},
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.unitframe = value
								BLINKIISPORTRAITS:InitializePetPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.pet.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.pet.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.pet.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.pet.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.pet.point.point = value
									BLINKIISPORTRAITS.db.profile.pet.mirror = false
								end

								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.point.x = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.point.y = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.strata = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.level = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
					},
				},
			},
		},
		party_group = {
			order = 8,
			type = "group",
			name = L["Party"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Party Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.party.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.party.enable = value

						if value then
							BLINKIISPORTRAITS:InitializePartyPortrait()
						else
							BLINKIISPORTRAITS:KillPartyPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.texture = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.size = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.cast = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Party Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.extra = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.unitcolor = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						force_extra_toggle = {
							order = 6,
							type = "select",
							name = L["Force Extra Texture"],
							desc = L["It will override the default extra texture, but will take care of rare/elite/boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.forceExtra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.forceExtra = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
							values = {
								none = L["None"],
								player = L["Player"],
								rare = L["Rare"],
								elite = L["Elite"],
								rareelite = L["Rare Elite"],
								boss = L["Boss"],
							},
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.unitframe = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.party.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.party.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.party.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.party.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.party.point.point = value
									BLINKIISPORTRAITS.db.profile.party.mirror = false
								end

								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.point.x = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.point.y = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.strata = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.level = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
					},
				},
			},
		},
		boss_group = {
			order = 9,
			type = "group",
			name = L["Boss"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Boss Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.boss.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.boss.enable = value

						if value then
							BLINKIISPORTRAITS:InitializeBossPortrait()
						else
							BLINKIISPORTRAITS:KillBossPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.texture = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.size = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.cast = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Boss Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.extra = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.unitcolor = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.unitframe = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.boss.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.boss.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.boss.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.boss.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.boss.point.point = value
									BLINKIISPORTRAITS.db.profile.boss.mirror = false
								end

								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.point.x = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.point.y = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.strata = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.level = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
					},
				},
			},
		},
		arena_group = {
			order = 10,
			type = "group",
			name = L["Arena"],
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable Arena Portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.arena.enable
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.arena.enable = value

						if value then
							BLINKIISPORTRAITS:InitializeArenaPortrait()
						else
							BLINKIISPORTRAITS:KillArenaPortrait()
						end
					end,
				},
				general_group = {
					order = 2,
					type = "group",
					inline = true,
					name = L["General"],
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = L["Style"],
							desc = L["Select a portrait texture style."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.texture
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.texture = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
							values = form,
						},
						size_range = {
							order = 2,
							name = L["Size"],
							type = "range",
							min = 16,
							max = 512,
							step = 1,
							softMin = 16,
							softMax = 512,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.size
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.size = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
						cast_toggle = {
							order = 3,
							type = "toggle",
							name = L["Cast Icon"],
							desc = L["Enable Cast Icons."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.cast = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
						extra_toggle = {
							order = 4,
							type = "toggle",
							name = L["Enable Extra Texture"],
							desc = L["Shows the Extra Texture (rare/elite) for the Arena Portrait."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.extra = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
						unitcolor_toggle = {
							order = 5,
							type = "toggle",
							name = L["Unitcolor for Extra"],
							desc = L["Use the unit color for the Extra (Rare/Elite) Texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.unitcolor
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.unitcolor = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = L["Anchor"],
					args = {
						frame_select = {
							order = 1,
							type = "select",
							name = L["Parent Frame"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.unitframe
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.unitframe = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
							values = parentFrames,
						},
						anchor_select = {
							order = 2,
							type = "select",
							name = L["Anchor Point"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.point.relativePoint
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.point.relativePoint = value
								if value == "LEFT" then
									BLINKIISPORTRAITS.db.profile.arena.point.point = "RIGHT"
									BLINKIISPORTRAITS.db.profile.arena.mirror = false
								elseif value == "RIGHT" then
									BLINKIISPORTRAITS.db.profile.arena.point.point = "LEFT"
									BLINKIISPORTRAITS.db.profile.arena.mirror = true
								else
									BLINKIISPORTRAITS.db.profile.arena.point.point = value
									BLINKIISPORTRAITS.db.profile.arena.mirror = false
								end

								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
							values = {
								LEFT = L["LEFT"],
								RIGHT = L["RIGHT"],
								CENTER = L["CENTER"],
							},
						},
						offset_x_range = {
							order = 3,
							name = L["X offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.point.x
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.point.x = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
						range_ofsY = {
							order = 4,
							name = L["Y offset"],
							type = "range",
							min = -256,
							max = 256,
							step = 1,
							softMin = -256,
							softMax = 256,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.point.y
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.point.y = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
					},
				},
				level_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Frame Level/ Strata"],
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = L["Frame Strata"],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.strata
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.strata = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
							values = frameStrata,
						},
						level_range = {
							order = 2,
							name = L["Frame Level"],
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							softMin = 0,
							softMax = 1000,
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.level
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.level = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
					},
				},
			},
		},
		extra_group = {
			order = 11,
			type = "group",
			name = L["Extra"],
			desc = L["Texture Style settings for Extra texture (Rare/Elite/Boss/player)."],
			args = {
				texture_group = {
					order = 1,
					type = "group",
					inline = true,
					name = L["Texture Styles"],
					args = {
						rare_select = {
							order = 1,
							type = "select",
							name = L["Rare"],
							desc = L["Select a extra texture style for rare units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.rare
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.rare = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
							values = extra,
						},
						elite_select = {
							order = 2,
							type = "select",
							name = L["Elite"],
							desc = L["Select a extra texture style for elite units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.elite
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.elite = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
							values = extra,
						},
						rareelite_select = {
							order = 3,
							type = "select",
							name = L["Rare Elite"],
							desc = L["Select a extra texture style for rare elite units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.rareelite
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.rareelite = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
							values = extra,
						},
						boss_select = {
							order = 4,
							type = "select",
							name = L["Boss"],
							desc = L["Select a extra texture style for boss units."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.boss
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.boss = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
							values = extra,
						},
						player_select = {
							order = 5,
							type = "select",
							name = L["Player"],
							desc = L["Select a extra texture style for player."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.player
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.player = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
							values = extra,
						},
						description = {
							order = 6,
							type = "description",
							name = L["TIP: If you use the Blizzard textures and change the classification color to white, you will see the extra texture with the original colors."],
						},
					},
				},
				settings_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Settings"],
					args = {
						extratop_toggle = {
							order = 1,
							type = "toggle",
							name = L["Set Extra on Top"],
							desc = L["Shows the extra (rare/elite) texture on a higher layer."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.extratop
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.extratop = value
								StaticPopup_Show("BLINKIISPORTRAITS_RL")
							end,
						},
					},
				},
			},
		},
		color_group = {
			order = 12,
			type = "group",
			name = L["Color"],
			args = {
				apply_execute = {
					order = 1,
					type = "execute",
					name = L["Apply"],
					func = function()
						BLINKIISPORTRAITS:LoadPortraits()
					end,
				},
				reset_class_execute = {
					order = 2,
					type = "execute",
					name = L["Reset class colors"],
					func = function()
						BLINKIISPORTRAITS.db.profile.colors.class = CopyTable(BLINKIISPORTRAITS.defaults.profile.colors.class)
					end,
				},
				reset_colors_execute = {
					order = 3,
					type = "execute",
					name = L["Reset all colors"],
					func = function()
						BLINKIISPORTRAITS.db.profile.colors = CopyTable(BLINKIISPORTRAITS.defaults.profile.colors)
					end,
				},
				settings_group = {
					order = 4,
					type = "group",
					inline = true,
					name = L["Settings"],
					args = {
						default_toggle = {
							order = 1,
							type = "toggle",
							name = L["Use Default color"],
							desc = L["Forces the default color for all texture."],
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.misc.force_default
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.misc.force_default = value
								BLINKIISPORTRAITS:LoadPortraits()
							end,
						},
					},
				},
				misc_group = {
					order = 5,
					type = "group",
					inline = true,
					name = L["Misc"],
					args = {
						default_color = {
							type = "color",
							order = 1,
							name = L["Default"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.misc.default
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.misc.default
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						death_color = {
							type = "color",
							order = 2,
							name = L["Death"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.misc.death
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.misc.death
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				class_group = {
					order = 6,
					type = "group",
					inline = true,
					name = L["Class"],
					args = {
						DEATHKNIGHT_color = {
							type = "color",
							order = 1,
							name = L["Death Knight"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DEATHKNIGHT
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DEATHKNIGHT
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						DEMONHUNTER_color = {
							type = "color",
							order = 2,
							name = L["Demon Hunter"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DEMONHUNTER
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DEMONHUNTER
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						DRUID_color = {
							type = "color",
							order = 3,
							name = L["Druid"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DRUID
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.DRUID
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						EVOKER_color = {
							type = "color",
							order = 4,
							name = L["Evoker"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.EVOKER
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.EVOKER
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						HUNTER_color = {
							type = "color",
							order = 5,
							name = L["Hunter"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.HUNTER
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.HUNTER
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						MAGE_color = {
							type = "color",
							order = 6,
							name = L["Mage"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.MAGE
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.MAGE
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						MONK_color = {
							type = "color",
							order = 7,
							name = L["Monk"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.MONK
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.MONK
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						PALADIN_color = {
							type = "color",
							order = 8,
							name = L["Paladin"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.PALADIN
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.PALADIN
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						PRIEST_color = {
							type = "color",
							order = 9,
							name = L["Priest"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.PRIEST
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.PRIEST
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						ROGUE_color = {
							type = "color",
							order = 10,
							name = L["Rouge"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.ROGUE
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.ROGUE
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						SHAMAN_color = {
							type = "color",
							order = 11,
							name = L["Shaman"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.SHAMAN
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.SHAMAN
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						WARLOCK_color = {
							type = "color",
							order = 12,
							name = L["Warlock"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.WARLOCK
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.WARLOCK
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						WARRIOR_color = {
							type = "color",
							order = 13,
							name = L["Warrior"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.WARRIOR
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.class.WARRIOR
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				classification_group = {
					order = 7,
					type = "group",
					inline = true,
					name = L["Classification"],
					args = {
						rare_color = {
							type = "color",
							order = 1,
							name = L["Rare"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.rare
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.rare
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						elite_color = {
							type = "color",
							order = 2,
							name = L["Elite"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.elite
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.elite
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						rareelite_color = {
							type = "color",
							order = 3,
							name = L["Rare Elite"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.rareelite
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.rareelite
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						boss_color = {
							type = "color",
							order = 4,
							name = L["Boss"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.boss
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.boss
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						player_color = {
							type = "color",
							order = 5,
							name = L["Player"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.player
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.classification.player
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				reaction_group = {
					order = 8,
					type = "group",
					inline = true,
					name = L["Reaction"],
					args = {
						enemy_color = {
							type = "color",
							order = 1,
							name = L["Enemy"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.enemy
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.enemy
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						neutral_color = {
							type = "color",
							order = 2,
							name = L["Neutral"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.neutral
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.neutral
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						friendly_color = {
							type = "color",
							order = 3,
							name = L["Friendly"],
							hasAlpha = true,
							get = function(info)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.friendly
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = BLINKIISPORTRAITS.db.profile.colors.reaction.friendly
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
			},
		},
		classicons_group = {
			order = 13,
			type = "group",
			name = L["Class Icons"],
			args = {
				classIcon_select = {
					order = 1,
					type = "select",
					name = L["Class Icons"],
					desc = L["Enable and select a class icon style for the portrait."],
					get = function(info)
						return BLINKIISPORTRAITS.db.profile.misc.class_icon
					end,
					set = function(info, value)
						BLINKIISPORTRAITS.db.profile.misc.class_icon = value
						BLINKIISPORTRAITS:LoadPortraits()
					end,
					values = function()
						local t = {}
						for k, v in pairs(BLINKIISPORTRAITS.media.class) do
							if type(v) == "table" then t[k] = v.name end
						end
						for k, v in pairs(BLINKIISPORTRAITS.media.custom) do
							if type(v) == "table" then t[k] = v.name end
						end
						t.none = L["None"]
						return t
					end,
				},
				customicons_group = {
					order = 2,
					type = "group",
					name = L["custom Class Icons"],
					inline = true,
					args = {
						add_new_group = {
							order = 1,
							type = "group",
							name = L["Add new Icons"],
							inline = true,
							args = {
								icon_path_input = {
									order = 1,
									name = L["Icon Path"],
									desc = L["The path should be in your Addons folder, example: MyIcons\\MyClassIcons.tga"],
									type = "input",
									width = "smal",
									get = function(info)
										return custom_classicons.path
									end,
									set = function(info, value)
										custom_classicons.path = value
									end,
								},
								icon_name_input = {
									order = 2,
									name = L["Icon Name"],
									desc = L["Name for your custom class Icons"],
									type = "input",
									width = "smal",
									get = function(info)
										return custom_classicons.name
									end,
									set = function(info, value)
										custom_classicons.name = value
									end,
								},
								add_execute = {
									order = 3,
									type = "execute",
									name = L["Add"],
									func = function()
										if custom_classicons.name == "blizzard" or custom_classicons.name == "hd" or custom_classicons.name == "new" then
											custom_classicons.name = L["Custom "] .. custom_classicons.name
										end

										if custom_classicons.path and custom_classicons.path:match("%S") and custom_classicons.name and custom_classicons.name:match("%S") then
											BLINKIISPORTRAITS.db.global.custom_classicons[custom_classicons.name] = {
												texture = custom_classicons.path,
												name = custom_classicons.name,
												texCoords = custom_classicons.texCoords or nil,
											}

											BLINKIISPORTRAITS:UpdateCustomClassIcons()
											BLINKIISPORTRAITS.db.global.name = custom_classicons.name
											custom_classicons.selected = custom_classicons.name

											custom_classicons.path = nil
											custom_classicons.name = nil
											custom_classicons.texCoords = nil
										end
									end,
								},
							},
						},
						delete_group = {
							order = 2,
							type = "group",
							name = L["Delete"],
							inline = true,
							args = {
								delete_icon_select = {
									order = 1,
									type = "select",
									name = L["Delete icons"],
									get = function() end,
									set = function(info, value)
										StaticPopup_Show("BLINKIISPORTRAITS_DELETE_ICON", value, nil, value)
										custom_classicons.path = nil
										custom_classicons.name = nil
										custom_classicons.texCoords = nil
										custom_classicons.selected = nil
										BLINKIISPORTRAITS:UpdateCustomClassIcons()
									end,
									values = function()
										local t = {}
										for k, v in pairs(BLINKIISPORTRAITS.db.global.custom_classicons) do
											if type(v) == "table" then t[k] = v.name end
										end
										return t
									end,
								},
							},
						},
					},
				},
			},
		},
		profile_group = {
			order = 14,
			type = "group",
			name = L["Profile"],
			childGroups = "tab",
			args = {
				profile = {},
				import = {
					order = 110,
					type = "group",
					name = L["Import"],
					args = {
						import_button = {
							order = 1,
							type = "execute",
							name = L["Import"],
							disabled = function()
								return not importInfos.success
							end,
							func = function()
								-- import the profile
								if importInfos and importInfos.success then
									if importInfos.exists then
										StaticPopup_Show("BLINKIISPORTRAITS_PROFILE_EXISTS", "", nil, importInfos.name)
									else
										BLINKIISPORTRAITS.db.profiles[importInfos.name] = copyTable(BLINKIISPORTRAITS.defaults)
										copyTable(importInfos.profile, BLINKIISPORTRAITS.db.profiles[importInfos.name])
										BLINKIISPORTRAITS.db:SetProfile(importInfos.name)

										importInfos = {}
									end
								end
							end,
						},
						import = {
							order = 2,
							type = "input",
							name = L["Import"],
							multiline = true,
							width = "full",
							get = function()
								-- check if the a profile with same name exists
								local profileExists
								local profiles = BLINKIISPORTRAITS.db:GetProfiles()
								if profiles then
									for _, name in ipairs(profiles) do
										if name == importInfos.name then
											profileExists = true
											break
										end
									end
								end

								importInfos.exists = profileExists

								-- show import infos
								if importInfos.success then
									local outputString = profileExists and "Author: %s\nName: %s (exists)\nVersion: %s" or "Author: %s\nName: %s\nVersion: %s"
									return format(outputString, importInfos.author, importInfos.name, importInfos.version)
								elseif importInfos.error then
									return importInfos.error
								end
							end,
							set = function(info, import)
								importInfos = {}

								-- check the import string
								if not strmatch(import, "^" .. "!BP") then
									importInfos.error = L["ERROR 1 - This is not a Blinkiis Portraits profile!"]
									return
								end

								local profileImport = gsub(import, "^" .. "!BP", "")

								local decoded = LibDeflate:DecodeForPrint(profileImport)
								if not decoded then
									importInfos.error = L["ERROR 2 - Import string is corrupted!"]
									return
								end

								local decompressed = LibDeflate:DecompressDeflate(decoded)
								if not decompressed then
									importInfos.error = L["ERROR 3 - Import string is corrupted!"]
									return
								end

								local success, outputDB = LibSerialize:Deserialize(decompressed)
								if not success then
									importInfos.error = L["ERROR 4 - Import string is corrupted!"]
									return
								end

								-- if success, the add the infos to the importInfos table
								if success and outputDB then
									importInfos.success = success
									importInfos.author = outputDB.author
									importInfos.name = outputDB.name
									importInfos.version = outputDB.version
									importInfos.bp_version = outputDB.bp_version
									importInfos.profile = outputDB.profile
								end
							end,
						},
					},
				},
				export = {
					order = 120,
					type = "group",
					name = L["Export"],
					args = {
						export_button = {
							order = 1,
							type = "execute",
							name = L["Export"],
							func = function()
								-- get profile infos
								exportProfile.author = exportProfile.author or "Unknown"
								exportProfile.name = exportProfile.name or BLINKIISPORTRAITS.db:GetCurrentProfile()
								exportProfile.version = exportProfile.version or "1.0"
								exportProfile.bp_version = BLINKIISPORTRAITS.Version

								-- get profile db
								exportProfile.profile = BLINKIISPORTRAITS.db.profile

								-- build export string
								local serialized = LibSerialize:Serialize(exportProfile) -- serialized the profile db
								local compressed = LibDeflate:CompressDeflate(serialized) -- compress the serialized string
								local encoded = LibDeflate:EncodeForPrint(compressed) -- encode the compressed string for the wow addon channel
								exportString = encoded and format("!BP%s", encoded) or nil -- add prefix to the encoded string

								-- cleanup the export data
								exportProfile = {}
							end,
						},
						export = {
							order = 2,
							type = "input",
							name = L["Export String"],
							multiline = true,
							width = "full",
							set = false,
							get = function(info, import)
								return exportString -- return the finished export string
							end,
						},
						info = {
							order = 3,
							type = "description",
							fontSize = "medium",
							name = L["This is where you can fill in your optional profile information."],
						},
						author = {
							order = 4,
							type = "input",
							name = L["Author"],
							multiline = false,
							width = "smal",
							get = false,
							set = function(info, author)
								exportProfile.author = author
							end,
						},
						info_author = {
							order = 5,
							type = "description",
							fontSize = "medium",
							name = function()
								return exportProfile.author
							end,
						},
						name = {
							order = 6,
							type = "input",
							name = L["Profile Name"],
							multiline = false,
							width = "smal",
							get = false,
							set = function(info, name)
								exportProfile.name = name
							end,
						},
						info_name = {
							order = 7,
							type = "description",
							fontSize = "medium",
							name = function()
								return exportProfile.name
							end,
						},
						version = {
							order = 8,
							type = "input",
							name = L["Profile Version"],
							multiline = false,
							width = "smal",
							get = false,
							set = function(info, version)
								exportProfile.version = version
							end,
						},
						info_version = {
							order = 9,
							type = "description",
							fontSize = "medium",
							name = function()
								return exportProfile.version
							end,
						},
					},
				},
			},
		},
		about = {
			order = 15,
			type = "group",
			name = L["About"],
			args = {
				help = {
					order = 1,
					type = "group",
					inline = true,
					name = L["Help"],
					args = {
						contact = {
							order = 1,
							type = "execute",
							name = L["Contact"],
							func = function()
								StaticPopup_Show("BLINKIISPORTRAITS_EDITBOX", nil, nil, "mmediatag@gmx.de")
							end,
						},
						git = {
							order = 2,
							type = "execute",
							name = "GitHub",
							func = function()
								StaticPopup_Show("BLINKIISPORTRAITS_EDITBOX", nil, nil, "https://github.com/mBlinkii/Blinkiis-Portraits")
							end,
						},
						discord = {
							order = 3,
							type = "execute",
							name = "Discord",
							func = function()
								StaticPopup_Show("BLINKIISPORTRAITS_EDITBOX", nil, nil, "https://discord.com/invite/AE9XebMU49")
							end,
						},
					},
				},
			},
		},
	},
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("BLINKIISPORTRAITS", BLINKIISPORTRAITS.options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLINKIISPORTRAITS", BLINKIISPORTRAITS.Name)
