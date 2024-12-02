const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // Open the file input-1.txt
    const file = try std.fs.cwd().openFile("src/input-2.txt", .{});
    defer file.close();

    // Create level array
    var level = std.ArrayList(u32).init(allocator);
    defer level.deinit();

    var safe_reports: u32 = 0;

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        var iterator = std.mem.splitSequence(u8, line, " ");
        while (iterator.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try level.append(num);
        }

        const first_item = level.items[0];
        const last_item = level.items[level.items.len - 1];

        // Decreasing
        if (first_item > last_item) {
            // Check if the level differ by 1 or at most 3
            for (level.items, 0..) |value, i| {
                // We skip the last item
                if (i == level.items.len - 1) {
                    safe_reports += 1;
                    break;
                }
                const current = value;
                const next = level.items[i + 1];
                if (current < next) {
                    std.debug.print("Curren is less than next\n", .{});
                    break;
                }

                const difference = current - next;

                if (difference < 1 or difference > 3) {
                    std.debug.print("Invalid difference found!\n", .{});
                    break;
                }
            }
        }
        // Increasing
        else {
            // Check if the level differ by 1 or at most 3
            for (level.items, 0..) |value, i| {
                // We skip the last item
                if (i == level.items.len - 1) {
                    safe_reports += 1;
                    break;
                }
                const current = value;
                const next = level.items[i + 1];
                if (current > next) {
                    std.debug.print("Current is greater than next\n", .{});
                    break;
                }

                const difference = next - current;

                if (difference < 1 or difference > 3) {
                    std.debug.print("Invalid difference found!\n", .{});
                    break;
                }
            }
        }

        level.clearAndFree();
    }

    std.debug.print("Safe Reports: {d}\n", .{safe_reports});
}
