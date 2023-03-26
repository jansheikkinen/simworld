// game.zig

const std = @import("std");

const ziglua = @import("ziglua");
const Lua = ziglua.Lua;

const mod_lib = @import("mod.zig");
const Mod = mod_lib.Mod;
const LuaAPI = mod_lib.LuaAPI;

const World = @import("world.zig").World;
const Tile = @import("tile.zig").Tile;
const Vector2 = @import("vector.zig").Vector2;


pub const Options = struct {
  base_path:  []const u8 = "./",
  world_path: []const u8 = "worlds/",
  mod_path:   []const u8 = "mods/",
};


pub const Game = struct {
  options: Options = Options { },

  allocator: std.mem.Allocator,
  mods: std.ArrayList(Mod),

  world: ?World = null,


  pub fn init(allocator: std.mem.Allocator) Game {
    return Game {
      .allocator = allocator,
      .mods = std.ArrayList(Mod).init(allocator)
    };
  }


  pub fn deinit(self: *Game) void {
    if (self.world != null) self.world.?.deinit();

    for (self.mods.items) |mod| {
      self.allocator.free(mod.tiles);
      self.allocator.free(mod.creatures);
      self.allocator.free(mod.generators);
    }

    self.mods.deinit();
  }


  pub fn newWorld(self: *Game, ctx: *Lua,
                  size: usize, generator: Vector2(usize)) !void {
    if (self.mods.items.len < 1) return error.MissingBaseMod;
    self.world = try World.init(size, self.allocator);
    self.allocator.free(self.world.?.tiles);

    ctx.pushInteger(self.mods.items[generator.x]
      .generators[generator.y].reference);
    if (ctx.getTable(ziglua.registry_index) != ziglua.LuaType.function)
      return error.ExpectedFunction;

    ctx.pushInteger(@intCast(isize, size));

    ctx.call(1, 1);

    const tiles = try LuaAPI.userdataArrayToSlice(ctx, -1, Tile, self.allocator);

    self.world.?.tiles = tiles;
  }
};
