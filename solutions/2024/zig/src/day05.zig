const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const testing = std.testing;
const fs = std.fs;
const Allocator = mem.Allocator;
const HashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;

const test_input =
    \\ 47|53
    \\ 97|13
    \\ 97|61
    \\ 97|47
    \\ 75|29
    \\ 61|13
    \\ 75|53
    \\ 29|13
    \\ 97|29
    \\ 53|29
    \\ 61|53
    \\ 97|53
    \\ 61|29
    \\ 47|13
    \\ 75|47
    \\ 97|75
    \\ 47|61
    \\ 75|61
    \\ 47|29
    \\ 75|13
    \\ 53|13
    \\
    \\ 75,47,61,53,29
    \\ 97,61,53,29,13
    \\ 75,29,13
    \\ 75,97,47,61,53
    \\ 61,13,29
    \\ 97,13,75,29,47
;

const OrderingRules = struct {
    allocator: Allocator,
    value: HashMap(usize, []const usize),

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var rules = HashMap(usize, ArrayList(usize)).init(allocator);
        defer rules.deinit();

        defer {
            var value_iterator = rules.valueIterator();

            while (value_iterator.next()) |list| {
                list.deinit();
            }
        }

        var lines = mem.splitScalar(u8, input, '\n');

        while (lines.next()) |line| {
            const line_trimmed = mem.trim(u8, line, " ");

            if (line_trimmed.len == 0) {
                continue;
            }

            var parts = mem.splitScalar(u8, line_trimmed, '|');
            const left = parts.next().?;
            const right = parts.next().?;

            const page_nr = try fmt.parseInt(usize, left, 10);
            const must_be_before = try fmt.parseInt(usize, right, 10);

            if (rules.getPtr(page_nr)) |list| {
                try list.append(must_be_before);
            } else {
                var list = ArrayList(usize).init(allocator);
                try list.append(must_be_before);
                try rules.put(page_nr, list);
            }
        }

        var result = HashMap(usize, []const usize).init(allocator);
        errdefer result.deinit();

        var entry_iterator = rules.iterator();

        while (entry_iterator.next()) |entry| {
            const slice = try allocator.alloc(usize, entry.value_ptr.items.len);
            mem.copyForwards(usize, slice, entry.value_ptr.items);
            try result.put(entry.key_ptr.*, slice);
        }

        return .{
            .allocator = allocator,
            .value = result,
        };
    }

    fn deinit(this: *@This()) void {
        var value_iterator = this.value.valueIterator();

        while (value_iterator.next()) |value| {
            this.allocator.free(value.*);
        }

        this.value.deinit();
    }

    fn compareValues(this: @This(), a: usize, b: usize) bool {
        if (this.value.get(a)) |must_be_before| {
            if (mem.indexOfScalar(usize, must_be_before, b)) |_| {
                return false;
            }
        }

        return true;
    }
};

const Update = struct {
    allocator: Allocator,
    pages: []usize,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var pages = ArrayList(usize).init(allocator);
        errdefer pages.deinit();

        const trimmed = mem.trim(u8, input, " ");
        var part_iterator = mem.splitScalar(u8, trimmed, ',');

        while (part_iterator.next()) |part| {
            const value = try fmt.parseInt(usize, part, 10);
            try pages.append(value);
        }

        return .{
            .allocator = allocator,
            .pages = try pages.toOwnedSlice(),
        };
    }

    fn deinit(this: @This()) void {
        this.allocator.free(this.pages);
    }

    fn complies(this: @This(), rules: OrderingRules) bool {
        for (this.pages, 0..) |page, index| {
            if (rules.value.get(page)) |must_be_before| {
                for (must_be_before) |value| {
                    if (mem.indexOfScalar(usize, this.pages[0..index], value) != null) {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    fn reorder(this: *@This(), rules: OrderingRules) void {
        if (this.complies(rules)) {
            return;
        }

        mem.sort(usize, this.pages, rules, OrderingRules.compareValues);
    }

    fn middle(this: @This()) usize {
        const middle_index = this.pages.len / 2;
        return this.pages[middle_index];
    }
};

const Input = struct {
    allocator: Allocator,
    rules: OrderingRules,
    updates: []Update,

    fn parse(allocator: Allocator, input: []const u8) !@This() {
        var sections = mem.splitSequence(u8, input, "\n\n");

        const rules_section = sections.next().?;
        const rules = try OrderingRules.parse(allocator, rules_section);

        const pages_section = sections.next().?;
        var page_lines = mem.splitScalar(u8, pages_section, '\n');

        var updates = ArrayList(Update).init(allocator);
        errdefer updates.deinit();

        while (page_lines.next()) |line| {
            const trimmed = mem.trim(u8, line, " ");

            if (trimmed.len == 0) {
                continue;
            }

            const update = try Update.parse(allocator, trimmed);
            try updates.append(update);
        }

        return .{
            .allocator = allocator,
            .rules = rules,
            .updates = try updates.toOwnedSlice(),
        };
    }

    fn deinit(this: *@This()) void {
        this.rules.deinit();

        for (this.updates) |update| {
            update.deinit();
        }

        this.allocator.free(this.updates);
    }

    fn sumOfValidMiddles(this: @This()) !usize {
        var result: usize = 0;

        for (this.updates) |update| {
            if (update.complies(this.rules)) {
                result += update.middle();
            }
        }

        return result;
    }
};

fn part1(allocator: Allocator, input: []const u8) !usize {
    var data = try Input.parse(allocator, input);
    defer data.deinit();

    return data.sumOfValidMiddles();
}

fn part2(allocator: Allocator, input: []const u8) !usize {
    var data = try Input.parse(allocator, input);
    defer data.deinit();

    var result: usize = 0;

    for (data.updates) |*update| {
        if (update.complies(data.rules)) {
            continue;
        }

        update.reorder(data.rules);
        result += update.middle();
    }

    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const input = try fs.cwd().readFileAlloc(allocator, "inputs/day05.txt", 200000);
    defer allocator.free(input);

    std.debug.print("part 1: {}\n", .{try part1(allocator, input)});
    std.debug.print("part 2: {}\n", .{try part2(allocator, input)});
}

test "part 1" {
    const allocator = testing.allocator;
    try testing.expectEqual(143, try part1(allocator, test_input));
}

test "part 2" {
    const allocator = testing.allocator;
    try testing.expectEqual(123, try part2(allocator, test_input));
}
