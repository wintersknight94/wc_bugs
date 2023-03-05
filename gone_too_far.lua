-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math, vector
    = minetest, nodecore, math, vector
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local adzecaps = nodecore.toolcaps({choppy = 1, crumbly = 2})
------------------------------------------------------------------------
local stickbug = "nc_tree_tree_side.png^nc_tree_peat.png"
local sticktop = "nc_tree_tree_top.png^nc_tree_peat.png"
local framebug = "nc_woodwork_frame.png^nc_tree_peat.png"
local gtfbug = "(" ..framebug.. ")^(" ..sticktop.. "^[mask:nc_woodwork_ladder_mask.png)"
------------------------------------------------------------------------
local lt = 1/16
local lw = 3/16
local ll = 1/2
local lf = 1/8
-- ================================================================== --
-- <><><><><><><><><><> Taking The Joke Too Far <><><><><><><><><><> --
-- ================================================================== --
minetest.register_node(modname .. ":staffbug", {
	description = "Staffbug",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
	selection_box = nodecore.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
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
		firestick = 2,
		crawling = 1,
		snappy = 1,
		flammable = 2,
		falling_repose = 2,
		stack_as_node = 1
	},
	sounds = nodecore.sounds("nc_tree_sticky")
})
------------------------------------------------------------------------
minetest.register_node(modname .. ":framebug", {
	description = "Framebug",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(
		{-lt, -ll, -lt, lt, ll, lt},
		{-ll, -lt, -lt, ll, lt, lt},
		{-lt, -lt, -ll, lt, lt, ll}
	),
	selection_box = nodecore.fixedbox(
		{-lf, -ll, -lf, lf, ll, lf},
		{-ll, -lf, -lf, ll, lf, lf},
		{-lf, -lf, -ll, lf, lf, ll}
	),
	tiles = {gtfbug},
	groups = {
		bug = 1,
		stickbug = 1,
		crawling = 1,
		snappy = 1,
		flammable = 2,
		fire_fuel = 1,
		falling_node = 1,
		stack_as_node = 1
	},
	paramtype = "light",
	climbable = true,
	sunlight_propagates = true,
	sounds = nodecore.sounds("nc_tree_sticky")
})
------------------------------------------------------------------------
minetest.register_node(modname .. ":ladderbug", {
	description = "Ladderbug",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(
		{-lt, -ll, -lt, lt, ll, lt},
		{-lw, -lt, -lt, lw, lt, lt},
		{-lt, -lt, -lw, lt, lt, lw}
	),
	selection_box = nodecore.fixedbox(-lw, -ll, -lw, lw, ll, lw),
	tiles = {gtfbug},
	groups = {
		bug = 1,
		stickbug = 1,
		crawling = 1,
		snappy = 1,
		flammable = 2,
		fire_fuel = 1,
		falling_node = 1,
		stack_as_node = 1
	},
	crush_damage = 0.25,
	paramtype = "light",
	sunlight_propagates = true,
	climbable = true,
	sounds = nodecore.sounds("nc_tree_sticky")
})
------------------------------------------------------------------------
adzecaps.groupcaps.crumbly.uses = adzecaps.groupcaps.choppy.uses
minetest.register_tool(modname .. ":adzebug", {
	description = "Adzebug",
	inventory_image = "nc_woodwork_adze.png^(nc_tree_peat.png^[mask:nc_lode_adze.png)",
	groups = {
		bug = 1,
		stickbug = 1,
		crawling = 1,
		firestick = 2,
		flammable = 2
	},
	tool_capabilities = adzecaps,
	sounds = nodecore.sounds("nc_tree_sticky")
})
------------------------------------------------------------------------
local rakevol = nodecore.rake_volume(2, 1)
local raketest = nodecore.rake_index(function(def)
		return def.groups and def.groups.falling_node
		and def.groups.snappy == 1
	end)
