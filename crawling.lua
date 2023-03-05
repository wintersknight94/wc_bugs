-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math, vector
    = minetest, nodecore, math, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local get_node = minetest.get_node
local set_node = minetest.swap_node
------------------------------------------------------------------------
local directions = {
	{x=1, y=0, z=0},
	{x=-1, y=0, z=0},
	{x=0, y=0, z=1},
	{x=0, y=0, z=-1},
	
	{x=1, y=0, z=1},
	{x=1, y=0, z=-1},
	{x=-1, y=0, z=1},
	{x=-1, y=0, z=-1},
}
-- ================================================================== --
nodecore.register_abm({
	label = "movement:crawling",
	nodenames = {"group:crawling"},
	interval = 2,
	chance = 2,
	action = function(pos, node)
		local dir = directions[math.random(1,8)]
		local next_pos = vector.add(pos, dir)
		local next_node = minetest.get_node(next_pos)	
			if next_node.name == "air" then
				minetest.swap_node(next_pos, node)
				minetest.swap_node(pos, next_node)
				minetest.check_for_falling(pos)
--			return nodecore.fallcheck(pos)
				else if next_node.name == "nc_tree:leaves_loose" then
					minetest.swap_node(next_pos, node)
					minetest.swap_node(pos, next_node)
				else if next_node.name == "nc_tree:stick" then
					minetest.swap_node(next_pos, node)
					minetest.swap_node(pos, next_node)
				else if next_node.name == "nc_tree:eggcorn" then
					minetest.swap_node(next_pos, node)
					minetest.swap_node(pos, next_node)
				end
			end
		end
	end
end
})
-- ================================================================== --
