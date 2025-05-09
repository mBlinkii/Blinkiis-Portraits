local texCoords = {
	WARRIOR = { 0, 0, 0, 0.125, 0.125, 0, 0.125, 0.125 },
	MAGE = { 0.125, 0, 0.125, 0.125, 0.25, 0, 0.25, 0.125 },
	ROGUE = { 0.25, 0, 0.25, 0.125, 0.375, 0, 0.375, 0.125 },
	DRUID = { 0.375, 0, 0.375, 0.125, 0.5, 0, 0.5, 0.125 },
	EVOKER = { 0.5, 0, 0.5, 0.125, 0.625, 0, 0.625, 0.125 },
	HUNTER = { 0, 0.125, 0, 0.25, 0.125, 0.125, 0.125, 0.25 },
	SHAMAN = { 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.25, 0.25 },
	PRIEST = { 0.25, 0.125, 0.25, 0.25, 0.375, 0.125, 0.375, 0.25 },
	WARLOCK = { 0.375, 0.125, 0.375, 0.25, 0.5, 0.125, 0.5, 0.25 },
	PALADIN = { 0, 0.25, 0, 0.375, 0.125, 0.25, 0.125, 0.375 },
	DEATHKNIGHT = { 0.125, 0.25, 0.125, 0.375, 0.25, 0.25, 0.25, 0.375 },
	MONK = { 0.25, 0.25, 0.25, 0.375, 0.375, 0.25, 0.375, 0.375 },
	DEMONHUNTER = { 0.375, 0.25, 0.375, 0.375, 0.5, 0.25, 0.5, 0.375 },
}

BLINKIISPORTRAITS.media = {
	portraits = {
		blizz = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_extra_b.tga",
		},
		blizz_up = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_up.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_up_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_up_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_up_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\blizz_up_extra_b.tga",
		},
		circle = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_extra.tga",
		},
		diagonal = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_extra_b.tga",
		},
		diagonal_mirror = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_mirror.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_mask_b.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_extra_b.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_mask_a.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\diagonal_extra_a.tga",
		},
		diamond = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\diamond.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\diamond_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\diamond_extra.tga",
		},
		drop = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_extra_b.tga",
		},
		drop_mirror = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_mirror.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_mask_b.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_extra_b.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_mask_a.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_extra_a.tga",
		},
		drop_side = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_extra_b.tga",
		},
		drop_side_mirror = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_mirror.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_mask_b.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_extra_b.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_mask_a.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\drop_side_extra_a.tga",
		},
		egg = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg_extra.tga",
		},
		hexa = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\hexa.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\hexa_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\hexa_extra.tga",
		},
		pad = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_extra.tga",
		},
		page = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\page.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_mask_a.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_extra_a.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_mask_b.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_extra_b.tga",
		},
		page_mirror = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_mirror.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_mask_b.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_extra_b.tga",
			mask_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_mask_a.tga",
			extra_mirror = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_extra_a.tga",
		},
		square = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\square.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\square_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\square_extra.tga",
		},
		square_round = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\square_round.tga",
			mask = "Interface\\Addons\\Blinkiis_Portraits\\media\\square_round_mask.tga",
			extra = "Interface\\Addons\\Blinkiis_Portraits\\media\\square_round_extra.tga",
		},
	},
	extra = {
		extra_a = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_a.tga",
		extra_b = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_b.tga",
		extra_c = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_c.tga",
		extra_d = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_d.tga",
		extra_f = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_f.tga",
		extra_g = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_g.tga",
		extra_h = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_h.tga",
		extra_i = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_i.tga",
		extra_j = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_j.tga",
		extra_k = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_k.tga",
		extra_m = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_m.tga",

		animal = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_animal.tga",
		dragon_a = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_dragon_a.tga",
		dragon_b = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_dragon_b.tga",
		fire = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_fire.tga",
		leaf = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_leaf.tga",
		micro = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_micro.tga",
		misc = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_misc.tga",
		pen = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_pen.tga",
		star = "Interface\\Addons\\Blinkiis_Portraits\\media\\circle_star.tga",

		egg_dragon = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg_dragon.tga",
		egg_leaf = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg_leaf.tga",
		egg_micro = "Interface\\Addons\\Blinkiis_Portraits\\media\\egg_micro.tga",

		pad_animal = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_animal.tga",
		pad_dragon = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_dragon.tga",
		pad_dragon_b = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_dragon_b.tga",
		pad_fire = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_fire.tga",
		pad_leaf = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_leaf.tga",
		pad_micro = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_micro.tga",
		pad_misc = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_misc.tga",
		pad_pen = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_pen.tga",
		pad_star = "Interface\\Addons\\Blinkiis_Portraits\\media\\pad_star.tga",

		page_dragon_a = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_dragon_a.tga",
		page_dragon_b = "Interface\\Addons\\Blinkiis_Portraits\\media\\page_dragon_b.tga",

		blizz_gold = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_blizz_gold.tga",
		blizz_silver = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_blizz_silver.tga",
		blizz_boss = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_blizz_boss.tga",
		blizz_neutral = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_blizz_neutral.tga",
		blizz_boss_neutral = "Interface\\Addons\\Blinkiis_Portraits\\media\\extra_blizz_boss_neutral.tga",
	},
	class = {
		blizzard = {
			texture = "Interface\\WorldStateFrame\\Icons-Classes",
			texCoords = CLASS_ICON_TCOORDS,
			name = "Blizzard"
		},
		hd = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\class_round.tga",
			texCoords = texCoords,
			name = "Blizzard HD"
		},
		new = {
			texture = "Interface\\Addons\\Blinkiis_Portraits\\media\\class_transparent.tga",
			texCoords = texCoords,
			name = "New Style"
		},
	},
}

function BLINKIISPORTRAITS:UpdateCustomClassIcons()
	BLINKIISPORTRAITS.media.custom = {}

	for k, v in pairs(BLINKIISPORTRAITS.db.global.custom_classicons) do
		if not (k == "blizzard" or k == "hd" or k == "new") then
			BLINKIISPORTRAITS.media.class[k] = {
				texture = "Interface\\Addons\\" .. v.texture,
				name = v.name,
				texCoords = v.texCoords or texCoords
			}
		end
	end
end
