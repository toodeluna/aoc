const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const sort = std.sort;
const testing = std.testing;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;
const HashMap = std.AutoHashMap;

const test_input =
    \\ 3   4
    \\ 4   3
    \\ 2   5
    \\ 1   3
    \\ 3   9
    \\ 3   3
;

const Lists = struct {
    allocator: Allocator,
    left: []usize,
    right: []usize,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var left = ArrayList(usize).init(allocator);
        var right = ArrayList(usize).init(allocator);
        var it = mem.splitScalar(u8, input, '\n');

        while (it.next()) |line| {
            const line_trimmed = mem.trim(u8, line, " ");

            if (line_trimmed.len == 0) {
                break;
            }

            var lineIt = mem.splitSequence(u8, line_trimmed, "   ");
            const left_number_string = mem.trim(u8, lineIt.next().?, " ");
            const right_number_string = mem.trim(u8, lineIt.next().?, " ");

            const left_number = try fmt.parseInt(u32, left_number_string, 10);
            const right_number = try fmt.parseInt(u32, right_number_string, 10);

            try left.append(left_number);
            try right.append(right_number);
        }

        const left_slice = try left.toOwnedSlice();
        const right_slice = try right.toOwnedSlice();

        mem.sort(usize, left_slice, {}, sort.asc(usize));
        mem.sort(usize, right_slice, {}, sort.asc(usize));

        return .{
            .allocator = allocator,
            .left = left_slice,
            .right = right_slice,
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.left);
        this.allocator.free(this.right);
    }

    fn distances(this: @This(), allocator: Allocator) ![]usize {
        var result = ArrayList(usize).init(allocator);

        for (0..this.left.len) |i| {
            const left_item: isize = @intCast(this.left[i]);
            const right_item: isize = @intCast(this.right[i]);
            const diff = right_item - left_item;
            const distance = @abs(diff);
            try result.append(distance);
        }

        return result.toOwnedSlice();
    }

    fn similarity_score(this: @This(), allocator: Allocator) !usize {
        var scores = HashMap(usize, usize).init(allocator);
        defer scores.deinit();

        var total: usize = 0;

        for (this.left) |value| {
            if (scores.get(value)) |score| {
                total += score;
            } else {
                var count: usize = 0;

                for (this.right) |right_value| {
                    if (right_value == value) {
                        count += 1;
                    }
                }

                const score = value * count;
                try scores.put(value, score);
                total += score;
            }
        }

        return total;
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    const lists = try Lists.parse(allocator, input);
    defer lists.deinit();

    const distances = try lists.distances(allocator);
    defer allocator.free(distances);

    var sum: usize = 0;

    for (distances) |value| {
        sum += value;
    }

    return sum;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const lists = try Lists.parse(allocator, input);
    defer lists.deinit();

    return lists.similarity_score(allocator);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day01.txt", 200000);
    defer allocator.free(input);

    const part1_result = try part1(allocator, input);
    std.debug.print("part 1: {}\n", .{part1_result});

    const part2_result = try part2(allocator, input);
    std.debug.print("part 2: {}", .{part2_result});
}

test "part 1" {
    const allocator = testing.allocator;
    const result = try part1(allocator, test_input);
    try testing.expectEqual(result, 11);
}

test "part 2" {
    const allocator = testing.allocator;
    const result = try part2(allocator, test_input);
    try testing.expectEqual(result, 31);
}
