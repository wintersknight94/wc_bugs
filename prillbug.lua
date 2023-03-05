-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --
local CHANCE_ESCAPE = 3 -- Probability of leaving the inventory
local CHANCE_CALM = 2 -- Probability multiplier while calm (base chance * calmness * multiplier)

local lode = "nc_lode_annealed.png"
local prill = lode.. "^[mask:nc_lode_mask_prill.png"
------------------------------------------------------------------------
minetest.register_node(modname .. ":prillbug", {
	description = ("Prillbug"),
	tiles = {lode},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.4375, 0.1875},
			{-0.125, -0.5, -0.25, 0.125, -0.4375, 0.1875},
			{-0.25, -0.5, -0.125, 0.25, -0.4375, 0.1875},
			{-0.125, -0.4375, -0.0625, 0.125, -0.375, 0.25},
		}
	},
	inventory_image = prill,
	wield_image = prill,
	groups = {
		snappy = 1,
		crawling = 1,
		stack_as_node = 1,
		falling_node = 1,
		prillbug = 1,
		bug = 1,
		metallic = 1
	},
	sounds = nodecore.sounds("sound")
})
-- ================================================================== --
minetest.override_item("nc_lode:ore", {drop = {items={{items={modname..":prillbug"},rarity=4}}}})
-- ================================================================== --
nodecore.register_craft({
	label = "smush prillbug",
	action = "pummel",
	indexkeys = {modname .. ":prillbug"},
	nodes = {{match = modname .. ":prillbug", replace = "air"}},
	items = {{name = "nc_lode:prill_annealed", count = 1}},
	toolgroups = {thumpy = 3}
})
-- ================================================================== --
-- Borrowed from ncshark, induced headache, sincere thanks GreenXenith --
nodecore.register_aism({
	label = "prillbug escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:prillbug"},
	action = function(stack, data)
		if data.pos and data.inv then -- Check if in inventory
		if math.random(1, CHANCE_ESCAPE) == 1 then
			local player = minetest.get_player_by_name(data.inv:get_location().name)
			-- Calmness based on environment
			local calm = 1
			local has_peat = data.inv:contains_item("main", "group:lodey")
			calm = calm + (has_lode and 1 or 0) -- Comforted by lode
			calm = calm - nodecore.get_node_light(data.pos) / 5 -- Prefers darkness
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
	label = "prillbug stack escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:prillbug"},
	action = function(stack, data)
		if not data.inv then -- Check if in inventory
			nodecore.item_eject(data.pos, stack:take_item(1), 2, 1, {x = 1, y = 0, z = 1})
			return stack
		end
	end
})
-- ================================================================== --



