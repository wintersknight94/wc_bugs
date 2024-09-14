-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local rfcall = function(pos, data)
	local ref = minetest.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end
------------------------------------------------------------------------
local mothanim = {
	name = modname .. "_luxmoth.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.4
	},
}
local calmanim = {
	name = modname .. "_torchbug.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 1.8
	},
}
local fireanim = {
	name = modname .. "_firebug.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 0.8
	},
}
local peatanim = "(nc_tree_humus.png^nc_tree_peat.png)^[mask:nc_lode_mask_prill.png"
local lodeanim = "nc_lode_annealed.png^[mask:nc_lode_mask_prill.png"
local suckanim = modname.. "_leech.png"
local miteanim = "nc_api_craft_smoke.png"
local glass = "nc_optics_glass_edges.png^(nc_tree_tree_side.png^[mask:nc_optics_tank_mask.png)"
-- ================================================================== --

local function register_bugjar(bug, desc, buganim, light, glow)
-- <>--------------------------------------------------------------<> --
	minetest.register_node(modname .. ":jar_" ..bug, {
		description = desc.. " Specimen",
		drawtype = "mesh",
		mesh = "plantlikestorebox.obj",
		tiles = {glass, glass, glass, buganim},
		use_texture_alpha = "blend",
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			bugjar = 1,
			snappy = 1,
			totable = 1,
			scaling_time = 60,
			stack_as_node = 1
		},
		light_source = light,
		glow = glow,
		stack_max = 1,
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_optics_glassy")
	})
------------------------------------------------------------------------
	nodecore.register_craft({
		label = "Encase " ..desc,
		action = "pummel",
		wield = {name = "nc_optics:shelf_float"},
		after = rfcall,
		nodes = {
			{match = modname..":" ..bug, replace = modname .. ":jar_" ..bug}
		}
	})
------------------------------------------------------------------------
--[[	nodecore.register_craft({
		label = "Release " ..desc.. " Specimen",
		action = "pummel",
		toolgroups = {cracky = 2},
		indexkeys = {modname .. ":jar_" ..bug},
		nodes = {
			{match = modname .. ":jar_" ..bug, replace = "nc_optics:shelf_float"}
		},
		after=function(pos)
			local yield = math.random(0,1)
			nodecore.item_eject(pos, {name = modname.. ":" ..bug}, 1, 1)
		end
	})
]]
-- <>--------------------------------------------------------------<> --
end
-- ================================================================== --
--register_bugjar(bug, desc, buganim, light, glow)
register_bugjar("luxmoth",		"Luxmoth",		mothanim,	3,		1)
register_bugjar("torchbug",		"Torchbug",		calmanim,	1,		1)
register_bugjar("flamebug",		"Torchbug",		fireanim,	5,		1)

register_bugjar("peatle",		"Peatle",		peatanim,	nil,	nil)
register_bugjar("prillbug",		"Prillbug",		lodeanim,	nil,	nil)
--register_bugjar("lodewurm",	"Lodewurm",		wurmanim,	1,		1)
register_bugjar("termite",		"Termite",		miteanim,	nil,	nil)
register_bugjar("leech",		"Leech",		suckanim,	nil,	nil)

--register_bugjar("sparkbug",	"Sparkbug",		zappanim,	4,		1)
