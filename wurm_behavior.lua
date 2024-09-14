-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------

local modname = minetest.get_current_modname()
local dirs = {
  {x=-1,y=0,z=0 },
  {x=1 ,y=0,z=0 },
  {x=0 ,y=0,z=-1},
  {x=0 ,y=0,z=1 }
}

local function is_snake_eatable(pos,body)
  local node = minetest.get_node(pos)
  if body then
    local f,p = nodecore.is_snake_eatable(pos)
    local down = vector.add(body[1].pos,{x=0,y=-1,z=0})
    local up = vector.add(body[1].pos,{x=0,y=1,z=0})
    if vector.equals(down,pos) then
      return f,p
    end
    local prebodis = {}
    local bodis
    for k,v in ipairs(body) do
      prebodis[v] = true
    end
    for n=1,4 do
      bodis = {}
      for v,_ in pairs(prebodis) do
        bodis[minetest.hash_node_position(v.pos)] = true
      end
      for v,_ in pairs(prebodis) do
        for y=-1,0 do
          local brek = false
          for _,dir in ipairs(dirs) do
            local pp = vector.add(vector.add(v.pos,dir),{x=0,y=y,z=0})
            if not nodecore.is_snake_eatable(pp) and not bodis[minetest.hash_node_position(pp)] then
              prebodis[v] = nil
              brek = true
              break
            end
          end
          if brek then break end
        end
      end
    end
    bodis = {}
    for v,_ in pairs(prebodis) do
      bodis[minetest.hash_node_position(v.pos)] = true
    end
    if vector.equals(up,pos) then
      for y=-1,0 do
        for _,dir in ipairs(dirs) do
          local pp = vector.add(vector.add(pos,dir),{x=0,y=y,z=0})
          if not bodis[minetest.hash_node_position(pp)] and not nodecore.is_snake_eatable(pp) then
            return f,p
          end
        end
      end
      return
    end
    if (not bodis[minetest.hash_node_position(vector.add(pos,{x=0,y=-1,z=0}))] and not nodecore.is_snake_eatable(vector.add(pos,{x=0,y=-1,z=0}))) or
       (not bodis[minetest.hash_node_position(vector.add(body[1].pos,{x=0,y=-1,z=0}))] and not nodecore.is_snake_eatable(vector.add(body[1].pos,{x=0,y=-1,z=0}))) then
      return f,p
    end
    return
  else
    local fleaves,fpeat = 1/9,1
    if nodecore.buildable_to(pos) then
      return 0,0.001
    end
    if node.name == "nc_terrain:gravel" or node.name == "nc_terrain:sand" or node.name == "nc_terrain:dirt" or node.name == "nc_terrain:dirt_with_grass" then
      return fleaves,fleaves/0.5
    end
    if node.name == "nc_terrain:stone" or node.name == "nc_concrete:sandstone" or node.name == "nc_concrete:adobe" or node.name == "nc_concrete:cloudstone" or node.name == "nc_concrete:coalstone" then
      return fleaves,fleaves/1
    end
	if node.name == "nc_terrain:hard_stone_1" or node.name == "nc_terrain:hard_stone_2" or node.name == "nc_terrain:hard_stone_3" or node.name == "nc_terrain:hard_stone_4" or node.name == "nc_terrain:hard_stone_5" or node.name == "nc_terrain:hard_stone_6" or node.name == "nc_terrain:hard_stone_7" then
      return fleaves,fleaves/1
	end
    if node.name == "nc_lode:stone" or node.name == "nc_lode:stone_1" or node.name == "nc_lode:stone_2" or node.name == "nc_lode:stone_3" or node.name == "nc_lode:stone_4" or node.name == "nc_lode:stone_5" or node.name == "nc_lode:stone_6" or node.name == "nc_lode:stone_7" then
      return fleaves,fleaves/2
    end
    if node.name == "nc_lode:ore" or node.name == "nc_lode:ore_1" or node.name == "nc_lode:ore_2" or node.name == "nc_lode:ore_3" then
      return fpeat,fpeat/8 --32
    end
    if node.name == "nc_lode:ore_4" or node.name == "nc_lode:ore_5" or node.name == "nc_lode:ore_6" or node.name == "nc_lode:ore_7" then
      return fpeat,fpeat/16 --64
    end
  end
