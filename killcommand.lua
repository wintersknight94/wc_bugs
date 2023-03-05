-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --

minetest.register_chatcommand("killbugs", {
		description = "Annihilate all nearby bugs",
		privs = {["debug"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:bug", 20)) do
				minetest.remove_node(p)
			end
		end
	})
