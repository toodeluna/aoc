const std = @import("std");
const fs = std.fs;
const testing = std.testing;
const mem = std.mem;
const fmt = std.fmt;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const test_input =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

const Position = struct {
    x: usize,
    y: usize,

    fn init(x: usize, y: usize) @This() {
        return .{ .x = x, .y = y };
    }
};

const Map = struct {
    allocator: Allocator,
    width: usize,
    height: usize,
    tiles: []u8,

    const ParseError = error{JaggedInput};

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var lines = mem.splitScalar(u8, input, '\n');
        var height: usize = 0;
        var width: usize = 0;

        var tiles = ArrayList(u8).init(allocator);
        errdefer tiles.deinit();

        while (lines.next()) |line| {
            if (line.len == 0) {
                continue;
            }

            if (width == 0) {
                width = line.len;
            } else if (line.len != width) {
                return ParseError.JaggedInput;
            }

            for (line) |char| {
                const tile_height = char - '0';
                try tiles.append(tile_height);
            }

            height += 1;
        }

        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .tiles = try tiles.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.tiles);
    }

    fn at(this: @This(), position: Position) ?u8 {
        if (position.x >= this.width or position.y >= this.height) {
            return null;
        } else {
            return this.tiles[position.y * this.width + position.x];
        }
    }

    fn getAllNeighbours(this: @This(), allocator: Allocator, position: Position) ![]Position {
        var result = ArrayList(Position).init(allocator);
        errdefer result.deinit();

        if (position.x > 0) {
            try result.append(Position.init(position.x - 1, position.y));
        }

        if (position.y > 0) {
            try result.append(Position.init(position.x, position.y - 1));
        }

        if (position.x < this.width - 1) {
            try result.append(Position.init(position.x + 1, position.y));
        }

        if (position.y < this.height - 1) {
            try result.append(Position.init(position.x, position.y + 1));
        }

        return result.toOwnedSlice();
    }

    fn getAllPositionsAtHeight(this: @This(), allocator: Allocator, height: u8) ![]Position {
        var result = ArrayList(Position).init(allocator);
        errdefer result.deinit();

        for (0..this.height) |y| {
            for (0..this.width) |x| {
                const position = Position.init(x, y);
                const tile = this.at(position).?;

                if (tile == height) {
                    try result.append(position);
                }
            }
        }

        return result.toOwnedSlice();
    }

    fn getTrailheadRating(this: @This(), allocator: Allocator, from: Position) !usize {
        const neighbours = try this.getAllNeighbours(allocator, from);
        defer allocator.free(neighbours);

        const current_tile = this.at(from).?;

        var result: usize = 0;

        for (neighbours) |neighbour| {
            const target_tile = this.at(neighbour).?;

            if (current_tile + 1 != target_tile) {
                continue;
            }

            if (target_tile == 9) {
                result += 1;
            } else {
                result += try this.getTrailheadRating(allocator, neighbour);
            }
        }

        return result;
    }

    fn getTrailheads(
        this: @This(),
        allocator: Allocator,
        from: Position,
    ) ![]Position {
        var unique_positions = HashMap(Position, void).init(allocator);
        defer unique_positions.deinit();

        try this.getTrailheadsRecursive(allocator, from, &unique_positions);

        var keys = unique_positions.keyIterator();

        var result = ArrayList(Position).init(allocator);
        errdefer result.deinit();

        while (keys.next()) |position| {
            try result.append(position.*);
        }

        return result.toOwnedSlice();
    }

    fn getTrailheadsRecursive(
        this: @This(),
        allocator: Allocator,
        from: Position,
        buffer: *HashMap(Position, void),
    ) !void {
        const neighbours = try this.getAllNeighbours(allocator, from);
        defer allocator.free(neighbours);

        const current_tile = this.at(from).?;

        for (neighbours) |neighbour| {
            const target_tile = this.at(neighbour).?;

            if (current_tile + 1 != target_tile) {
                continue;
            }

            if (target_tile == 9) {
                try buffer.put(neighbour, {});
            } else {
                try this.getTrailheadsRecursive(allocator, neighbour, buffer);
            }
        }
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    const map = try Map.parse(allocator, input);
    defer map.deinit();

    const lowest_positions = try map.getAllPositionsAtHeight(allocator, 0);
    defer allocator.free(lowest_positions);

    var result: usize = 0;

    for (lowest_positions) |start| {
        const trailheads = try map.getTrailheads(allocator, start);
        defer allocator.free(trailheads);

        result += trailheads.len;
    }

    return result;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const map = try Map.parse(allocator, input);
    defer map.deinit();

    const lowest_positions = try map.getAllPositionsAtHeight(allocator, 0);
    defer allocator.free(lowest_positions);

    var result: usize = 0;

    for (lowest_positions) |start| {
        result += try map.getTrailheadRating(allocator, start);
    }

    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day10.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(36, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(81, try part2(allocator, test_input));
}
