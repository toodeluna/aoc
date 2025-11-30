const std = @import("std");
const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const testing = std.testing;
const assert = std.debug.assert;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const test_input = "125 17";

var cache = HashMap(CachedStone, usize).init(std.heap.page_allocator);

const CachedStone = struct {
    stone: usize,
    amount: usize,
};

fn parseStones(allocator: Allocator, input: []const u8) ![]usize {
    var result = ArrayList(usize).init(allocator);
    errdefer result.deinit();

    const trimmed = mem.trim(u8, input, " \n");
    var number_strings = mem.splitScalar(u8, trimmed, ' ');

    while (number_strings.next()) |number_string| {
        const number = try fmt.parseInt(usize, number_string, 10);
        try result.append(number);
    }

    return result.toOwnedSlice();
}

fn countDigits(number: usize) usize {
    var current = number;
    var result: usize = 0;

    while (current != 0) {
        result += 1;
        current /= 10;
    }

    return result;
}

fn splitDigits(number: usize) ![2]usize {
    assert(countDigits(number) % 2 == 0);

    var buf = mem.zeroes([256]u8);
    const length = fmt.formatIntBuf(&buf, number, 10, .lower, .{});

    const string = buf[0..length];
    const left = string[0..(length / 2)];
    const right = string[(length / 2)..];

    const left_number = try fmt.parseInt(usize, left, 10);
    const right_number = try fmt.parseInt(usize, right, 10);

    return .{ left_number, right_number };
}

fn blink(allocator: Allocator, stone: usize, amount: usize) !usize {
    if (amount == 0) {
        return 1;
    }

    if (cache.get(.{ .stone = stone, .amount = amount })) |cached| {
        return cached;
    }

    var result: usize = 0;

    if (stone == 0) {
        result = try blink(allocator, 1, amount - 1);
    } else if (countDigits(stone) % 2 == 0) {
        const result_stones = try splitDigits(stone);
        result = try blink(allocator, result_stones[0], amount - 1) + try blink(allocator, result_stones[1], amount - 1);
    } else {
        result = try blink(allocator, stone * 2024, amount - 1);
    }

    try cache.put(.{ .stone = stone, .amount = amount }, result);

    return result;
}

fn part1(allocator: Allocator, input: []const u8) !usize {
    const stones = try parseStones(allocator, input);
    defer allocator.free(stones);

    var result: usize = 0;

    for (stones) |stone| {
        result += try blink(allocator, stone, 25);
    }

    return result;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const stones = try parseStones(allocator, input);
    defer allocator.free(stones);

    var result: usize = 0;

    for (stones) |stone| {
        result += try blink(allocator, stone, 75);
    }

    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    defer cache.deinit();

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day11.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(55312, try part1(allocator, test_input));
}
