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


const OptItems = struct {
  base_path:  []const u8 = "./",
  world_path: []const u8 = "worlds/",
  mod_path:   []const u8 = "mods/",
};


pub const Options = struct {
  const config_path = "~/.config/simworld/config.json";

  allocator: ?std.mem.Allocator = null,
  items: OptItems = OptItems { },


  pub fn initFromJSON(allocator: std.mem.Allocator, file: []const u8) !Options {
    const fd = try std.fs.cwd().openFile(file, .{ .mode = .read_only });
    defer fd.close();

    const buffer = try fd.readToEndAlloc(allocator, std.math.maxInt(u64));
    defer allocator.free(buffer);

    var stream = std.json.TokenStream.init(buffer);
    const items = try std.json.parse(OptItems, &stream, .{
      .allocator = allocator
    });

    return Options { .allocator = allocator, .items = items };
  }


  pub fn deinit(self: *Options) void {
    std.json.parseFree(OptItems, self.items, .{ .allocator = self.allocator });
  }
};


pub const Game = struct {
  options: Options,

  allocator: std.mem.Allocator,
  mods: std.ArrayList(Mod),

  world: ?World = null,


  pub fn init(allocator: std.mem.Allocator, options_file: ?[]const u8) !Game {
    return Game {
      .allocator = allocator,
      .options = if (options_file) |file|
        try Options.initFromJSON(allocator, file)
      else Options { },
      .mods = std.ArrayList(Mod).init(allocator)
    };
  }


  pub fn deinit(self: *Game) void {
    if (self.options.allocator != null) self.options.deinit();
    if (self.world != null) self.world.?.deinit();

    var i: usize = 0;
    while (i < self.mods.items.len) : (i += 1)
      self.mods.items[i].deinit(self.allocator);

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

    const tiles = LuaAPI.expectUserdata(ctx, -1, Tile, self.allocator);

    self.world.?.tiles = tiles;
  }
};
