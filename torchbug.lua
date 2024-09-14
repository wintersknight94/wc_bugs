-- LUALOCALS < ---------------------------------------------------------
local math, minetest, next, nodecore, pairs
    = math, minetest, next, nodecore, pairs
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
-- ================================================================== --
local torchbug = modname.. "_torchbug.png^[verticalframe:8:2"
-- ================================================================== --
-------------Calm Torchbug-------------
minetest.register_node(modname .. ":torchbug", {
	description = ("Torchbug"),
	drawtype = "plantlike",
	tiles = {{
		name = modname .. "_torchbug.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.5
		},
	}},
	inventory_image = torchbug,
	wield_image =  torchbug,
	waving = 1,
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	groups = {
		snappy = 1,
		torchbug = 1,
		bug = 1,
		flying = 1,
		stack_as_node = 1
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	},
	light_source = 1,
	drop_in_place = modname.. ":torchbug_red"
})
------------------------------------------------------------------------
------------Hidden Torchbug------------
minetest.register_node(modname .. ":torchbug_hidden", {
	description = ("Torchbug"),	--only used for testing purposes
	drawtype = "airlike",
--	tiles = {torchbug.. "^[colorize:white:200"},	--only used for testing purposes
	inventory_image = torchbug,				--only used for testing purposes
	wield_image = torchbug,					--only used for testing purposes
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = true,
	groups = {
		torchbug = 1,
		bug = 1,
		flying = 1,
		stack_as_node = 1
	},
	drop = ""
})
------------------------------------------------------------------------
-----------Excited Torchbug------------
minetest.register_node(modname .. ":torchbug_red", {
	description = ("Torchbug"),
	drawtype = "plantlike",
	tiles = {{
		name = modname .. "_firebug.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.8
		},
	}},
	waving = 1,
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	groups = {
		bug = 1,
		torchbug = 1,
		firebug = 1,
		flying = 1,
		stack_as_node = 1,
		igniter = 1,
		damage_touch = 1,
		flame_ambiance = 1
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	},
	light_source = 3
})
-- ================================================================== --
-----------Blinking Behavior-----------
nodecore.register_limited_abm({
	label = "Torchbug Hide",
	nodenames = {modname .. ":torchbug"},
	interval = 2,
	chance = 10,
	action = function(pos)
		nodecore.set_node(pos, {name = modname .. ":torchbug_hidden"})
	end
})
nodecore.register_limited_abm({
	label = "Torchbug Light",
	nodenames = {modname .. ":torchbug_hidden"},
	interval = 2,
	chance = 10,
	action = function(pos)
		nodecore.set_node(pos, {name = modname .. ":torchbug"})
	end
})
------------------------------------------------------------------------
local function snufffx(pos)
	nodecore.smokeburst(pos, 3)
	return nodecore.sound_play("nc_fire_snuff", {gain = 0.2, pos = pos})
end
nodecore.register_limited_abm({
	label = "Torchbug Calm",
	nodenames = {modname .. ":torchbug_red"},
	interval = 2,
	chance = 10,
	action = function(pos)
		nodecore.set_node(pos, {name = modname .. ":torchbug"})
		snufffx(pos)
		return
	end
})
-- ================================================================== --
nodecore.register_abm({
	label = "Torchbug Birth",
	interval = 10,
	chance = 10,
	nodenames = {"group:torch_lit"},
	neighbors = {"group:humus"},
	action = function(pos)
		nodecore.set_node(pos, {name = "air"})
		nodecore.item_eject(pos, modname.. ":torchbug", 1)
		nodecore.item_eject(pos, "nc_fire:lump_ash", 1)
		nodecore.firestick_spark_ignite(pos)
		nodecore.sound_play("nc_fire_ignite", {gain = 0.2, pos = pos})
	end
})
------------------------------------------------------------------------
nodecore.register_abm({
	label = "Torchbug Death",
	interval = 1,
	chance = 1,
	nodenames = {"group:torchbug"},
	action = function(pos)
		if nodecore.quenched(pos) then
			minetest.remove_node(pos)
			snufffx(pos)
			return
		end
	end
})
------------------------------------------------------------------------
minetest.register_abm({
	label = "Torchbug Icarian Flight",
	nodenames = {"group:torchbug"},
	interval = 10,
	chance = 1,
	action = function(pos)
		local down = {x = pos.x, y = pos.y - 20, z = pos.z}
		local icarus = minetest.find_nodes_in_area(pos, down, "air")
		if #icarus >= 20 then
			minetest.remove_node(pos)
			snufffx(pos)
		end
	end
})
------------------------------------------------------------------------
nodecore.register_limited_abm({
	label = "effect:firebug",
	nodenames = {"group:firebug"},
	interval = 1,
	chance = 1,
	action = function(pos)
		nodecore.firestick_spark_ignite(pos)
		nodecore.sound_play("nc_fire_ignite", {gain = 0.1, pos = pos})

	end
})
