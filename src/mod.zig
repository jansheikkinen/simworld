// mod.zig

const std = @import("std");

const ziglua = @import("ziglua");
const Lua = ziglua.Lua;
const FnReg = ziglua.FnReg;

const world = @import("world.zig");
const World = world.World;
const TileType = world.TileType;

const CreatureType = @import("creature.zig").CreatureType;


pub const LuaAPI = struct {
  const name = "core";
  const functions = [_]FnReg {
    FnReg { .name = "registerMod", .func = ziglua.wrap(registerMod) },
    FnReg { .name = "initTileType", .func = ziglua.wrap(TileType.fromLua) },
    FnReg { .name = "initCreatureType", .func = ziglua.wrap(CreatureType.fromLua) },
  };

  const error_messages = [_][]const u8 {
    "[registerMod]: the first argument must be a string",
    "[registerMod]: the second argument must be an array of tiletype userdata",
    "[registerMod]: the third argument must be an array of creaturetype userdata",
  };

  const world_table = "_World";

  pub fn initAPI(ctx: *Lua) void {
    ctx.openLibs();
    ctx.newLib(&functions);
    ctx.setGlobal(name);
  }


  pub fn pushWorld(ctx: *Lua, _world: *World) void {
    ctx.pushLightUserdata(_world);
    ctx.setGlobal(world_table);
  }


  fn userdataArrayToSlice(ctx: *Lua, index: i32,
                     comptime T: type, allocator: std.mem.Allocator) ![]T {
    // make a copy of the array on the top of the stack so we can pass
    // both positive and negative values for index
    ctx.pushValue(index);

    // get the length of the array
    ctx.len(-1);
    const len = @intCast(usize, try ctx.toInteger(-1));
    ctx.pop(1); // ctx.len

    // arraylist for temporary storage since VLAs don't exist
    var array = try std.ArrayList(T).initCapacity(allocator, len);

    // get each element
    var i: isize = 1;
    while (i <= len) : (i += 1) {
      // get element from table
      ctx.pushInteger(i);
      const elem_type = ctx.getTable(-2);
      if (elem_type != ziglua.LuaType.userdata) return error.WrongType;

      // stick it in the arraylist
      const elem = (try ctx.toUserdata(T, -1)).*;
      try array.append(elem);

      ctx.pop(1); // ctx.getTable
    }

    // remove copy from earlier and return a slice of the arraylist
    ctx.pop(1); // ctx.pushValue
    return try array.toOwnedSlice();
  }


  /// fn registerMod(name: []const u8,
  ///                tiles: ?[]TileType,
  ///                creatures: ?[]CreatureType) void
  fn registerMod(ctx: *Lua) i32 {
    // get world data struct from lua
    _ = ctx.getGlobal(world_table) catch unreachable;
    var world_data = ctx.toUserdata(World, -1) catch unreachable;
    ctx.pop(1); // ctx.getGlobal

    // get arguments
    const mod_name = ctx.toString(-3)
      catch std.debug.panic("{s}\n", .{ error_messages[0] });

    const tiles = userdataArrayToSlice(ctx, -2, TileType, world_data.allocator)
      catch std.debug.panic("{s}\n", .{ error_messages[1] });

    const creatures = userdataArrayToSlice(ctx, -1, CreatureType,
      world_data.allocator)
      catch std.debug.panic("{s}\n", .{ error_messages[2] });

    // create mod and add to list of mods
    const mod = Mod.init(mod_name[0..std.mem.len(mod_name)], tiles, creatures);
    world_data.mods.append(mod) catch unreachable; // TODO: handle error

    return 0;
  }
};


pub const Mod = struct {
  name: []const u8,
  tiles: []TileType,
  creatures: []CreatureType,

  pub fn init(name: []const u8,
              tiles: []TileType,
              creatures: []CreatureType) Mod {
    return Mod {
      .name = name,
      .tiles = tiles,
      .creatures = creatures,
    };
  }
};
