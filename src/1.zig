const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open the file input-1.txt
    const file = try std.fs.cwd().openFile("src/input-1.txt", .{});
    defer file.close();

    var left_list = std.ArrayList(u32).init(allocator);
    defer left_list.deinit();

    var right_list = std.ArrayList(u32).init(allocator);
    defer right_list.deinit();

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var iterator = std.mem.splitSequence(u8, line, "  ");
        var left_num: u32 = undefined;
        if (iterator.next()) |n| {
            left_num = try std.fmt.parseInt(u32, std.mem.trim(u8, n, " "), 10);
        }
        var right_num: u32 = undefined;
        if (iterator.next()) |n| {
            right_num = try std.fmt.parseInt(u32, std.mem.trim(u8, n, " "), 10);
        }

        try left_list.append(left_num);
        try right_list.append(right_num);
    }

    // Sorting both arrays
    std.mem.sort(u32, left_list.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right_list.items, {}, comptime std.sort.asc(u32));

    // Part 1
    var total: u32 = 0;
    for (left_list.items, right_list.items) |left, right| {
        if (left > right) {
            total += (left - right);
        } else if (right > left) {
            total += (right - left);
        } else {
            total += 0;
        }
    }

    // Part 2
    var similarity: u32 = 0;
    var similarity_score: u32 = 0;
    for (left_list.items) |left| {
        for (right_list.items) |right| {
            if (left == right) {
                similarity += 1;
            }
        }
        similarity_score += left * similarity;
        similarity = 0;
    }

    std.debug.print("Similarity Score: {d}\n", .{similarity_score});
}
