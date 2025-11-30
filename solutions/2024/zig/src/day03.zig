const std = @import("std");
const mem = std.mem;
const ascii = std.ascii;
const fmt = std.fmt;
const testing = std.testing;
const fs = std.fs;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;

const test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const test_input2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

const Instruction = union(enum) {
    do: void,
    dont: void,
    mul: Mul,
};

const ParseInstructionResult = struct {
    value: ?Instruction,
    rest: []const u8,
};

const Instructions = struct {
    allocator: Allocator,
    value: []Instruction,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var instructions = ArrayList(Instruction).init(allocator);
        errdefer instructions.deinit();

        var remaining_input = input[0..];

        while (remaining_input.len > 0) {
            const first_instruction = parseFirstInstruction(remaining_input);

            if (first_instruction.value) |value| {
                try instructions.append(value);
            }

            remaining_input = first_instruction.rest;
        }

        return .{
            .allocator = allocator,
            .value = try instructions.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.value);
    }

    fn execAll(this: @This()) usize {
        var result: usize = 0;
        var should_mul = true;

        for (this.value) |instruction| {
            switch (instruction) {
                .do => should_mul = true,
                .dont => should_mul = false,
                .mul => |mul| if (should_mul) {
                    result += mul.exec();
                },
            }
        }

        return result;
    }
};

const Mul = struct {
    left: usize,
    right: usize,

    const ParseResult = struct {
        value: ?Mul,
        rest: []const u8,
    };

    fn parse(input: []const u8) ParseResult {
        var current = input["mul(".len..];

        if (!ascii.isDigit(current[0])) {
            return .{ .value = null, .rest = current };
        }

        var left_digit: []const u8 = current[0..0];

        while (ascii.isDigit(current[left_digit.len])) {
            left_digit = current[0..(left_digit.len + 1)];
        }

        current = current[left_digit.len..];

        if (current[0] != ',') {
            return .{ .value = null, .rest = current };
        }

        current = current[1..];

        if (!ascii.isDigit(current[0])) {
            return .{ .value = null, .rest = current };
        }

        var right_digit: []const u8 = current[0..0];

        while (ascii.isDigit(current[right_digit.len])) {
            right_digit = current[0..(right_digit.len + 1)];
        }

        current = current[right_digit.len..];

        if (current[0] != ')') {
            return .{ .value = null, .rest = current };
        }

        current = current[1..];

        const left = fmt.parseInt(usize, left_digit, 10) catch unreachable;
        const right = fmt.parseInt(usize, right_digit, 10) catch unreachable;

        return .{
            .value = .{ .left = left, .right = right },
            .rest = current,
        };
    }

    fn exec(this: @This()) usize {
        return this.left * this.right;
    }
};

const Input = struct {
    allocator: Allocator,
    muls: []Mul,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var muls = ArrayList(Mul).init(allocator);
        errdefer muls.deinit();

        var remaining_input = input[0..];

        while (remaining_input.len > 0) {
            const result = parseFirstMul(remaining_input);

            if (result.value) |value| {
                try muls.append(value);
            }

            remaining_input = result.rest;
        }

        return .{
            .allocator = allocator,
            .muls = try muls.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.muls);
    }
};

fn parseFirstInstruction(input: []const u8) ParseInstructionResult {
    var remaining_input = input[0..];

    while (remaining_input.len > 0) {
        if (mem.startsWith(u8, remaining_input, "do()")) {
            remaining_input = remaining_input["do()".len..];
            return .{ .value = .do, .rest = remaining_input };
        } else if (mem.startsWith(u8, remaining_input, "don't()")) {
            remaining_input = remaining_input["don't()".len..];
            return .{ .value = .dont, .rest = remaining_input };
        } else if (mem.startsWith(u8, remaining_input, "mul(")) {
            const parse_mul_result = Mul.parse(remaining_input);

            if (parse_mul_result.value) |mul| {
                return .{ .value = .{ .mul = mul }, .rest = parse_mul_result.rest };
            } else {
                return .{ .value = null, .rest = parse_mul_result.rest };
            }
        } else {
            remaining_input = remaining_input[1..];
            return .{ .value = null, .rest = remaining_input };
        }
    }

    return .{ .value = null, .rest = "" };
}

fn parseFirstMul(input: []const u8) Mul.ParseResult {
    var current = input[0..];

    while (!mem.startsWith(u8, current, "mul(") and current.len > 0) {
        current = current[1..];
    }

    if (current.len == 0) {
        return .{ .value = null, .rest = "" };
    }

    return Mul.parse(current);
}

fn part1(allocator: Allocator, input: []const u8) !usize {
    const data = try Input.parse(allocator, input);
    defer data.deinit();

    var result: usize = 0;

    for (data.muls) |mul| {
        const mul_result = mul.exec();
        result += mul_result;
    }

    return result;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const data = try Instructions.parse(allocator, input);
    defer data.deinit();

    return data.execAll();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day03.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(161, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(48, try part2(allocator, test_input2));
}
