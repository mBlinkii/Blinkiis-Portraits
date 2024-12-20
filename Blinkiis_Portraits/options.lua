local form = {
	blizz = "Blizz",
	blizz_up = "Blizz Up",
	circle = "Circle",
	diagonal = "Diagonal",
	diamond = "Diamond",
	drop = "Drop",
	drop_mirror = "Drop Mirror",
	egg = "Egg",
	hexa = "Hexa",
	page = "Page",
	page_mirror = "Page Mirror",
	square = "Square",
	square_round = "Square Round",
}
local extra = {
	extra_a = "Extra A",
	extra_b = "Extra B",
	extra_c = "Extra C",
}

local frameStrata = {
	BACKGROUND = "BACKGROUND",
	LOW = "LOW",
	MEDIUM = "MEDIUM",
	HIGH = "HIGH",
	DIALOG = "DIALOG",
	TOOLTIP = "TOOLTIP",
	AUTO = "Auto",
}

local options = {
	name = BLINKIISPORTRAITS.Name,
	handler = BLINKIISPORTRAITS,
	type = "group",
	childGroups = "tab",
	args = {
		player_group = {
			order = 1,
			type = "group",
			name = "Player",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Player Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Player Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.extra = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.player.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.player.cast = value
								BLINKIISPORTRAITS:InitializePlayerPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 2,
			type = "group",
			name = "Target",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Target Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Target Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.extra = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.target.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.target.cast = value
								BLINKIISPORTRAITS:InitializeTargetPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 3,
			type = "group",
			name = "Focus",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Focus Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Focus Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.extra = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.focus.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.focus.cast = value
								BLINKIISPORTRAITS:InitializeFocusPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 4,
			type = "group",
			name = "Target of Target",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Target of Target Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Target of Target Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.extra = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.targettarget.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.targettarget.cast = value
								BLINKIISPORTRAITS:InitializeTargetTargetPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 5,
			type = "group",
			name = "Pet",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Pet Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Pet Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.extra = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.pet.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.pet.cast = value
								BLINKIISPORTRAITS:InitializePetPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 6,
			type = "group",
			name = "Party",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Party Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Party Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.extra = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.party.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.party.cast = value
								BLINKIISPORTRAITS:InitializePartyPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 7,
			type = "group",
			name = "Boss",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Boss Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Boss Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.extra = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.boss.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.boss.cast = value
								BLINKIISPORTRAITS:InitializeBossPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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
			order = 8,
			type = "group",
			name = "Arena",
			args = {
				enable_toggle = {
					order = 1,
					type = "toggle",
					name = "Enable",
					desc = "Enable Arena Portrait.",
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
					name = "General",
					args = {
						styles_select = {
							order = 1,
							type = "select",
							name = "Style",
							desc = "Select a portrait texture style.",
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
							name = "Size",
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
						extra_toggle = {
							order = 3,
							type = "toggle",
							name = "Enable Extra Texture",
							desc = "Shows the Extra Texture (rare/elite) for the Arena Portrait.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.extra
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.extra = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
						cast_toggle = {
							order = 4,
							type = "toggle",
							name = "Cast Icon",
							desc = "Enable Cast Icons.",
							get = function(info)
								return BLINKIISPORTRAITS.db.profile.arena.cast
							end,
							set = function(info, value)
								BLINKIISPORTRAITS.db.profile.arena.cast = value
								BLINKIISPORTRAITS:InitializeArenaPortrait()
							end,
						},
					},
				},
				anchor_group = {
					order = 3,
					type = "group",
					inline = true,
					name = "Anchor",
					args = {
						anchor_select = {
							order = 1,
							type = "select",
							name = "Anchor Point",
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
								LEFT = "LEFT",
								RIGHT = "RIGHT",
								CENTER = "CENTER",
							},
						},
						offset_x_range = {
							order = 2,
							name = "X offset",
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
							order = 3,
							name = "Y offset",
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
					name = "Frame Level/ Strata",
					args = {
						strata_select = {
							order = 1,
							type = "select",
							name = "Frame Strata",
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
							name = "Frame Level",
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


	},
}

LibStub("AceConfig-3.0"):RegisterOptionsTable("BLINKIISPORTRAITS", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLINKIISPORTRAITS", BLINKIISPORTRAITS.Name)
