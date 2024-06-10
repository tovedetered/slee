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
        const result = ascii.indexOfIgnoreCase(row.chars, query);
        if (result != null) {
            data.input.cy = i;
            data.input.cx = rowOps.editorRowRxToCx(row, result.?);
            data.editor.rowoff = data.editor.numRows;
            break;
        }
    }
}

pub fn editorFind() void {
    const I = &data.input;
    const E = &data.editor;
    const saved_cx = I.cx;
    const saved_cy = I.cy;
    const saved_coloff = E.coloff;
    const saved_rowoff = E.rowoff;

    const query = input.editorPrompt("Search {s} (ESC to cancel)", editorFindCallback) catch |err| {
        std.log.err("(recoverable) In find.zig - editorFind(): {!}", .{err});
        output.editorSetStatusMessage("ERROR: Search failed: check prompt", .{});
        return;
    };
    if (query == null) return;
    data.editor.ally.free(query.?);
    I.cx = saved_cx;
    I.cy = saved_cy;
    E.coloff = saved_coloff;
    E.rowoff = saved_rowoff;
}
