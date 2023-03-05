-- LUALOCALS < ---------------------------------------------------------
local include, minetest, nodecore
    = include, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------

include("crawling")
include("flying")
--include("burrowing")

include("peatle")
include("prillbug")
include("stickbug")
include("torchbug")
include("luxmoth")

if minetest.settings:get_bool(modname .. ".termites", true) then
	include("termites")
	--include("ants")
end

--include("leech")

include("killcommand")

if minetest.settings:get_bool(modname .. ".toofar", true) then
	include("gone_too_far")
end

if minetest.settings:get_bool(modname .. ".tremors", true) then
	include("wurm_behavior")
	include("wurm_node")
	include("wurm_gen")
end
