-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------
local modname = minetest.get_current_modname()

local scales = "nc_lode_hot.png^[mask:nc_concrete_pattern_bindy.png"
local mouth = "nc_lode_hot.png^[mask:nc_concrete_pattern_iceboxy.png"
local dklode = "nc_lode_annealed.png^[colorize:black:50"

local mats = {
  {suffix=""},
  {
    suffix="_lodey",tile="nc_lode_hot.png^[mask:nc_lode_mask_ore.png",def={
      groups={
        snake_poop=1,
      },
      snake_poop = "nc_lode:block_hot"
    }
  }
}

for n=1,#mats do
  local mat = mats[n]
  local tile = "(" ..dklode.. ")^(" ..scales.. ")"
  if mat.tile then
    tile = "nc_lode_annealed.png^("..mat.tile..")^(" ..scales.. ")"
  end
  local headname = modname..":head"..mat.suffix
  local bodyname = modname..":body"..mat.suffix
  
  local def = nodecore.underride({
      tiles = {tile,tile,tile, tile,tile,tile},
      groups = {
        bug = 1,
        wurm = 1,
        lode = 1,
        cracky = 4,
        snake_body = 1
      },
      drop_in_place = "nc_concrete:terrain_stone_bindy",
      silktouch=false,
      crush_damage = 2,
	light_source = 2,
      sounds = nodecore.sounds("nc_lode_annealed"),
      alternative_head = headname,
      alternative_body = bodyname
    },mat.def or {})

  if mat.group then
    def.groups[mat.group] = 1
  end
  
  local def_h = nodecore.underride({
    paramtype2="facedir",
    description = "Lodewurm Head",
    tiles = {[5]=tile.."^(" ..mouth.. ")"},
    groups = {snake_head = 1},
    after_place_node = nodecore.snake_construct
  },def)

  local def_b = nodecore.underride({
    description = "Lodewurm Body",
    groups = {snake_body = 1}
  },def)

  minetest.register_node(headname,def_h)
  minetest.register_node(bodyname,def_b)
end

nodecore.register_dnt({
	name=modname..":snekstep",
	nodenames={modname..":head",modname.."head_lodey"},
	action=nodecore.snake_step,
	time=2,		--0.5,
	loop=true,
})
