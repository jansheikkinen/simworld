// tile.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const World = @import("world.zig").World;


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
