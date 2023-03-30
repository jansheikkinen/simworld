// world.zig

const std = @import("std");

const ziglua = @import("ziglua");
const Lua = ziglua.Lua;

const LuaAPI = @import("mod.zig").LuaAPI;
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


pub const WorldGenerator = struct {
  name: []const u8,
  reference: i32,

  /// fn fromLua(name: []const u8, reference: fn) WorldGenerator
  pub fn fromLua(ctx: *Lua) i32 {
    const name = LuaAPI.expectString(ctx, -2);
    const reference = LuaAPI.expectAndRegisterFunction(ctx);

    const worldgen = ctx.newUserdata(WorldGenerator, 0);
    worldgen.name = name[0..std.mem.len(name)];
    worldgen.reference = reference;

    return 1;
  }
};
