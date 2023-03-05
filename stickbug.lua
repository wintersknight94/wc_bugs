-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math, vector
    = minetest, nodecore, math, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local stickbug = "nc_tree_tree_side.png^nc_tree_peat.png"
local sticktop = "nc_tree_tree_top.png^nc_tree_peat.png"
------------------------------------------------------------------------
local CHANCE_ESCAPE = 3 -- Probability of leaving the inventory
local CHANCE_CALM = 2 -- Probability multiplier while calm (base chance * calmness * multiplier)
-- ================================================================== --
minetest.register_node(modname .. ":stickbug", {
	description = "Stickbug",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
	selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0, 1/8),
	tiles = {
	sticktop,
	sticktop,
	stickbug
	},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {
		bug = 1,
		stickbug = 1,
		firestick = 1,
		crawling = 1,
		snappy = 1,
		flammable = 2,
		falling_repose = 1,
		stack_as_node = 1
	},
	sounds = nodecore.sounds("nc_tree_sticky")
})
------------------------------------------------------------------------
nodecore.register_leaf_drops(function(_, node, list)
	list[#list + 1] = {
		name = modname .. ":stickbug",
		prob = 0.05 * (node.param2 * node.param2)}	-- One quarter the frequency of normal sticks
end)
-- ================================================================== --
nodecore.register_craft({
	label = "smush stickbug",
	action = "pummel",
	indexkeys = {modname .. ":stickbug"},
	nodes = {{match = modname .. ":stickbug", replace = "air"}},
	items = {{name = "nc_tree:stick", count = 1}},
	toolgroups = {thumpy = 1}
})
-- ================================================================== --
-- Borrowed from ncshark, induced headache, sincere thanks GreenXenith --
nodecore.register_aism({
	label = "stickbug escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:stickbug"},
	action = function(stack, data)
		if data.pos and data.inv then -- Check if in inventory
		if math.random(1, CHANCE_ESCAPE) == 1 then
			local player = minetest.get_player_by_name(data.inv:get_location().name)
			-- Calmness based on environment
			local calm = 1
			local has_peat = data.inv:contains_item("main", "nc_tree:peat") or data.inv:contains_item("main", "group:humus")
			calm = calm + (has_peat and 1 or 0) -- Comforted by peat and humus
			calm = calm - vector.length(vector.multiply(player:get_player_velocity(), {x = 1, y = 0, z = 1})) / 5 -- Not an adrenaline junkie
			calm = math.floor(math.max(1, calm) * math.max(1, CHANCE_CALM))
			if CHANCE_ESCAPE > 0 and math.random(1, CHANCE_ESCAPE * calm) == 1 then
				nodecore.item_eject(data.pos, stack:take_item(1))
			end
			return stack
		end
		end
	end
})
-- ================================================================== --
nodecore.register_aism({
	label = "stickbug stack escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:stickbug"},
	action = function(stack, data)
		if not data.inv then -- Check if in inventory
			nodecore.item_eject(data.pos, stack:take_item(1), 2, 1, {x = 1, y = 0, z = 1})
			return stack
		end
	end
})
-- ================================================================== --


