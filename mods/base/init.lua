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
  core.initWorldGenerator("wg1", function(_)
    print("Howdy, world!")
  end),
  core.initWorldGenerator("wg2", function(size)
    local tiless = {}
    for y = 0, size do
      for x = 0, size do
        tiless[(y * size) + x + 1] = core.initTile(MOD_ID, (x + y) % 2, 0)
      end
    end

    return tiless
  end),
}

core.registerMod("base", tiles, creatures, generators)
