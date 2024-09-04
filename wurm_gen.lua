-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local anlode = "nc_lode_annealed.png^[colorize:black:50"
local tmlode = "nc_lode_tempered.png^[colorize:gold:50"
local scales = tmlode.. "^[mask:nc_concrete_pattern_bindy.png"
local egg = tmlode.. "^[mask:nc_concrete_pattern_vermy.png"
------------------------------------------------------------------------
local wurmegg = "(" ..anlode.. ")^(" ..scales.. ")^(" ..egg.. ")"
-- ================================================================== --
minetest.register_node(modname .. ":wurm_egg", {
	description = ("Lodewurm Egg"),
	tiles = {wurmegg},
	groups = {
		wurm_egg = 1,
		cobble = 1,
		cracky = 3
	},
	sounds = nodecore.sounds("nc_lode_tempered")
})
------------------------------------------------------------------------
minetest.register_ore({
	name = modname .. ":wurm_egg",
	ore_type = "scatter",
	ore = modname .. ":wurm_egg",
	wherein = "group:stone",
	random_factor = 0,
	noise_params = {
		offset = 0,
		scale = 4,
		spread = {x = 64, y = 64, z = 64},
		seed = 72031,
		octaves = 4,
		persist = 0.5,
		flags = "eased",
	},
	noise_threshold = 0.9,
	y_max = -128,
	y_min = -31000,
	clust_num_ores = 1,
	clust_size = 1,
	clust_scarcity = 8 * 8 * 8 * 4
})
