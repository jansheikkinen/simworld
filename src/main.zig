// main.zig

const std = @import("std");

const ziglua = @import("ziglua");
const Lua = ziglua.Lua;

const worlds = @import("world.zig");
const creatures = @import("creature.zig");
const vector = @import("vector.zig");
const mod = @import("mod.zig");


pub fn main() anyerror!void {
  std.debug.print("\n", .{}); // because zig doesn't do this for you

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();

  const allocator = gpa.allocator();

  var lua = try Lua.init(allocator);
  defer lua.deinit();

  mod.LuaAPI.initAPI(&lua);

  var world = try worlds.World.init(16, allocator);
  defer world.deinit();

  lua.pushLightUserdata(&world);
  lua.setGlobal("_World");

  try lua.doFile("mods/base/init.lua");

  for (world.mods.items) |modd| {
    std.debug.print("{s}\n", .{ modd.name });

    std.debug.print(" tiles:\n", .{});
    for (modd.tiles) |tile| std.debug.print("  {s} {s}\n",
      .{ tile.name, tile.description });

    std.debug.print(" creatures:\n", .{});
    for (modd.creatures) |creature| std.debug.print("  {s} {s}\n",
      .{ creature.name, creature.description });
  }
}
