const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const testing = std.testing;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const test_input =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

const Position = struct {
    x: isize,
    y: isize,

    fn init(x: isize, y: isize) @This() {
        return .{ .x = x, .y = y };
    }

    fn sub(this: @This(), other: @This()) @This() {
        return .{ .x = this.x - other.x, .y = this.y - other.y };
    }
};

const Map = struct {
    allocator: Allocator,
    antennas: HashMap(u8, []Position),
    width: usize,
    height: usize,

    const ParseError = error{JaggedInput};

    const AntennaIterator = struct {
        key_iterator: HashMap(u8, []Position).KeyIterator,

        fn next(this: *@This()) ?u8 {
            if (this.key_iterator.next()) |ptr| {
                return ptr.*;
            } else {
                return null;
            }
        }
    };

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var lines = mem.splitScalar(u8, input, '\n');
        var width: usize = 0;
        var height: usize = 0;

        var positions = HashMap(u8, ArrayList(Position)).init(allocator);
        defer positions.deinit();

        errdefer {
            var iterator = positions.valueIterator();

            while (iterator.next()) |list| {
                list.deinit();
            }
        }

        while (lines.next()) |line| {
            const y = height;

            if (line.len == 0) {
                continue;
            }

            if (width == 0) {
                width = line.len;
            } else if (line.len != width) {
                return ParseError.JaggedInput;
            }

            for (line, 0..) |char, x| {
                const position = Position.init(@intCast(x), @intCast(y));

                switch (char) {
                    '.' => continue,
                    else => if (positions.getPtr(char)) |existing_list| {
                        try existing_list.append(position);
                    } else {
                        var new_list = try ArrayList(Position).initCapacity(allocator, 1);
                        errdefer new_list.deinit();

                        try new_list.append(position);
                        try positions.put(char, new_list);
                    },
                }
            }

            height += 1;
        }

        var antennas = HashMap(u8, []Position).init(allocator);
        errdefer antennas.deinit();

        var iterator = positions.iterator();

        while (iterator.next()) |entry| {
            try antennas.put(entry.key_ptr.*, try entry.value_ptr.toOwnedSlice());
        }

        return .{
            .allocator = allocator,
            .antennas = antennas,
            .width = width,
            .height = height,
        };
    }

    fn deinit(this: *@This()) void {
        var value_iterator = this.antennas.valueIterator();

        while (value_iterator.next()) |list| {
            this.allocator.free(list.*);
        }

        this.antennas.deinit();
    }

    fn antennaIterator(this: @This()) AntennaIterator {
        return .{ .key_iterator = this.antennas.keyIterator() };
    }

    fn getPositions(this: @This(), char: u8) ?[]Position {
        return this.antennas.get(char);
    }

    fn isPositionInMap(this: @This(), position: Position) bool {
        if (position.x < 0 or position.y < 0) {
            return false;
        }

        if (position.x >= this.width or position.y >= this.height) {
            return false;
        }

        return true;
    }

    fn getAntinodePositions(
        this: @This(),
        allocator: Allocator,
        comptime enable_resonant_harmonics: bool,
    ) !HashMap(Position, void) {
        var antinode_positions = HashMap(Position, void).init(allocator);
        errdefer antinode_positions.deinit();

        var antennas = this.antennaIterator();

        while (antennas.next()) |antenna| {
            const positions = this.getPositions(antenna).?;

            for (positions, 0..) |position, current_index| {
                for (positions, 0..) |other_position, other_index| {
                    if (current_index == other_index) {
                        continue;
                    }

                    if (enable_resonant_harmonics) {
                        try antinode_positions.put(position, {});
                    }

                    const diff = other_position.sub(position);
                    var target_position = position.sub(diff);

                    if (this.isPositionInMap(target_position)) {
                        try antinode_positions.put(target_position, {});
                    }

                    if (enable_resonant_harmonics) {
                        while (true) {
                            target_position = target_position.sub(diff);

                            if (this.isPositionInMap(target_position)) {
                                try antinode_positions.put(target_position, {});
                            } else {
                                break;
                            }
                        }
                    }
                }
            }
        }

        return antinode_positions;
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    var map = try Map.parse(allocator, input);
    defer map.deinit();

    var antinodes = try map.getAntinodePositions(allocator, false);
    defer antinodes.deinit();

    return antinodes.count();
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    var map = try Map.parse(allocator, input);
    defer map.deinit();

    var antinodes = try map.getAntinodePositions(allocator, true);
    defer antinodes.deinit();

    return antinodes.count();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day08.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(14, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(34, try part2(allocator, test_input));
}
