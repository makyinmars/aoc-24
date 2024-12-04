const std = @import("std");

fn checkPattern(input: []const u8, i: usize, pattern: []const u8) bool {
    if (i >= input.len or i + pattern.len > input.len) return false;
    return std.mem.eql(u8, input[i .. i + pattern.len], pattern);
}

fn parseNumber(input: []const u8, start: *usize) ?struct { end: usize, value: u64 } {
    const num_start = start.*;
    var i = num_start;

    while (i < input.len and std.ascii.isDigit(input[i])) : (i += 1) {}
    const num_end = i;

    if (num_end > num_start) {
        if (std.fmt.parseInt(u64, input[num_start..num_end], 10)) |value| {
            start.* = i;
            return .{ .end = num_end, .value = value };
        } else |_| {
            return null;
        }
    }
    return null;
}

const Sums = struct {
    p1: u64,
    p2: u64,
};

fn processMul(input: []const u8, i: *usize, mul_enabled: bool, sums: *Sums) !void {
    const original_i = i.*;
    if (i.* + 4 >= input.len) return;

    i.* += 4; // Skip "mul("

    // Parse first number
    if (parseNumber(input, i)) |num1_result| {
        // Skip comma
        if (i.* < input.len and input[i.*] == ',') {
            i.* += 1;
            // Parse second number
            if (parseNumber(input, i)) |num2_result| {
                if (i.* < input.len and input[i.*] == ')') {
                    const product = num1_result.value * num2_result.value;
                    sums.p1 += product;
                    if (mul_enabled) sums.p2 += product;
                    i.* += 1;
                    return;
                }
            }
        }
    }

    // If we get here, something was wrong with the format
    i.* = original_i + 1; // Reset to just after the first character
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Read the entire file into memory
    const file = try std.fs.cwd().openFile("src/input-3.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(input);

    var sums = Sums{ .p1 = 0, .p2 = 0 };
    var i: usize = 0;
    var mul_enabled: bool = true;

    while (i < input.len) {
        // Check for "do()"
        if (checkPattern(input, i, "do(")) {
            i += 3;
            if (i < input.len and input[i] == ')') {
                mul_enabled = true;
                i += 1;
            }
            continue;
        }

        // Check for "don't()"
        if (checkPattern(input, i, "don't(")) {
            i += 6;
            if (i < input.len and input[i] == ')') {
                mul_enabled = false;
                i += 1;
            }
            continue;
        }

        // Check for "mul("
        if (checkPattern(input, i, "mul(")) {
            try processMul(input, &i, mul_enabled, &sums);
        } else {
            i += 1;
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}\n", .{sums.p1});
    try stdout.print("Part 2: {}\n", .{sums.p2});
}
