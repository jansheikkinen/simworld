// tile.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const World = @import("world.zig").World;
const Game = @import("game.zig").Game;
const Vector2 = @import("vector.zig").Vector2;


pub const Tile = struct {
  kind: Vector2(usize),
  height: u16,


  pub fn init(kind: Vector2(usize), height: u16) Tile {
    return Tile { .kind = kind, .height = height };
  }


  pub fn getTileType(self: Tile, game: *const Game) *const TileType {
    return &game.mods.items[self.kind.x].tiles[self.kind.y];
  }


  pub fn getName(self: Tile, game: *const Game) []const u8 {
    return self.getTileType(game).name;
  }


  pub fn getDescription(self: Tile, game: *const Game) []const u8 {
    return self.getTileType(game).description;
  }


  pub fn toLua(self: Tile, ctx: *Lua) void {
    const tile = ctx.newUserdata(Tile, 0);
    tile.kind = self.kind;
    tile.height = self.height;
  }


  pub fn fromLua(ctx: *Lua) i32 {
    const x = ctx.toInteger(-3) catch unreachable;
    const y = ctx.toInteger(-2) catch unreachable;
    const h = ctx.toInteger(-1) catch unreachable;

    const tile = ctx.newUserdata(Tile, 0);
    tile.kind = Vector2(usize).init(@intCast(usize, x), @intCast(usize, y));
    tile.height = @intCast(u16, h);

    return 1;
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


  pub fn isEqual(self: TileType, other: TileType) bool {
    return std.mem.eql(u8, self.name, other.name) and
           std.mem.eql(u8, self.description, other.description);
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
