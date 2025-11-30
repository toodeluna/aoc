const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const fs = std.fs;
const testing = std.testing;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

const test_input =
    \\ 7 6 4 2 1
    \\ 1 2 7 8 9
    \\ 9 7 6 2 1
    \\ 1 3 2 4 5
    \\ 8 6 4 4 1
    \\ 1 3 6 7 9
;

const Report = struct {
    const ParseError = error{EmptyString};

    allocator: Allocator,
    values: []usize,

    fn parse(allocator: Allocator, line: []const u8) !@This() {
        var result = ArrayList(usize).init(allocator);
        errdefer result.deinit();

        const line_trimmed = mem.trim(u8, line, " ");

        if (line_trimmed.len == 0) {
            return ParseError.EmptyString;
        }

        var values = mem.splitScalar(u8, line_trimmed, ' ');

        while (values.next()) |value| {
            if (value.len == 0) {
                continue;
            }

            const value_number = try fmt.parseInt(usize, value, 10);
            try result.append(value_number);
        }

        return .{
            .allocator = allocator,
            .values = try result.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.values);
    }

    fn steps(this: @This(), allocator: Allocator, ignore_index: ?usize) ![]isize {
        var result = ArrayList(isize).init(allocator);
        errdefer result.deinit();

        var last: ?isize = null;

        for (this.values, 0..) |value, index| {
            if (index == ignore_index) {
                continue;
            }

            const valueIsize: isize = @intCast(value);

            if (last) |last_value| {
                const step = last_value - valueIsize;
                try result.append(step);
                last = valueIsize;
            } else {
                last = valueIsize;
            }
        }

        return result.toOwnedSlice();
    }

    fn isSafe(this: @This(), allocator: Allocator, use_problem_dampener: bool) !bool {
        if (use_problem_dampener) {
            for (0..this.values.len) |index_to_ignore| {
                const steps_for_this_report = try this.steps(allocator, index_to_ignore);
                defer allocator.free(steps_for_this_report);

                var last_step: isize = 0;
                var result = false;

                for (steps_for_this_report) |step| {
                    result = isStepValid(last_step, step);
                    last_step = step;

                    if (!result) {
                        break;
                    }
                }

                if (result) {
                    return true;
                }
            }

            return false;
        } else {
            const steps_for_this_report = try this.steps(allocator, null);
            defer allocator.free(steps_for_this_report);

            var last_step: isize = 0;

            for (steps_for_this_report) |step| {
                const result = isStepValid(last_step, step);
                last_step = step;

                if (!result) {
                    return result;
                }
            }

            return true;
        }
    }
};

fn isStepValid(from: isize, to: isize) bool {
    const abs = @abs(to);

    if (abs < 1 or abs > 3) {
        return false;
    }

    if (from != 0) {
        const sign_from = from > 0;
        const sign_to = to > 0;

        if (sign_from != sign_to) {
            return false;
        }
    }

    return true;
}

const Input = struct {
    allocator: Allocator,
    reports: []Report,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var reports = ArrayList(Report).init(allocator);
        errdefer reports.deinit();

        var lines = mem.splitScalar(u8, input, '\n');

        while (lines.next()) |line| {
            const report = Report.parse(allocator, line) catch |err| {
                switch (err) {
                    Report.ParseError.EmptyString => continue,
                    else => return err,
                }
            };

            try reports.append(report);
        }

        return .{
            .allocator = allocator,
            .reports = try reports.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        for (this.reports) |report| {
            report.deinit();
        }

        this.allocator.free(this.reports);
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    const data = try Input.parse(allocator, input);
    defer data.deinit();

    var amount_of_safe_reports: usize = 0;

    for (data.reports) |report| {
        if (try report.isSafe(allocator, false)) {
            amount_of_safe_reports += 1;
        }
    }

    return amount_of_safe_reports;
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const data = try Input.parse(allocator, input);
    defer data.deinit();

    var amount_of_safe_reports: usize = 0;

    for (data.reports) |report| {
        if (try report.isSafe(allocator, true)) {
            amount_of_safe_reports += 1;
        }
    }

    return amount_of_safe_reports;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day02.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    const result = try part1(allocator, test_input);
    try testing.expectEqual(2, result);
}

test "part 2" {
    const allocator = testing.allocator;
    const result = try part2(allocator, test_input);
    try testing.expectEqual(4, result);
}
