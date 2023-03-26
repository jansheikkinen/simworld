// creature.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const Vector2 = @import("vector.zig").Vector2;
const Game = @import("game.zig").Game;


pub const Creature = struct {
  kind: Vector2(usize),
  age: usize,
  position: Vector2(usize),


  pub fn init(kind: Vector2(usize), position: Vector2(usize)) Creature {
    return Creature { .kind = kind, .age = 0, .position = position };
  }


  pub fn getTileType(self: Creature, game: *const Game) *const CreatureType {
    return &game.mods.items[self.kind.x].creatures[self.kind.y];
  }


  pub fn getName(self: Creature, game: *const Game) []const u8 {
    return self.getTileType(game).name;
  }


  pub fn getDescription(self: Creature, game: *const Game) []const u8 {
    return self.getTileType(game).description;
  }
};


pub const CreatureType = struct {
  name: []const u8,
  description: []const u8,


  pub fn init(name: []const u8, description: []const u8) CreatureType {
    return CreatureType { .name = name, .description = description };
  }


  /// fn fromLua(name: []const u8, description: []const u8) CreatureType
  pub fn fromLua(ctx: *Lua) i32 {
    const name = ctx.toString(-2) catch return @errorToInt(error.WrongType);
    const desc = ctx.toString(-1) catch return @errorToInt(error.WrongType);

    const creature = ctx.newUserdata(CreatureType, 0);
    creature.name = name[0..std.mem.len(name)];
    creature.description = desc[0..std.mem.len(desc)];

    return 1;
  }
};
