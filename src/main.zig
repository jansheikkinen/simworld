// main.zig

const std = @import("std");

const world_lib = @import("world.zig");
const mod_lib = @import("mod.zig");
const Game = @import("game.zig").Game;

const Tile = @import("tile.zig").Tile;
const Vector2 = @import("vector.zig").Vector2;

pub fn main() anyerror!void {
  std.debug.print("\n", .{}); // because zig doesn't do this for you

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();


  var game = Game.init(allocator);
  defer game.deinit();


  var api = try mod_lib.LuaAPI.init(allocator);
  defer api.deinit();
  try api.loadAPIAndMods(&game);

  const c = Tile.init(Vector2(usize).init(0, 0), 0);
  std.debug.print("{s}: {s}\n", .{ c.getName(&game), c.getDescription(&game) });


  try game.newDebugWorld(16);

  for (game.world.?.tiles) |tile| {
    if (tile.height % game.world.?.size == 0) std.debug.print("\n", .{});

    if (tile.kind.y == 0) {
      std.debug.print("# ", .{});
    } else
      std.debug.print(". ", .{});
  }
}
