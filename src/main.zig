// main.zig

const std = @import("std");

const ziglua = @import("ziglua");

const world_lib = @import("world.zig");
const mod_lib = @import("mod.zig");
const Game = @import("game.zig").Game;
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

  try game.newWorld(&api.lua, 16, Vector2(usize).init(0, 1));

  if (game.world) |world| {
    var i: usize = 0;
    var y: usize = 0;
    while (y < world.size) : (y += 1) {
      var x: usize = 0;
      while (x < world.size) : (x += 1) {
        const vec = Vector2(usize).init(x, y);
        const tile = world.tiles[vec.toIndex(world.size)];
        if ((i % world.size) == 0) std.debug.print("\n", .{});
        i += 1;

        if (tile.getTileType(&game).isEqual(game.mods.items[0].tiles[0])) {
          std.debug.print("＃", .{});
        } else {
          std.debug.print("・", .{});
        }
      }
    }
  }
}
