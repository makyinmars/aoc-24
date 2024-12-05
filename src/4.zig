const std = @import("std");
const Allocator = std.mem.Allocator;
const input = @embedFile("input-4.txt");

const Direction = struct {
    dx: i32,
    dy: i32,
};

// All possible directions for word search
const directions = [_]Direction{
    .{ .dx = 1, .dy = 0 }, // right
    .{ .dx = -1, .dy = 0 }, // left
    .{ .dx = 0, .dy = 1 }, // down
    .{ .dx = 0, .dy = -1 }, // up
    .{ .dx = 1, .dy = 1 }, // diagonal down-right
    .{ .dx = -1, .dy = 1 }, // diagonal down-left
    .{ .dx = 1, .dy = -1 }, // diagonal up-right
    .{ .dx = -1, .dy = -1 }, // diagonal up-left
};

fn createGrid(allocator: Allocator, input_text: []const u8) !std.ArrayList([]u8) {
    // Create ArrayList to store our rows
    var grid = std.ArrayList([]u8).init(allocator);

    // - Each row stays allocated as long as it's in the grid
    // - If an error occurs during grid creation, all allocated memory is properly freed
    // - The caller is responsible for freeing the grid and its rows when done
    errdefer {
        for (grid.items) |row| {
            allocator.free(row);
        }
        grid.deinit();
    }

    // Split input into lines
    var lines = std.mem.splitSequence(u8, input_text, "\n");

    // Process each line
    while (lines.next()) |line| {
        // skip empty lines
        if (line.len == 0) continue;

        // Allocate space for this row
        const row = try allocator.alloc(u8, line.len);

        // Copy the line into our row
        @memcpy(row, line);

        // Add the row to our grid
        try grid.append(row);
    }

    return grid;
}

fn checkWord(grid: std.ArrayList([]u8), row: i32, col: i32, dir: Direction, word: []const u8) bool {
    const rows: i32 = @intCast(grid.items.len);
    if (rows == 0) return false;
    const cols: i32 = @intCast(grid.items[0].len);

    // Check each character of the word
    for (word, 0..) |char, i| {
        const temp_i: i32 = @intCast(i);
        const curr_row: i32 = row + temp_i * dir.dy;
        const curr_col: i32 = col + temp_i * dir.dx;

        // Check if we're still within grid boundaries
        if (curr_row < 0 or curr_row >= rows or curr_col < 0 or curr_col >= cols) {
            return false;
        }

        // Check if the character matches
        const temp_curr_row: usize = @intCast(curr_row);
        const temp_curr_col: usize = @intCast(curr_col);
        if (grid.items[temp_curr_row][temp_curr_col] != char) {
            return false;
        }
    }
    return true;
}

fn findWord(grid: std.ArrayList([]u8)) u32 {
    var count: u32 = 0;
    const rows: i32 = @intCast(grid.items.len);
    if (rows == 0) return 0;
    const cols: i32 = @intCast(grid.items[0].len);

    // Check each position in the grid
    var row: i32 = 0;
    while (row < rows) : (row += 1) {
        var col: i32 = 0;
        while (col < cols) : (col += 1) {
            // Try all possible directions from this position
            for (directions) |dir| {
                if (checkWord(grid, row, col, dir, "XMAS")) {
                    count += 1;
                }
            }
        }
    }
    return count;
}

fn findXMAS(grid: std.ArrayList([]u8)) u32 {
    var count: u32 = 0;
    const rows: i32 = @intCast(grid.items.len);
    if (rows == 0) return 0;
    const cols: i32 = @intCast(grid.items[0].len);

    // Check each position as potential center of X
    var row: i32 = 1;
    while (row < rows - 1) : (row += 1) {
        var col: i32 = 1;
        while (col < cols - 1) : (col += 1) {
            // Check if this position is 'A' (center of X)
            const center_row: usize = @intCast(row);
            const center_col: usize = @intCast(col);
            if (grid.items[center_row][center_col] != 'A') continue;

            // Check all possible combinations of MAS in X pattern
            // Top-left to bottom-right diagonal
            const tl_mas = checkWord(grid, row - 1, col - 1, .{ .dx = 1, .dy = 1 }, "MAS");
            const tl_sam = checkWord(grid, row - 1, col - 1, .{ .dx = 1, .dy = 1 }, "SAM");
            const br_mas = checkWord(grid, row + 1, col + 1, .{ .dx = -1, .dy = -1 }, "MAS");
            const br_sam = checkWord(grid, row + 1, col + 1, .{ .dx = -1, .dy = -1 }, "SAM");

            // Top-right to bottom-left diagonal
            const tr_mas = checkWord(grid, row - 1, col + 1, .{ .dx = -1, .dy = 1 }, "MAS");
            const tr_sam = checkWord(grid, row - 1, col + 1, .{ .dx = -1, .dy = 1 }, "SAM");
            const bl_mas = checkWord(grid, row + 1, col - 1, .{ .dx = 1, .dy = -1 }, "MAS");
            const bl_sam = checkWord(grid, row + 1, col - 1, .{ .dx = 1, .dy = -1 }, "SAM");

            // Check if we have valid MAS strings in both diagonals
            const tl_br_valid = (tl_mas or tl_sam) and (br_mas or br_sam);
            const tr_bl_valid = (tr_mas or tr_sam) and (bl_mas or bl_sam);

            if (tl_br_valid and tr_bl_valid) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const grid = try createGrid(allocator, input);

    defer {
        for (grid.items) |row| {
            allocator.free(row);
        }
        grid.deinit();
    }

    const x_mas_word_count = findWord(grid);
    const x_mas_count = findXMAS(grid);

    std.debug.print("Count 1: {d}, Count 2: {d}\n", .{ x_mas_word_count, x_mas_count });
}