end
nodecore.is_snake_eatable = is_snake_eatable

function nodecore.snake_attractiveness(pos)
  local node = minetest.get_node(pos)
  local score = 0
--  local l = ((minetest.get_node_light(pos) or 0)/15*2-1) * 3
--  score=score+l
  local f,p = nodecore.is_snake_eatable(pos)
  if f then
    score = score + (f^2) * 100
  end
  return score
end

function nodecore.snake_check(pos,r,am)
  local score = 0
  r = r or 10
  am = am or {}
  for x=pos.x-r,pos.x+r do
    for y=pos.y-r,pos.y+r do
      for z=pos.z-r,pos.z+r do
        local rpos = pos
        local pos = {x=x,y=y,z=z}
        local h = minetest.hash_node_position(pos)
        local dx,dy,dz = pos.x-rpos.x,pos.y-rpos.y,pos.z-rpos.z
        dy = dy*0.6
        local d = dx*dx+dy*dy+dz*dz
        if d > 0 then
          d = d^0.5
          if (r-d) > 0 then
            local v = am[h] or nodecore.snake_attractiveness(pos)
            score = score + v * ((r-d)/r)^1.5
            am[h] = v
          end
        end
      end
    end
  end
  score = score + nodecore.is_snake_eatable(pos)*10000
  return -score
end

local function eatsound(pos)
  local node = minetest.get_node(pos)
  local def = minetest.registered_items[node.name]
  if def.sounds and def.sounds.dug then
    nodecore.sound_play(def.sounds.dug, {gain = 4, pos = pos})
  end
end

