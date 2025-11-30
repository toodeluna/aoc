const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const fs = std.fs;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;

const test_input =
    \\ MMMSXXMASM
    \\ MSAMXMSMSA
    \\ AMXSXMAAMM
    \\ MSAMASMSMX
    \\ XMASAMXAMM
    \\ XXAMMXXAMA
    \\ SMSMSASXSS
    \\ SAXAMASAAA
    \\ MAMMMXMMMM
    \\ MXMXAXMASX
;

const Grid = struct {
    allocator: Allocator,
    rows: []const []const u8,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var rows = ArrayList([]const u8).init(allocator);
        errdefer rows.deinit();

        var lines = mem.splitScalar(u8, input, '\n');

        while (lines.next()) |line| {
            const line_trimmed = mem.trim(u8, line, " ");

            if (line_trimmed.len == 0) {
                continue;
            }

            try rows.append(line_trimmed);
        }

        return .{ .allocator = allocator, .rows = try rows.toOwnedSlice() };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.rows);
    }

    fn scanAll(this: @This()) usize {
        return this.scanHorizontal() + this.scanVertical() + this.scanDiagonal();
    }

    fn scanHorizontal(this: @This()) usize {
        var result: usize = 0;

        for (this.rows) |row| {
            var remaining = row[0..];

            while (remaining.len > 0) {
                if (mem.startsWith(u8, remaining, "XMAS") or mem.startsWith(u8, remaining, "SAMX")) {
                    result += 1;
                }

                remaining = remaining[1..];
            }
        }

        return result;
    }

    fn scanVertical(this: @This()) usize {
        var result: usize = 0;

        for (this.rows, 0..) |row, row_index| {
            if (row_index > this.rows.len - 4) {
                break;
            }

            for (row, 0..) |cell, column_index| {
                const column = [4]u8{
                    cell,
                    this.rows[row_index + 1][column_index],
                    this.rows[row_index + 2][column_index],
                    this.rows[row_index + 3][column_index],
                };

                if (mem.eql(u8, &column, "XMAS") or mem.eql(u8, &column, "SAMX")) {
                    result += 1;
                }
            }
        }

        return result;
    }

    fn scanDiagonal(this: @This()) usize {
        var result: usize = 0;

        for (this.rows, 0..) |row, row_index| {
            if (row_index > this.rows.len - 4) {
                break;
            }

            for (row, 0..) |cell, column_index| {
                if (column_index < row.len - 3) {
                    const column_forward = [4]u8{
                        cell,
                        this.rows[row_index + 1][column_index + 1],
                        this.rows[row_index + 2][column_index + 2],
                        this.rows[row_index + 3][column_index + 3],
                    };

                    if (mem.eql(u8, &column_forward, "XMAS") or mem.eql(u8, &column_forward, "SAMX")) {
                        result += 1;
                    }
                }

                if (column_index >= 3) {
                    const column_backward = [4]u8{
                        cell,
                        this.rows[row_index + 1][column_index - 1],
                        this.rows[row_index + 2][column_index - 2],
                        this.rows[row_index + 3][column_index - 3],
                    };

                    if (mem.eql(u8, &column_backward, "XMAS") or mem.eql(u8, &column_backward, "SAMX")) {
                        result += 1;
                    }
                }
            }
        }

        return result;
    }

    fn scanShapes(this: @This()) usize {
        var result: usize = 0;

        for (this.rows, 0..) |row, row_index| {
            if (row_index == 0 or row_index == this.rows.len - 1) {
                continue;
            }

            for (row, 0..) |cell, column_index| {
                if (column_index == 0 or column_index == row.len - 1) {
                    continue;
                }

                if (cell != 'A') {
                    continue;
                }

                const first = [3]u8{
                    this.rows[row_index - 1][column_index - 1],
                    cell,
                    this.rows[row_index + 1][column_index + 1],
                };

                const second = [3]u8{
                    this.rows[row_index - 1][column_index + 1],
                    cell,
                    this.rows[row_index + 1][column_index - 1],
                };

                if ((mem.eql(u8, &first, "SAM") or mem.eql(u8, &first, "MAS")) and
                    (mem.eql(u8, &second, "SAM") or mem.eql(u8, &second, "MAS")))
                {
                    result += 1;
                }
            }
        }

        return result;
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    const data = try Grid.parse(allocator, input);
    defer data.deinit();

    return data.scanAll();
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    const data = try Grid.parse(allocator, input);
    defer data.deinit();

    return data.scanShapes();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day04.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(18, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(9, try part2(allocator, test_input));
}
