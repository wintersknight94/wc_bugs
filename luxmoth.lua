-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local CHANCE_ESCAPE = 4 -- Probability of leaving the inventory
local CHANCE_CALM = 2 -- Probability multiplier while calm (base chance * calmness * multiplier)

local chrysalis = "nc_tree_bud_top.png^(nc_lux_gravel.png^[opacity:120)"
local mothstill = modname.. "_luxmoth.png^[verticalframe:8:1"
local mothanim = {
	name = modname .. "_luxmoth.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.5
	},
}
-- ================================================================== --
minetest.register_node(modname .. ":luxmoth", {
	description = ("Luxmoth"),
	drawtype = "plantlike",
	tiles = {mothanim},
	inventory_image = mothstill,
	wield_image = mothstill,
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	floodable = true,
	groups = {
		snappy = 1,
		luxmoth = 1,
		bug = 1,
		flying = 1,
		stack_as_node = 1,
		lux_emit = 2,
		flammable = 1
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	},
	light_source = 3,
	glow = 1,
	max_stack = 1,
	sounds = nodecore.sounds("nc_terrain_swishy")
})
------------------------------------------------------------------------
minetest.register_node(modname .. ":chrysalis", {
	description = ("Chrysalis"),
	tiles = {chrysalis},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.375, -0.25, 0.25, 0.375, 0.25},
			{-0.375, -0.25, -0.375, 0.375, 0.25, 0.375},
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
		}
	},
	selection_box = nodecore.fixedbox(),
	collision_box = nodecore.fixedbox(),
	paramtype = "light",
	sunlight_propagates = true,
	groups = {
		snappy = 1,
		chrysalis = 1,
		bug = 1,
		stack_as_node = 1,
		lux_emit = 3,
		flammable = 1
	},
	light_source = 4,
	glow = 1,
	drop_in_place = modname .. ":luxmoth",
	sounds = nodecore.sounds("nc_terrain_grassy")
})
-- ================================================================== --
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"group:stone", "group:sandstone", "group:adobe", "group:cloudstone", "group:coalstone", "group:coal"},
	place_offset_y = 0,
	sidelen = 16,
	fill_ratio = 0.001,
	y_max = -16,
	y_min = -31000,
	flags = "all_ceilings",
	decoration = modname ..":chrysalis",
	rotation = "random",
})
-- ================================================================== --
-- Borrowed from ncshark, induced headache, sincere thanks GreenXenith --
nodecore.register_aism({
	label = "Luxmoth Escape",
	interval = 1,
	chance = 1,
	itemnames = {"group:luxmoth"},
	action = function(stack, data)
		if data.pos and data.inv then -- Check if in inventory
		if math.random(1, CHANCE_ESCAPE) == 1 then
			local player = minetest.get_player_by_name(data.inv:get_location().name)
			-- Calmness based on environment
			local calm = 1
			local has_lux = data.inv:contains_item("main", "group:lux_cobble")
			calm = calm + (has_lux and 1 or 0) -- Comforted by lux
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
	label = "Luxmoth Claustrophobia",
	interval = 600,	-- approx 10 min
	chance = 10,	-- 10% chance of death
	itemnames = {"group:luxmoth"},
	action = function(stack, data)
		if not data.inv then -- Check if in inventory
			stack:set_name("")
			nodecore.sound_play("nc_api_craft_hiss", {gain = 0.2, pos = data.pos, fade = 0.5})
			return stack
		end
	end
})
-- ================================================================== --
local function snufffx(pos)
	nodecore.smokeburst(pos, 3)
	return nodecore.sound_play("nc_fire_snuff", {gain = 0.2, pos = pos, fade = 0.5})
end
------------------------------------------------------------------------
nodecore.register_abm({
	label = "Luxmoth Starstroke",
	interval = 10,
	chance = 10,
	nodenames = {"group:luxmoth"},
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if nodecore.is_full_sun(above) then
			minetest.remove_node(pos)
			snufffx(pos)
			return
		end
	end
})
