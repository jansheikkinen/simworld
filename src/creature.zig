// creature.zig

const std = @import("std");
const Lua = @import("ziglua").Lua;

const Vector2 = @import("vector.zig").Vector2(usize);
const World = @import("world.zig").World;


pub const Creature = struct {
  kind: usize,
  age: usize,
  position: Vector2,


  pub fn init(kind: usize, x: usize, y: usize) Creature {
    return Creature { .kind = kind, .age = 0, .position = Vector2.init(x, y) };
  }


  pub fn getName(self: Creature, world: *const World) []const u8 {
    return world.creature_types.items[self.kind].name;
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
