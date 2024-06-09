const std = @import("std");
const input = @import("./input.zig");
const data = @import("./data.zig");
const output = @import("./output.zig");
const rowOps = @import("./rowOps.zig");
const ascii = std.ascii;

fn editorFindCallback(query: []const u8, key: u16) void {
    if (key == '\r' or key == '\x1b') {
        return;
    }
    for (0..data.editor.numRows) |i| {
        const row = &data.editor.row[i];
        std.log.debug("trying to find {s} in {s}", .{ query, row.chars });
        const result = ascii.indexOfIgnoreCase(row.chars, query);
        if (result != null) {
            std.log.debug("setting cy to {d}", .{i});
            data.input.cy = i;
            data.input.cx = rowOps.editorRowRxToCx(row, result.?);
            data.editor.rowoff = data.editor.numRows;
            break;
        }
    }
}

pub fn editorFind() void {
    const query = input.editorPrompt("Search {s} (ESC to cancel)", editorFindCallback) catch |err| {
        std.log.err("(recoverable) In find.zig - editorFind(): {!}", .{err});
        output.editorSetStatusMessage("ERROR: Search failed: check prompt", .{});
        return;
    };
    if (query == null) return;
    data.editor.ally.free(query.?);
}
