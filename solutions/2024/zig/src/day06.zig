const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const testing = std.testing;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const test_input =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

const Cell = enum(u8) {
    floor = '.',
    obstacle = '#',
};

const Direction = enum(u8) {
    up = '^',
    right = '>',
    down = 'v',
    left = '<',

    fn turnRight(this: @This()) @This() {
        return switch (this) {
            .up => .right,
            .right => .down,
            .down => .left,
            .left => .up,
        };
    }
};

const Position = struct {
    x: usize,
    y: usize,

    fn init(x: usize, y: usize) @This() {
        return .{ .x = x, .y = y };
    }

    fn move(this: @This(), direction: Direction) ?@This() {
        var target_x = this.x;
        var target_y = this.y;

        switch (direction) {
            .down => target_y += 1,
            .right => target_x += 1,
            .left => if (target_x == 0) {
                return null;
            } else {
                target_x -= 1;
            },
            .up => if (target_y == 0) {
                return null;
            } else {
                target_y -= 1;
            },
        }

        return @This().init(target_x, target_y);
    }
};

const Map = struct {
    allocator: Allocator,
    width: usize,
    height: usize,
    cells: []Cell,

    guard_position: Position,
    guard_direction: Direction,
    initial_position: Position,
    initial_direction: Direction,

    visited: HashMap(Position, void),

    const ParseError = error{ InvalidCharacter, JaggedInput };

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var cells = ArrayList(Cell).init(allocator);
        errdefer cells.deinit();

        var lines = mem.splitScalar(u8, input, '\n');
        var y: usize = 0;
        var width: usize = 0;

        var guard_x: usize = 0;
        var guard_y: usize = 0;
        var guard_direction: Direction = .up;

        while (lines.next()) |line| {
            const line_trimmed = mem.trim(u8, line, " ");

            if (line_trimmed.len == 0) {
                continue;
            }

            if (width == 0) {
                width = line_trimmed.len;
            } else if (width != line_trimmed.len) {
                return ParseError.JaggedInput;
            }

            for (line_trimmed, 0..) |char, x| {
                switch (char) {
                    '.', '#' => try cells.append(@enumFromInt(char)),
                    '^', '>', 'v', '<' => {
                        guard_x = x;
                        guard_y = y;
                        guard_direction = @enumFromInt(char);
                        try cells.append(.floor);
                    },
                    else => return ParseError.InvalidCharacter,
                }
            }

            y += 1;
        }

        const guard_position = Position.init(guard_x, guard_y);

        var visited = HashMap(Position, void).init(allocator);
        errdefer visited.deinit();

        try visited.put(guard_position, {});

        return .{
            .allocator = allocator,
            .width = width,
            .height = y,
            .cells = try cells.toOwnedSlice(),

            .guard_direction = guard_direction,
            .guard_position = guard_position,
            .initial_direction = guard_direction,
            .initial_position = guard_position,
            .visited = visited,
        };
    }

    fn deinit(this: *@This()) void {
        this.allocator.free(this.cells);
        this.visited.deinit();
    }

    fn reset(this: *@This()) void {
        this.guard_position = this.initial_position;
        this.guard_direction = this.initial_direction;
    }

    fn at(this: @This(), position: Position) ?Cell {
        if (position.x >= this.width or position.y >= this.height) {
            return null;
        } else {
            return this.cells[position.y * this.width + position.x];
        }
    }

    fn takeStep(this: *@This()) ?Position {
        if (this.guard_position.move(this.guard_direction)) |target_position| {
            if (this.at(target_position)) |target_cell| {
                switch (target_cell) {
                    .floor => {
                        this.guard_position = target_position;
                        return target_position;
                    },
                    .obstacle => {
                        this.guard_direction = this.guard_direction.turnRight();
                        return this.takeStep();
                    },
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    fn simulatePatrol(this: *@This(), allocator: Allocator) !HashMap(Position, void) {
        defer this.reset();

        var result = HashMap(Position, void).init(allocator);
        errdefer result.deinit();

        while (this.takeStep()) |position| {
            try result.put(position, {});
        }

        return result;
    }

    fn checkLoop(this: *@This(), allocator: Allocator, obstacle_position: Position) !bool {
        defer this.reset();

        const VisitedPoint = struct {
            position: Position,
            direction: Direction,
        };

        var point_directions = HashMap(VisitedPoint, void).init(allocator);
        defer point_directions.deinit();

        this.cells[obstacle_position.y * this.width + obstacle_position.x] = .obstacle;
        defer this.cells[obstacle_position.y * this.width + obstacle_position.x] = .floor;

        while (this.takeStep()) |position| {
            const point = VisitedPoint{ .position = position, .direction = this.guard_direction };

            if (point_directions.contains(point)) {
                return true;
            } else {
                try point_directions.put(point, {});
            }
        }

        return false;
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    var map = try Map.parse(allocator, input);
    defer map.deinit();

    var visited = try map.simulatePatrol(allocator);
    defer visited.deinit();

    return visited.count();
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    var map = try Map.parse(allocator, input);
    defer map.deinit();

    var visited = try map.simulatePatrol(allocator);
    defer visited.deinit();

    var keys = visited.keyIterator();
    var possible_obstacles: usize = 0;

    while (keys.next()) |position| {
        if (try map.checkLoop(allocator, position.*)) {
            possible_obstacles += 1;
        }
    }

    return possible_obstacles;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day06.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(41, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(6, try part2(allocator, test_input));
}
