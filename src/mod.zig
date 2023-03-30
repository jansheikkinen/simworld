// mod.zig

const std = @import("std");

const ziglua = @import("ziglua");
const Lua = ziglua.Lua;
const FnReg = ziglua.FnReg;

const game_lib = @import("game.zig");

const tile_lib = @import("tile.zig");
const Tile = tile_lib.Tile;
const TileType = tile_lib.TileType;

const CreatureType = @import("creature.zig").CreatureType;
const WorldGenerator = @import("world.zig").WorldGenerator;


pub const LuaAPI = struct {
  const name = "core";
  const functions = [_]FnReg {
    FnReg {
      .name = "registerMod",
      .func = ziglua.wrap(registerMod)
    },
    FnReg {
      .name = "initTileType",
      .func = ziglua.wrap(TileType.fromLua)
    },
    FnReg {
      .name = "initCreatureType",
      .func = ziglua.wrap(CreatureType.fromLua)
    },
    FnReg {
      .name = "initWorldGenerator",
      .func = ziglua.wrap(WorldGenerator.fromLua)
    },
    FnReg {
      .name = "initTile",
      .func = ziglua.wrap(Tile.fromLua)
    },
    FnReg {
      .name = "getModID",
      .func = ziglua.wrap(getModID)
    },
  };
  const game_table = "_Game";

  lua: Lua,


  pub fn init(allocator: std.mem.Allocator) !LuaAPI {
    return LuaAPI {
      .lua = try Lua.init(allocator)
    };
  }


  pub fn deinit(self: *LuaAPI) void {
    self.lua.deinit();
  }


  fn initAPI(self: *LuaAPI) void {
    self.lua.openLibs();
    self.lua.newLib(&functions);
    self.lua.setGlobal(name);
  }


  fn pushGame(self: *LuaAPI, game: *game_lib.Game) void {
    self.lua.pushLightUserdata(game);
    self.lua.setGlobal(game_table);
  }


  fn loadMods(self: *LuaAPI, game: *game_lib.Game) !void {
    const path = try std.mem.concatWithSentinel(game.allocator, u8,
      &[_][]const u8 {
        game.options.base_path,
        game.options.mod_path,
        "base/init.lua"
      }, 0);
    defer game.allocator.free(path);

    try self.lua.doFile(path);
  }


  pub fn loadAPIAndMods(self: *LuaAPI, game: *game_lib.Game) !void {
    self.initAPI();
    self.pushGame(game);
    try self.loadMods(game);
  }


  // wanted to make this [:0]const u8 but IT WONT WORK GRAHHHH!!!!!!!!
  pub fn expectString(ctx: *Lua, index: i32) [*:0]const u8 {
    return ctx.toString(index)
      catch std.debug.panic("[CORE]: Expected a string", .{});
  }


  pub fn expectInteger(ctx: *Lua, index: i32) isize {
    return ctx.toInteger(index)
      catch std.debug.panic("[CORE]: Expected integer", .{});
  }


  pub fn registerFunction(ctx: *Lua) i32 {
    return ctx.ref(ziglua.registry_index)
      catch std.debug.panic("[CORE]: Expected a function", .{});
  }


  fn userdataArrayToSlice(ctx: *Lua, index: i32,
                     comptime T: type, allocator: std.mem.Allocator) ![]T {
    ctx.pushValue(index);

    ctx.len(-1);
    const len = @intCast(usize, try ctx.toInteger(-1));
    ctx.pop(1); // ctx.len

    var array = try std.ArrayList(T).initCapacity(allocator, len);

    var i: isize = 1;
    while (i <= len) : (i += 1) {
      ctx.pushInteger(i);
      const elem_type = ctx.getTable(-2);
      if (elem_type != ziglua.LuaType.userdata) return error.WrongType;

      const elem = (try ctx.toUserdata(T, -1)).*;
      try array.append(elem);

      ctx.pop(1); // ctx.getTable
    }

    ctx.pop(1); // ctx.pushValue
    return try array.toOwnedSlice();
  }


  pub fn expectUserdata(ctx: *Lua, index: i32,
                        comptime T: type, allocator: std.mem.Allocator) []T {
    return userdataArrayToSlice(ctx, index, T, allocator)
      catch std.debug.panic("[CORE]: Expected {any} userdata", .{ T });
  }


  fn getGame(ctx: *Lua) !*game_lib.Game {
    const kind = try ctx.getGlobal(game_table);
    if (kind != ziglua.LuaType.userdata and
        kind != ziglua.LuaType.light_userdata)
      return error.WrongType;

    var game = try ctx.toUserdata(game_lib.Game, -1);
    ctx.pop(1);

    return game;
  }


  /// fn registerMod(name: []const u8,
  ///                tiles: ?[]TileType,
  ///                creatures: ?[]CreatureType) void
  fn registerMod(ctx: *Lua) i32 {
    var game = getGame(ctx) catch std.debug.panic(
      "[CORE]: expected game", .{});

    const mod_name = expectString(ctx, -4);

    const tiles = expectUserdata(ctx, -3, TileType, game.allocator);
    const creatures = expectUserdata(ctx, -2, CreatureType, game.allocator);
    const generators = expectUserdata(ctx, -1, WorldGenerator, game.allocator);

    const mod = Mod.init(mod_name[0..std.mem.len(mod_name)], tiles,
                         creatures, generators);
    game.mods.append(mod) catch std.debug.panic(
      "[CORE]: couldn't register mod", .{});

    return 0;
  }


  // TODO: a more sophisticated solution that'd allow multithreaded modloading
  pub fn getModID(ctx: *Lua) i32 {
    var game = getGame(ctx) catch std.debug.panic(
      "[CORE]: expected game", .{});

    ctx.pushInteger(@intCast(isize, game.mods.items.len));
    return 1;
  }
};


pub const Mod = struct {
  name: []const u8,
  tiles: []TileType,
  creatures: []CreatureType,
  generators: []WorldGenerator,

  pub fn init(name: []const u8,
              tiles: []TileType,
              creatures: []CreatureType,
              generators: []WorldGenerator) Mod {
    return Mod {
      .name = name,
      .tiles = tiles,
      .creatures = creatures,
      .generators = generators,
    };
  }

  pub fn deinit(self: *Mod, allocator: std.mem.Allocator) void {
    allocator.free(self.tiles);
    allocator.free(self.creatures);
    allocator.free(self.generators);
  }
};
