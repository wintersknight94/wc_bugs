-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local function metastat(metakey)
	local statcache = {}
	return function(player)
		local pname = player:get_player_name()
		local meta = player:get_meta()
		local found = statcache[pname]
		if not found then
			found = meta:get_float(metakey)
			statcache[pname] = found
		end
		return found, function(v)
			if v == found then return end
			found = v
			statcache[pname] = v
			meta:set_float(metakey, v)
		end
	end
end
local parasite = metastat("bloodsucker")
local suckrate = metastat("suckrate")

local leech = modname .. ":leech"
-- ================================================================== --
nodecore.register_virtual_item(leech, {
		description = "Leech",
		inventory_image = "[combine:1x1",
		hotbar_type = "leech",
	})
------------------------------------------------------------------------
nodecore.register_healthfx({
		item = leech,
		getqty = function(player) return bloodsucker(player) end,
		setqty = function(player, qty)
			if qty == 0 then
				local _, setrate = suckrate(player)
				setrate(0)
			end
			local _, set = bloodsucker(player)
			return set(qty)
		end
	})
-- ================================================================== --
