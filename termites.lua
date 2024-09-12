-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local logtop = "nc_tree_tree_top.png"
local logside = "nc_tree_tree_side.png"
local roots = "nc_tree_roots.png"
local plank = "nc_woodwork_plank.png"
local dirt = "nc_terrain_dirt.png"
local mites = "nc_tree_peat.png^[colorize:black:200"
local mound = "(" ..logside.. "^[colorize:gray:20)^(" ..mites.. "^[opacity:200)"
-- ================================================================== --
for i = 1,4 do
  local o = (i*50)
------------------------------------------------------------------------  
  local ilogtop = "(" ..logtop.. ")^(" ..mites.. "^[opacity:" ..o.. ")"
  local ilogside = "(" ..logside.. ")^(" ..mites.. "^[opacity:" ..o.. ")"
  local iroots = dirt.. "^(" ..roots.. ")^(" ..mites.. "^[opacity:" ..o.. ")"
  local iplank = "(" ..plank.. ")^(" ..mites.. "^[opacity:" ..o.. ")"

  local ilog = {ilogtop, ilogtop, ilogside}
  local istump = {ilogtop, dirt, iroots}
------------------------------------------------------------------------
  local function infested(mitenode, oldnode, mitetiles)
    local wood = oldnode
	local mitedef = nodecore.underride({
--		description = desc,
		tiles = mitetiles,
		groups = {infested = i},
	}, minetest.registered_items[wood] or {})
	minetest.register_node(mitenode, mitedef)
  end
------------------------------------------------------------------------
  infested(modname.. ":plank_infested_" ..i, "nc_woodwork:plank", {iplank})
  infested(modname.. ":log_infested_" ..i, "nc_tree:log", ilog)
  infested(modname.. ":tree_infested_" ..i, "nc_tree:tree", ilog)
  infested(modname.. ":root_infested_" ..i, "nc_tree:root", istump)
------------------------------------------------------------------------
end
-- ================================================================== --
minetest.register_node(modname .. ":mound", {
	description = "Termite Nest",
	tiles = {mound},
	groups = {
		choppy = 1, crumbly = 2,
		flammable = 12,
		fire_fuel = 6,
		mound = 1,
		infested = 5,
		falling_node = 1,
		peat_grindable_node = 1,
		scaling_time = 65
	},
	sounds = nodecore.sounds("nc_tree_chompy"),
})
------------------------------------------------------------------------
local function termites(pos)
	minetest.add_particlespawner({
		time = 10,
		amount = 20,
		minpos = pos,
		maxpos = pos,
		minacc = {x = -0.2, y = -0.2, z = -0.2},
		maxacc = {x = 0.2, y = 0.2, z = 0.2},
		minexptime = 2,
		maxexptime = 3,
		minsize = 0.3,
		maxsize = 0.5,
		texture = "nc_woodwork_ladder_mask.png^[colorize:black",
		collisiondetection = true,
		collision_removal = true,
	})
end
nodecore.register_abm({
	label = "particles:termites",
	interval = 10,
	chance = 1,
	nodenames = {"group:infested"},
	action = function(pos)
		termites(pos)
	end
})
-- ================================================================== --
local function termite_spread(oldnode, newnode)
	nodecore.register_abm({
		label = "Termite Infestation",
		nodenames = {oldnode},
		neighbors = {"group:infested"},
		neighbors_invert = true,
		interval = 300,
		chance = 10,
		action = function(pos)
			minetest.set_node(pos, {name = newnode})
		end
	})
end
termite_spread("nc_tree:tree",		modname.. ":tree_infested_1")
termite_spread("nc_tree:root",		modname.. ":root_infested_1")
termite_spread("nc_tree:log",		modname.. ":log_infested_1")
termite_spread("nc_woodwork:plank",	modname.. ":plank_infested_1")

termite_spread(modname.. ":tree_infested_4",	modname.. ":mound")
termite_spread(modname.. ":root_infested_4",	modname.. ":mound")
termite_spread(modname.. ":log_infested_4",		modname.. ":mound")
termite_spread(modname.. ":plank_infested_4",	modname.. ":mound")

for i = 1,3 do
  termite_spread(modname.. ":tree_infested_" ..i,		modname.. ":tree_infested_" ..i+1)
  termite_spread(modname.. ":root_infested_" ..i,		modname.. ":root_infested_" ..i+1)
  termite_spread(modname.. ":log_infested_" ..i,		modname.. ":log_infested_" ..i+1)
  termite_spread(modname.. ":plank_infested_" ..i,		modname.. ":plank_infested_" ..i+1)
end
-- ================================================================== --
--minetest.register_decoration({
--		label = {modname .. ":mound"},
--		deco_type = "simple",
--		place_on = {"group:soil"},
--		sidelen = 16,
--		fill_ratio = 0.00025,
--		biomes = {"unknown"},
--		y_max = 32,
--		y_min = 8,
--		decoration = {modname .. ":mound"}
--	})

local c_tree = minetest.get_content_id("nc_tree:tree")
local c_termites = minetest.get_content_id(modname..":tree_infested_1")
nodecore.register_mapgen_shared({
  label = "termite spawn",
  func = function(minp, maxp, area, data, _, _, _, rng)
    local ai = area.index
    for z = minp.z, maxp.z do
      for y = minp.y, maxp.y do
        local offs = ai(area, 0, y, z)
        for x = minp.x, maxp.x do
          local i = offs + x
          if data[i] == c_tree and rng(1, 500) == 1 then
            data[i] = c_termites
          end
        end
      end
    end
  end
})
