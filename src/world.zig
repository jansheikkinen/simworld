// world.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const Mod = @import("mod.zig").Mod;
const creature_lib = @import("creature.zig");
const tile_lib = @import("tile.zig");


pub const World = struct {
  allocator: std.mem.Allocator,
  size: usize = 16,
  tiles: []tile_lib.Tile,
  creatures: std.ArrayList(creature_lib.Creature),


  pub fn init(size: usize, allocator: std.mem.Allocator) !World {
    return World {
      .size = size,
      .allocator = allocator,
      .tiles = try allocator.alloc(tile_lib.Tile, size * size),
      .creatures = std.ArrayList(creature_lib.Creature).init(allocator),
    };
  }


  pub fn deinit(self: *World) void {
    self.allocator.free(self.tiles);
    self.creatures.deinit();
  }
};
