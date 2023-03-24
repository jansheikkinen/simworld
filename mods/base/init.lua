-- base.lua

-- luacheck: globals core

local tiles = {
    core.initTileType("t1", "first tile"),
    core.initTileType("t2", "second tile"),
}

local creatures = {
    core.initCreatureType("c1", "first creature"),
    core.initCreatureType("c2", "second creature"),
}

core.registerMod("base", tiles, creatures)
