const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const testing = std.testing;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;

const test_input =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

const Equation = struct {
    allocator: Allocator,
    result: usize,
    values: []const usize,

    const ParseError = error{InvalidInput};

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var parts = mem.splitScalar(u8, input, ':');

        const result_string = parts.next() orelse return ParseError.InvalidInput;
        const result = try fmt.parseInt(usize, result_string, 10);

        const values_string = parts.next() orelse return ParseError.InvalidInput;
        var value_strings = mem.splitScalar(u8, mem.trim(u8, values_string, " "), ' ');

        var values = ArrayList(usize).init(allocator);
        errdefer values.deinit();

        while (value_strings.next()) |value_string| {
            const trimmed = mem.trim(u8, value_string, " ");

            if (trimmed.len == 0) {
                continue;
            }

            const value = try fmt.parseInt(usize, trimmed, 10);
            try values.append(value);
        }

        return .{
            .allocator = allocator,
            .result = result,
            .values = try values.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.values);
    }

    fn isCorrect(this: @This(), comptime support_concat: bool) IsCorrect(support_concat) {
        return this.isCorrectRecursive(1, this.values[0], support_concat);
    }

    fn isCorrectRecursive(this: @This(), index: usize, total: usize, comptime support_concat: bool) IsCorrect(support_concat) {
        if (index >= this.values.len) {
            return this.result == total;
        }

        const addition = this.isCorrectRecursive(index + 1, total + this.values[index], support_concat);
        const multiplication = this.isCorrectRecursive(index + 1, total * this.values[index], support_concat);

        if (support_concat) {
            const new_value = try concatNumbers(total, this.values[index]);
            const concatenation = this.isCorrectRecursive(index + 1, new_value, support_concat);

            return try addition or try multiplication or try concatenation;
        } else {
            return addition or multiplication;
        }
    }

    fn IsCorrect(comptime support_concat: bool) type {
        if (support_concat) {
            return anyerror!bool;
        } else {
            return bool;
        }
    }
};

const Input = struct {
    allocator: Allocator,
    equations: []const Equation,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var lines = mem.splitScalar(u8, input, '\n');

        var equations = ArrayList(Equation).init(allocator);
        errdefer equations.deinit();

        while (lines.next()) |line| {
            const trimmed = mem.trim(u8, line, " ");

            if (trimmed.len == 0) {
                continue;
            }

            const equation = try Equation.parse(allocator, trimmed);
            errdefer equations.deinit();

            try equations.append(equation);
        }

        return .{
            .allocator = allocator,
            .equations = try equations.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        for (this.equations) |equation| {
            equation.deinit();
        }

        this.allocator.free(this.equations);
    }
};

fn concatNumbers(left: usize, right: usize) !usize {
    var buf = mem.zeroes([128]u8);

    const left_length = fmt.formatIntBuf(&buf, left, 10, .lower, .{});
    const right_length = fmt.formatIntBuf(buf[left_length..], right, 10, .lower, .{});
    const length = left_length + right_length;
    const str = buf[0..length];

    return fmt.parseInt(usize, str, 10);
}

fn part1(allocator: Allocator, input: []const u8) !usize {
    const data = try Input.parse(allocator, input);
    defer data.deinit();

    var result: usize = 0;

    for (data.equations) |equation| {
        if (equation.isCorrect(false)) {
            result += equation.result;
        }
    }

    return result;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const data = try Input.parse(allocator, input);
    defer data.deinit();

    var result: usize = 0;

    for (data.equations) |equation| {
        if (try equation.isCorrect(true)) {
            result += equation.result;
        }
    }

    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day07.txt", 200000);
    defer allocator.free(input);

    std.debug.print("{}\n", .{try part1(allocator, input)});
    std.debug.print("{}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(3749, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(11387, try part2(allocator, test_input));
}