minetest.register_tool(modname .. ":rakebug", {
	description = "Rakebug",
	inventory_image = "nc_woodwork_rake.png^(nc_tree_peat.png^[mask:nc_lode_rake.png)",
	tool_capabilities = nodecore.toolcaps({
		snappy = 1,
		uses = 10
	}),
	groups = {
		bug = 1,
		stickbug = 1,
		crawling = 1,
		flammable = 1,
		rakey = 1,
		nc_doors_pummel_first = 1
	},
	sounds = nodecore.sounds("nc_tree_sticky"),
	on_rake = function() return rakevol, raketest end
})
-- ================================================================== --
nodecore.register_craft({
	label = "assemble staffbug",
	normal = {y = 1},
	indexkeys = {modname .. ":stickbug"},
	nodes = {
		{match = modname .. ":stickbug", replace = "air"},
		{y = -1, match = modname .. ":stickbug", replace = modname .. ":staffbug"}
	}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "assemble framebug",
	normal = {x = 1},
	indexkeys = {modname .. ":staffbug"},
	nodes = {
		{match = modname .. ":staffbug", replace = "air"},
		{x = -1, match = modname .. ":staffbug", replace = modname .. ":framebug"},
	}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "assemble wood ladder",
	normal = {x = 1},
	indexkeys = {modname .. ":stickbug"},
	nodes = {
		{match = modname .. ":stickbug", replace = "air"},
		{x = -1, match = modname .. ":staffbug", replace = modname .. ":ladderbug"},
	}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "assemble adzebug",
	normal = {y = 1},
	indexkeys = {modname .. ":stickbug"},
	nodes = {
		{match = modname .. ":stickbug", replace = "air"},
		{y = -1, match = modname .. ":staffbug", replace = "air"},
	},
	items = {{y = -1, name = modname .. ":adzebug"}
	}
})
------------------------------------------------------------------------
local adze = {name = modname .. ":adzebug", wear = 0.05}
nodecore.register_craft({
		label = "assemble rakebug",
		indexkeys = {modname .. ":adzebug"},
		nodes = {
			{match = adze, replace = "air"},
			{y = -1, match = modname .. ":staffbug", replace = "air"},
			{x = -1, match = adze, replace = "air"},
			{x = 1, match = adze, replace = "air"},
		},
		items = {{
				y = -1,
				name = modname .. ":rakebug"
		}}
	})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "artificial torchbug",
	normal = {y = 1},
	indexkeys = {"nc_fire:lump_coal"},
	nodes = {
		{match = "nc_fire:lump_coal", replace = "air"},
		{y = -1, match = modname .. ":staffbug", replace = modname .. ":torchbug"},
	},
})
-- ================================================================== --
nodecore.register_craft({
	label = "smush staffbug",
	action = "pummel",
	indexkeys = {modname .. ":staffbug"},
	nodes = {{match = modname .. ":staffbug", replace = "air"}},
	items = {{name = "nc_woodwork:staff", count = 1}},
	toolgroups = {thumpy = 1}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "smush framebug",
	action = "pummel",
	indexkeys = {modname .. ":framebug"},
	nodes = {{match = modname .. ":framebug", replace = "air"}},
	items = {{name = "nc_woodwork:frame", count = 1}},
	toolgroups = {thumpy = 1}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "smush ladderbug",
	action = "pummel",
	indexkeys = {modname .. ":ladderbug"},
	nodes = {{match = modname .. ":ladderbug", replace = "air"}},
	items = {{name = "nc_woodwork:ladder", count = 1}},
	toolgroups = {thumpy = 1}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "smush adzebug",
	action = "pummel",
	indexkeys = {modname .. ":adzebug"},
	nodes = {{match = modname .. ":adzebug", replace = "air"}},
	items = {{name = "nc_woodwork:adze", count = 1}},
	toolgroups = {thumpy = 1}
})
------------------------------------------------------------------------
nodecore.register_craft({
	label = "smush rakebug",
	action = "pummel",
	indexkeys = {modname .. ":rakebug"},
	nodes = {{match = modname .. ":rakebug", replace = "air"}},
	items = {{name = "nc_woodwork:rake", count = 1}},
	toolgroups = {thumpy = 1}
})
-- ================================================================== --
