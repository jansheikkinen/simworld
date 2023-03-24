// world.zig

const std = @import("std");

const Lua = @import("ziglua").Lua;

const Mod = @import("mod.zig").Mod;

const creature = @import("creature.zig");
const Creature = creature.Creature;
const CreatureType = creature.CreatureType;


pub const Tile = struct {
  kind: usize,
  height: u16,

  pub fn init(kind: usize, height: u16) Tile {
    return Tile { .kind = kind, .height = height };
  }

  pub fn getName(self: Tile, world: *const World) []const u8 {
    return world.tile_types.items[self.kind].name;
  }
};


pub const TileType = struct {
  name: []const u8,
  description: []const u8,

  pub fn init(name: []const u8, desc: []const u8) TileType {
    return TileType {
      .name = name,
      .description = desc,
    };
  }

  /// fn fromLua(name: []const u8, description: []const u8) TileType
  pub fn fromLua(ctx: *Lua) i32 {
    const name = ctx.toString(-2) catch return @errorToInt(error.WrongType);
    const desc = ctx.toString(-1) catch return @errorToInt(error.WrongType);

    const tile = ctx.newUserdata(TileType, 0);
    tile.name = name[0..std.mem.len(name)];
    tile.description = desc[0..std.mem.len(desc)];

    return 1;
  }
};


pub const World = struct {
  size: usize = 16,
  allocator: std.mem.Allocator,
  mods: std.ArrayList(Mod),
  tiles: std.ArrayList(Tile),
  creatures: std.ArrayList(Creature),

  pub fn init(size: usize, allocator: std.mem.Allocator) !World {
    return World {
      .size = size,
      .allocator = allocator,
      .tiles = try std.ArrayList(Tile).initCapacity(allocator, size * size),
      .mods = std.ArrayList(Mod).init(allocator),
      .creatures = std.ArrayList(Creature).init(allocator),
    };
  }

  pub fn deinit(self: *World) void {
    self.tiles.deinit();
    self.creatures.deinit();

    for (self.mods.items) |mod| {
      self.allocator.free(mod.tiles);
      self.allocator.free(mod.creatures);
    }
    self.mods.deinit();
  }
};
