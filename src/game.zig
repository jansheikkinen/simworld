// game.zig

const std = @import("std");

const Mod = @import("mod.zig").Mod;
const World = @import("world.zig").World;


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


  pub fn newWorld(self: *Game, size: usize) !void {
    self.world = try World.init(size, self.allocator);
  }
};
