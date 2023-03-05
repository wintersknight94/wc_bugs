-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore
    = ipairs, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local hatchcost = 1200
local CHANCE_ESCAPE = 3 -- Probability of leaving the inventory
local CHANCE_CALM = 2 -- Probability multiplier while calm (base chance * calmness * multiplier)
------------------------------------------------------------------------
local peat = "nc_tree_humus.png^nc_tree_peat.png"
local prill = "(" ..peat.. ")^[mask:nc_lode_mask_prill.png"
-- ================================================================== --
minetest.register_node(modname .. ":peatle", {
	description = ("Peatle"),
	tiles = {peat},
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
		bug = 1,
		peatle = 1,
		crawling = 1,
		stack_as_node = 1,
		falling_node = 1,
		peat_grindable_item = 1
	},
	sounds = nodecore.sounds("nc_tree_corny")
})
-- ================================================================== --
nodecore.register_on_peatle_hatch,
nodecore.registered_on_peatle_hatching
= nodecore.mkreg()
------------------------------------------------------------------------
local function hatchdone(pos, node)
	nodecore.set_loud(pos, node)
	for _, f in ipairs(nodecore.registered_on_peatle_hatching) do f(pos) end
	nodecore.witness(pos, "peatle hatch")
	return false
end
------------------------------------------------------------------------
nodecore.register_soaking_abm({
		label = "peatle hatch",
		fieldname = "hatch",
		nodenames = {"nc_tree:peat"},
		interval = 20,
		soakrate = nodecore.tree_soil_rate,
		soakcheck = function(data, pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if data.total < hatchcost then return end
			minetest.get_meta(pos):from_table({})
			hatchdone(above, {name = modname .. ":peatle"})
			local found = nodecore.find_nodes_around(pos, {"group:humus"}) --{"nc_tree:peat"})
			if #found < 1 then return false end
			nodecore.soaking_abm_push(nodecore.pickrand(found),
				"hatch", data.total - hatchcost)
			return false
		end
	})
-- ================================================================== --
local function snufffx(pos)
	nodecore.smokeburst(pos, 3)
	return nodecore.sound_play("nc_fire_snuff", {gain = 0.2, pos = pos, fade = 0.5})
end
------------------------------------------------------------------------
nodecore.register_abm({
	label = "Peatle Starstroke",
	interval = 10,
	chance = 10,
	nodenames = {"group:peatle"},
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if nodecore.is_full_sun(above) then
			minetest.remove_node(pos)
			snufffx(pos)
			return
		end
	end
})
-- ================================================================== --
-- Borrowed from ncshark, induced headache, sincere thanks GreenXenith --
nodecore.register_aism({
	label = "peatle escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:peatle"},
	action = function(stack, data)
		if data.pos and data.inv then -- Check if in inventory
		if math.random(1, CHANCE_ESCAPE) == 1 then
			local player = minetest.get_player_by_name(data.inv:get_location().name)
			-- Calmness based on environment
			local calm = 1
			local has_peat = data.inv:contains_item("main", "nc_tree:peat") or data.inv:contains_item("main", "group:humus")
			calm = calm + (has_peat and 1 or 0) -- Comforted by peat and humus
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
	label = "peatle stack escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:peatle"},
	action = function(stack, data)
		if not data.inv then -- Check if in inventory
			nodecore.item_eject(data.pos, stack:take_item(1), 2, 1, {x = 1, y = 0, z = 1})
			return stack
		end
	end
})
-- ================================================================== --



