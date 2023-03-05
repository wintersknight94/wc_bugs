-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local function temper(name, desc, sound, glow, alt, alt2)
local lode = "nc_lode_" ..name.. ".png"
local mouth = "(" ..alt.. ")^[mask:" ..modname.. "_mask_wurm.png"
local scales = "(" ..alt2.. ")^[mask:nc_concrete_pattern_bindy.png"
local tail = "(" ..alt2.. ")^[mask:(nc_concrete_pattern_iceboxy.png^nc_concrete_pattern_bindy.png)"
------------------------------------------------------------------------
	minetest.register_node(modname .. ":lodewurm_head_" ..name, {
		description = (desc.. " Lodewurm"),
		tiles = {
			"(" ..lode.. ")^(" ..scales.. ")",	--
			"(" ..lode.. ")^(" ..scales.. ")",	--
			"(" ..lode.. ")^(" ..scales.. ")^(" ..mouth.. ")",	--
			"(" ..lode.. ")^(" ..scales.. ")",	--
			"(" ..lode.. ")^(" ..scales.. ")",	--
			"(" ..lode.. ")^(" ..scales.. ")",	--
	},
		groups = {
			cracky = 5,
			choppy = 5,
			lodewurm = 1,
			lodewurm_head = 1,
			bug = 1,
			metallic = 1,
			lode_cube = 1
		},
		sounds = nodecore.sounds(sound),
		light_source = glow
	})
	minetest.register_node(modname .. ":lodewurm_body_" ..name, {
		description = (desc.. " Lodewurm"),
		tiles = {
			"(" ..lode.. ")^(" ..scales.. ")"
		},
		groups = {
			cracky = 5,
			choppy = 5,
			lodewurm = 1,
			lodewurm_body = 1,
			bug = 1,
			metallic = 1,
			lode_cube = 1
		},
		sounds = nodecore.sounds(sound),
				light_source = glow
	})
	minetest.register_node(modname .. ":lodewurm_tail_" ..name, {
		description = (desc.. " Lodewurm"),
		tiles = {
			"(" ..lode.. ")^(" ..scales.. ")",
			"(" ..lode.. ")^(" ..scales.. ")",
			"(" ..lode.. ")^(" ..scales.. ")",
			"(" ..lode.. ")^(" ..tail.. ")",
			"(" ..lode.. ")^(" ..scales.. ")",
			"(" ..lode.. ")^(" ..scales.. ")"
		},
		groups = {
			cracky = 5,
			choppy = 5,
			lodewurm = 1,
			lodewurm_tail = 1,
			bug = 1,
			metallic = 1,
			lode_cube = 1
		},
		sounds = nodecore.sounds(sound),
		light_source = glow
	})
------------------------------------------------------------------------
end
------------------------------------------------------------------------------------------------------------------------------------------------
temper("annealed",	"Annealed",	"nc_lode_annealed",		0,	"nc_lode_hot.png",				"nc_terrain_gravel.png")
temper("tempered",	"Tempered",	"nc_lode_tempered",		0,	"nc_lode_hot.png",				"nc_optics_glass_frost.png")
temper("hot",		"Glowing",	"nc_lode_annealed",		8,	"nc_optics_glass_frost.png",		"nc_igneous_pumice.png")
------------------------------------------------------------------------------------------------------------------------------------------------
local eggname = modname .. ":lodewurm_egg"
local ore = "nc_lode:ore"
--local eggdef = nodecore.underride({
--	description = "Lodewurm Egg",
--	tiles = {"nc_terrain_stone.png^(nc_lode_ore.png^[mask:(nc_concrete_pattern_iceboxy.png^nc_lode_mask_ore.png))"},
--	groups = {lodewurm = 1, cracky = 3},
--	drop_in_place = "nc_lode:cobble"
--}, minetest.registered_items[ore] or {})
--minetest.register_node(eggname, eggdef)
------------------------------------------------------------------------
--nodecore.register_craft({
--		label = "crack lodewurm egg",
--		action = "pummel",
--		toolgroups = {thumpy = 4, cracky = 4},
--		indexkeys = {modname.. ":lodewurm_egg"},
--		nodes = {
--			{
--				match = modname.. ":lodewurm_egg",
--				replace = modname .. ":lodewurm_head_annealed"
--			}
--		}
--	})
------------------------------------------------------------------------

------------------------------------------------------------------------

------------------------------------------------------------------------

------------------------------------------------------------------------

------------------------------------------------------------------------
