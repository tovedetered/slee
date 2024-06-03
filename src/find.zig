const std = @import("std");
const input = @import("./input.zig");
const data = @import("./data.zig");
const output = @import("./output.zig");
const rowOps = @import("./rowOps.zig");
const ascii = std.ascii;

pub fn editorFind() void {
    const query = input.editorPrompt("Search {s} (ESC to cancel)") catch |err| {
        std.log.err("(recoverable) In find.zig - editorFind(): {!}", .{err});
        output.editorSetStatusMessage("ERROR: Search failed: check prompt", .{});
        return;
    };
    if (query == null) return;
    defer data.editor.ally.free(query.?);

    for (0..data.editor.numRows) |i| {
        const row = &data.editor.row[i];
        const result = ascii.indexOfIgnoreCase(row.chars, query.?);
        if (result != null) {
            data.input.cy = i;
            data.input.cx = rowOps.editorRowRxToCx(row, result.?);
            data.editor.rowoff = data.editor.numRows;
            break;
        }
    }
}
