const std = @import("std");
const Allocator = std.mem.Allocator;

// PART 1
fn isValidSequence(items: []const i32) bool {
    if (items.len <= 1) return false;

    // Determine if sequence should be increasing or decreasing
    const increasing = items[0] < items[items.len - 1];

    // Start from index 1 since we compare with previous
    var i: usize = 1;
    while (i < items.len) : (i += 1) {
        const current = items[i];
        const prev = items[i - 1];

        // Calculate difference based on direction
        const difference = if (increasing)
            current - prev
        else
            prev - current;

        // Check if the difference is between 1 and 3 inclusive
        if (difference < 1 or difference > 3) {
            return false;
        }

        // Verify the sequence maintains its direction
        if (increasing and current <= prev) {
            return false;
        }
        if (!increasing and current >= prev) {
            return false;
        }
    }

    return true;
}

// PART 2
fn canBeValid(allocator: Allocator, items: []const i32) !bool {
    // If its already valid, not need to remove anything
    if (isValidSequence(items)) return true;

    // If its not valid, try removing one number at a time
    var sequence_made_valid = false;
    for (0..items.len) |i| {
        var temp_list = try std.ArrayList(i32).initCapacity(allocator, items.len - 1);
        defer temp_list.deinit();

        // Copy all items except the one at index i
        for (0..items.len) |j| {
            if (j != i) {
                try temp_list.append(items[j]);
            }
        }

        if (isValidSequence(temp_list.items)) {
            sequence_made_valid = true;
            break;
        }
    }

    return sequence_made_valid;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // Open the file input-1.txt
    const file = try std.fs.cwd().openFile("src/input-2.txt", .{});
    defer file.close();

    // Create level array
    var level = std.ArrayList(i32).init(allocator);
    defer level.deinit();

    var safe_reports: i32 = 0;

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        var iterator = std.mem.splitSequence(u8, line, " ");
        while (iterator.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try level.append(num);
        }

        if (try canBeValid(allocator, level.items)) {
            safe_reports += 1;
        }

        level.clearAndFree();
    }

    std.debug.print("Safe Reports: {d}\n", .{safe_reports});
}
