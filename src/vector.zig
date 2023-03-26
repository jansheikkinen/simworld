// vector.zig

const std = @import("std");

pub fn Vector2(comptime T: type) type {
  return struct {
    const Self = @This();

    x: T, y: T,

    pub fn init(x: T, y: T) Self {
      return Self { .x = x, .y = y };
    }


    pub fn add(self: *const Self, other: *const Self) Self {
      return Self {
        .x = self.x + other.x,
        .y = self.y + other.y,
      };
    }


    pub fn addScalar(self: *const Self, other: T) Self {
      return Self {
        .x = self.x + other,
        .y = self.y + other,
      };
    }


    pub fn sub(self: *const Self, other: *const Self) Self {
      return Self {
        .x = self.x - other.x,
        .y = self.y - other.y,
      };
    }


    pub fn subScalar(self: *const Self, other: T) Self {
      return Self {
        .x = self.x - other,
        .y = self.y - other,
      };
    }


    pub fn cross(self: *const Self, other: *const Self) Self {
      unreachable(self, other); // lol no todo!()
    }


    pub fn dot(self: *const Self, other: *const Self) T {
      return (self.x * other.x) + (self.y * other.y);
    }


    pub fn scale(self: *const Self, other: T) Self {
      return Self {
        .x = self.x * other,
        .y = self.y * other,
      };
    }


    pub fn magnitude(self: *const Self) T {
      return std.math.sqrt(
        std.math.pow(T, self.x, 2) + std.math.pow(T, self.y, 2));
    }


    pub fn equal(self: *const Self, other: *const Self) bool {
      return self.x == other.x and self.y == other.y;
    }


    pub fn toIndex(self: *const Self, width: T) T {
      return (self.y * width) + self.x;
    }


    pub fn fromIndex(index: T, width: T) Self {
      return Self {
        .x = if (@typeInfo(T) == .Int) @mod(index, width) else index % width,
        .y = if (@typeInfo(T) == .Int) @divFloor(index, width)
          else std.math.floor(index / width),
      };
    }
  };
}


test "Vector2 add" {
  const v1 = Vector2(isize).init(34, 35);
  const v2 = Vector2(isize).init(35, 34);

  try std.testing.expectEqualDeep(v1.add(&v2), Vector2(isize).init(69, 69));
}

test "Vector2 addScalar" {
  const v1 = Vector2(isize).init(34, 34);

  try std.testing.expectEqualDeep(v1.addScalar(35),
    Vector2(isize).init(69, 69));
}

test "Vector2 sub" {
  const v1 = Vector2(isize).init(34, 35);
  const v2 = Vector2(isize).init(35, 34);

  try std.testing.expectEqualDeep(v1.sub(&v2), Vector2(isize).init(-1, 1));
}

test "Vector2 subScalar" {
  const v1 = Vector2(isize).init(34, 34);
  try std.testing.expectEqualDeep(v1.subScalar(35),
    Vector2(isize).init(-1, -1));
}

test "Vector2 cross" {
  try std.testing.expect(true);
}

test "Vector2 dot" {
  const v1 = Vector2(isize).init(34, 35);
  const v2 = Vector2(isize).init(35, 34);

  try std.testing.expectEqual(v1.dot(&v2), 2380);
}

test "Vector2 scale" {
  const v1 = Vector2(isize).init(34, 34);

  try std.testing.expectEqualDeep(v1.scale(2), Vector2(isize).init(68, 68));
}

test "Vector2 magnitude" {
  const v1 = Vector2(usize).init(3, 4); // no signed sqrt()

  try std.testing.expectEqual(v1.magnitude(), 5);
}

test "Vector2 equal" {
  const v1 = Vector2(isize).init(69, 420);

  try std.testing.expectEqualDeep(v1, Vector2(isize) { .x = 69, .y = 420 });
}

test "Vector2 toIndex" {
  const width: isize = 5;

  var i: isize = 0;
  var y: isize = 0;
  while (y < width) : (y += 1) {
    var x: isize = 0;
    while (x < width) : (x += 1) {
      const vec = Vector2(isize).init(x, y);
      try std.testing.expectEqual(vec.toIndex(width), i);
      i += 1;
    }
  }
}

test "Vector2 fromIndex" {
  const width: isize = 5;

  var i: isize = 0;
  var y: isize = 0;
  while (y < width) : (y += 1) {
    var x: isize = 0;
    while (x < width) : (x += 1) {
      const vec = Vector2(isize).init(x, y);
      try std.testing.expectEqualDeep(vec, Vector2(isize).fromIndex(i, width));
      i += 1;
    }
  }
}
