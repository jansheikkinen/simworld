-- base.lua

-- luacheck: globals core

local MOD_ID = core.getModID()


local tiles = {
    core.initTileType("t1", "first tile"),
    core.initTileType("t2", "second tile"),
}

local creatures = {
    core.initCreatureType("c1", "first creature"),
    core.initCreatureType("c2", "second creature"),
}

local generators = {
  core.initWorldGenerator("wg1", function(size)
    print("[BASE]: using worldgen 0.0")

    local world = {}
    for i = 0, size * size do
      world[i] = core.initTile(MOD_ID, i % 2, 0)
    end

    return world
  end),

  core.initWorldGenerator("wg2", function(size)
    print("[BASE]: using worldgen 0.1")

    local world = {}
    local i = 0

    for y = 0, size - 1 do
      for x = 0, size - 1 do
        i = i + 1
        world[i] = core.initTile(MOD_ID, (x + y) % 2, 0)
      end
    end

    return world
  end),
}

core.registerMod("base", tiles, creatures, generators)
