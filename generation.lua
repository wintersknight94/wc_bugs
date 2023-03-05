-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
minetest.register_ore({
		name = modname .. ":peatle_hidden",
		ore_type = "scatter",
		ore = modname .. ":peatle_hidden",
		wherein = {"group:soil"},
		random_factor = 0,
		noise_params = {
			offset = 0,
			scale = 4,
			spread = {x = 5, y = 5, z = 5},
			seed = 42069,
			octaves = 3,
			persist = 0.5,
			flags = "eased",
		},
		noise_threshold = -1,
		y_max = 100,
		y_min = -50,
		clust_num_ores = 1,
		clust_size = 1,
		clust_scarcity = 8 * 8 * 8 * 4
	})
------------------------------------------------------------------------
--minetest.register_ore({
--		name = modname .. ":lodewurm_egg",
--		ore_type = "scatter",
--		ore = modname .. ":lodewurm_egg",
--		wherein = {"group:stone", "group:gravel"},
--		random_factor = 0,
--		noise_params = {
--			offset = 0,
--			scale = 4,
--			spread = {x = 75, y = 25, z = 75},
--			seed = 42069,
--			octaves = 3,
--			persist = 0.5,
--			flags = "eased",
--		},
--		noise_threshold = -1,
--		y_max = 31000,
--		y_min = -31000,
--		clust_num_ores = 1,
--		clust_size = 1,
--		clust_scarcity = 8 * 8 * 8 * 4
--	})
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