local function snake_step(pos,node)
  local meta = minetest.get_meta(pos)
  local len = meta:get_int("snake_len")
  local body = {{pos=pos,node=node}}
  local head = body[1]
  local cut = false
  for n=1,len do
    local rpos = pos
    local pos = minetest.string_to_pos(meta:get_string("snake_body"..n))
    if pos then
      local node = minetest.get_node(pos)
      if node.name == "ignore" then
        return rpos
      end
      if minetest.get_item_group(node.name,"snake_body") == 0 then
        print("ouch",n-1)
        len = n-1
        meta:set_int("snake_len",len)
        cut = true
      end
      if not cut then
        body[#body+1] = {pos=pos,node=node}
      elseif minetest.get_item_group(node.name,"snake_body") > 0 then
        minetest.set_node(pos,{name="nc_concrete:terrain_stone_bindy"})
      end
    end
  end
  local tail = body[#body]
  local poop = meta:get_float("snake_poop")
  local food = meta:get_float("snake_food")
  local dir = minetest.facedir_to_dir(head.node.param2)
  local fposes = {vector.add(pos,{x=0,y=1,z=0}),vector.add(pos,{x=0,y=-1,z=0}),vector.add(pos,dir)}
  local ascores = {}
  local aposes = {}
  local am = {}
  for n=0,3 do
    local d = vector.add(pos,minetest.facedir_to_dir(n))
    local f,p = nodecore.is_snake_eatable(d,body)
    if f then
      local score = nodecore.snake_check(d,nil,am)+math.random()*0.2-0.1
      ascores[#ascores+1] = score
      aposes[score]={n,d,f,p}
    end
  end
  for k,d in ipairs(fposes) do
    local f,p = nodecore.is_snake_eatable(d,body)
    if f then
      local score = nodecore.snake_check(d,nil,am)+math.random()*0.2-0.1
      ascores[#ascores+1] = score
      aposes[score]={head.node.param2,d,f,p}
    end
  end
  local rnpos
  if #ascores > 0 then
    table.sort(ascores)
    local n,d,f,p = unpack(aposes[ascores[1]])
    food = food + f
    poop = poop + p
    head.node.param2 = n
    eatsound(d)
    rnpos = d
  else
    local f,p = nodecore.is_snake_eatable(fposes[3])
    if f then
      food = food + f
      poop = poop + p
      eatsound(fposes[3])
      rnpos = fposes[3]
    end
  end
  if rnpos then
    local bodyname = minetest.registered_items[head.node.name].alternative_body
    local ohnode = head.node
    head.node = {name=bodyname}
    minetest.set_node(head.pos,head.node)
    minetest.set_node(rnpos,{name=modname..":head",param2=ohnode.param2})
    local metb = minetest.get_meta(rnpos)
    local bodyb = {}
    for k,v in ipairs(body) do
      bodyb[#bodyb+1] = minetest.pos_to_string(v.pos)
    end
    table.insert(body,1,{pos=rnpos,node=minetest.get_node(rnpos)})
    head = body[1]
    tail = body[#body]
    for n=1,#bodyb do
      metb:set_string("snake_body"..n,bodyb[n])
    end
    if #body-1 >= len then
      len = #body-1
    end
    metb:set_int("snake_len",len)
    metb:set_float("snake_food",food)
    metb:set_float("snake_poop",poop)
    meta = metb
    pos = rnpos
    --[[do
      local am = {}
      local scores = {}
      local fscores = {}
      for n=0,3 do
        local d = vector.add(pos,minetest.facedir_to_dir(n))
        if nodecore.is_snake_eatable(d,body) then
          local score = nodecore.snake_check(d,r,am)
          if n == head.node.param2 then
            score = score
          end
          fscores[score] = n
          scores[#scores+1] = score
        end
      end
      table.sort(scores)
      --print(scores[1],scores[2],scores[3],scores[4])
      head.node.param2 = fscores[scores[1] ]
      local t = meta:to_table()
      minetest.set_node(rnpos,{name=head.node.name,param2=head.node.param2})
      meta = minetest.get_meta(pos)
      meta:from_table(t)
    end]]
    local tailmoved = false
    --print(len,#body-1)
    if len == (#body-1) then
      if poop > 1 and body[2] and minetest.get_item_group(body[2].node.name,"snake_poop") == 0 then
        poop = poop-1
        meta:set_float("snake_poop",poop)
        body[2].node.name = modname..":body_lodey"
        minetest.set_node(body[2].pos,body[2].node)
      end
      if food < 1 then
        minetest.set_node(tail.pos,{name = "air"})
        len = len - 1
        meta:set_int("snake_len",len)
        body[#body] = nil
        tailmoved = true
        if minetest.get_item_group(tail.node.name,"snake_poop") > 0 then
          nodecore.item_eject(tail.pos,{name=minetest.registered_items[tail.node.name].snake_poop})
          tail = body[#body]
          minetest.set_node(tail.pos,{name = "air"})
          if #body > 1 then
            len = len - 1
            meta:set_int("snake_len",len)
          end
        end
      else
        food = food - 1
        meta:set_float("snake_food",food)
      end
    end
  end
  return pos
end

local DEFAULT_TIMER = 0.5

function nodecore.snake_step(pos,elapsed)
  --local ts = minetest.get_us_time()
  if not nodecore.stasis then
    pos = snake_step(pos,minetest.get_node(pos))
  end
  --print("snake step took " .. (minetest.get_us_time()-ts)/1000000 .. " sec")
  nodecore.dnt_set(pos,modname..":snekstep")
end

function nodecore.snake_construct(pos)
  local meta = minetest.get_meta(pos)
  if meta:get_int("snake_gen") ~= 0 then
    nodecore.dnt_set(pos,modname..":snekstep")
    return
  end
  minetest.set_node(pos,{name=modname..":head",param2=math.random(0,3)})
  meta = minetest.get_meta(pos) -- not sure if setting nodes replaces the metadata object
  local timer = minetest.get_node_timer(pos)
  local t = DEFAULT_TIMER
  nodecore.dnt_set(pos,modname..":snekstep")
  meta:set_int("snake_len",2)
  meta:set_int("snake_gen",1)
end


nodecore.register_craft({
		label = "hatch wurm from egg",
		action = "pummel",
		toolgroups = {thumpy = 3, cracky = 3},
		nodes = {
			{match = {groups={wurm_egg=true}}}
		},
		after=function(data)
			nodecore.snake_construct(data)
		end
	})

