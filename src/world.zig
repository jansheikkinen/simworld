// world.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const Mod = @import("mod.zig").Mod;
const creature_lib = @import("creature.zig");
const tile_lib = @import("tile.zig");


pub const World = struct {
  size: usize = 16,
  allocator: std.mem.Allocator,
  tiles: std.ArrayList(tile_lib.Tile),
  creatures: std.ArrayList(creature_lib.Creature),


  pub fn init(size: usize, allocator: std.mem.Allocator) !World {
    return World {
      .size = size,
      .allocator = allocator,
      .tiles = try std.ArrayList(tile_lib.Tile)
        .initCapacity(allocator, size * size),
      .creatures = std.ArrayList(creature_lib.Creature).init(allocator),
    };
  }


  pub fn deinit(self: *World) void {
    self.tiles.deinit();
    self.creatures.deinit();
  }
};
