const std = @import("std");
const fs = std.fs;
const testing = std.testing;
const mem = std.mem;
const fmt = std.fmt;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

const test_input = "2333133121414131402";

const Block = union(enum) {
    empty: void,
    file: usize,
};

const File = struct {
    id: usize,
    start: usize,
    size: usize,
};

const Disk = struct {
    allocator: Allocator,
    blocks: []Block,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var blocks = ArrayList(Block).init(allocator);
        errdefer blocks.deinit();

        for (input, 0..) |char, index| {
            if (char < '0' or char > '9') continue;
            const amount: usize = @intCast(char - '0');
            const block: Block = if (index % 2 == 0) .{ .file = index / 2 } else .empty;
            try blocks.appendNTimes(block, amount);
        }

        return .{
            .allocator = allocator,
            .blocks = try blocks.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.blocks);
    }

    fn checksum(this: @This()) usize {
        var result: usize = 0;

        for (this.blocks, 0..) |block, index| {
            switch (block) {
                .empty => continue,
                .file => |id| result += id * index,
            }
        }

        return result;
    }

    fn defragment(this: *@This()) void {
        var iterator = mem.reverseIterator(this.blocks);
        var index = this.blocks.len - 1;

        while (iterator.next()) |block| {
            switch (block) {
                .empty => {
                    index -= 1;
                    continue;
                },
                .file => {
                    const first_empty_index = this.findFirstEmptyIndex() orelse break;
                    if (first_empty_index > index) break;

                    this.blocks[first_empty_index] = block;
                    this.blocks[index] = .empty;

                    index -= 1;
                },
            }
        }
    }

    fn defragmentFile(this: *@This()) void {
        var max_end = this.blocks.len;

        while (max_end > 1) {
            const file = this.findLastFile(max_end) orelse break;
            max_end = file.start;

            const first_empty_slice = this.findFirstEmptySlice(file.size, max_end) orelse continue;

            for (0..file.size) |index| {
                first_empty_slice[index] = .{ .file = file.id };
                this.blocks[file.start + index] = .empty;
            }
        }
    }

    fn findFirstEmptyIndex(this: @This()) ?usize {
        for (this.blocks, 0..) |block, index| {
            if (block == .empty) return index;
        }

        return null;
    }

    fn findFirstEmptySlice(this: *@This(), min_size: usize, max_end: usize) ?[]Block {
        for (this.blocks[0..max_end], 0..max_end) |block, start_index| {
            if (block != .empty) continue;

            const end = start_index + min_size;

            if (end >= this.blocks.len) {
                break;
            }

            const slice = this.blocks[start_index..end];
            var all_equal = true;

            for (slice) |b| {
                if (b != .empty) {
                    all_equal = false;
                    break;
                }
            }

            if (all_equal) return slice;
        }

        return null;
    }

    fn findLastFile(this: @This(), max_end: usize) ?File {
        const end_index = for (0..max_end) |distance_from_end| {
            const index = max_end - distance_from_end - 1;
            const block = this.blocks[index];

            if (block == .file) {
                break index;
            }
        } else {
            return null;
        };

        const file_id = this.blocks[end_index].file;
        var length: usize = 0;

        for (0..end_index) |distance_from_end| {
            const index = end_index - distance_from_end;
            const block = this.blocks[index];

            switch (block) {
                .empty => break,
                .file => |id| {
                    if (id != file_id) {
                        break;
                    } else {
                        length += 1;
                    }
                },
            }
        }

        return .{ .id = file_id, .start = end_index - length + 1, .size = length };
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    var disk = try Disk.parse(allocator, input);
    defer disk.deinit();

    disk.defragment();

    return disk.checksum();
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    var disk = try Disk.parse(allocator, input);
    defer disk.deinit();

    disk.defragmentFile();

    return disk.checksum();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day09.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(1928, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(2858, try part2(allocator, test_input));
}
