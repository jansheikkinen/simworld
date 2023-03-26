// game.zig

const std = @import("std");

const Mod = @import("mod.zig").Mod;
const World = @import("world.zig").World;
const Tile = @import("tile.zig").Tile;
const Vector2 = @import("vector.zig").Vector2;


pub const Options = struct {
  base_path:  []const u8 = "./",
  world_path: []const u8 = "worlds/",
  mod_path:   []const u8 = "mods/",
};


pub const Game = struct {
  options: Options = Options { },

  allocator: std.mem.Allocator,
  mods: std.ArrayList(Mod),

  world: ?World = null,


  pub fn init(allocator: std.mem.Allocator) Game {
    return Game {
      .allocator = allocator,
      .mods = std.ArrayList(Mod).init(allocator)
    };
  }


  pub fn deinit(self: *Game) void {
    if (self.world != null) self.world.?.deinit();

    for (self.mods.items) |mod| {
      self.allocator.free(mod.tiles);
      self.allocator.free(mod.creatures);
    }

    self.mods.deinit();
  }


  pub fn newDebugWorld(self: *Game, size: usize) !void {
    if (self.mods.items.len < 1) return error.MissingBaseMod;
    if (self.mods.items[0].tiles.len < 2) return error.WorldGenTwoTiles;

    self.world = try World.init(size, self.allocator);

    if (self.world) |world| {
      var i: u16 = 0;
      while (i < world.tiles.len) : (i += 1) {
        const vec = Vector2(usize).fromIndex(i, world.size);
        world.tiles[i] = Tile.init(
          Vector2(usize).init(0, (vec.x + vec.y) % 2),
          i % std.math.maxInt(u16));
      }
    }
  }
};
