// main.zig

const std = @import("std");
const ziglua = @import("ziglua").Lua;

const world_lib = @import("world.zig");
const mod_lib = @import("mod.zig");
const Game = @import("game.zig").Game;


pub fn main() anyerror!void {
  std.debug.print("\n", .{}); // because zig doesn't do this for you

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();


  var game = Game.init(allocator);
  defer game.deinit();

  try game.newWorld(16);


  var api = try mod_lib.LuaAPI.init(allocator);
  defer api.deinit();
  try api.loadAPIAndMods(&game);


  for (game.mods.items) |modd| {
    std.debug.print("{s}\n", .{ modd.name });

    std.debug.print(" tiles:\n", .{});
    for (modd.tiles) |tile| std.debug.print("  {s} {s}\n",
      .{ tile.name, tile.description });

    std.debug.print(" creatures:\n", .{});
    for (modd.creatures) |creature| std.debug.print("  {s} {s}\n",
      .{ creature.name, creature.description });
  }
}
