const std = @import("std");
const data = @import("./data.zig");

pub fn editorUpdateSyntax(row: *data.erow) !void {
    row.highlight = try data.editor.ally.realloc(row.highlight, row.render.len);
    @memset(row.highlight, @intFromEnum(data.editorHighlight.HL_NORMAL));

    for (0..row.render.len) |i| {
        if (std.ascii.isDigit(row.render[i])) {
            row.highlight[i] = @as(u8, @intFromEnum(data.editorHighlight.HL_NUMBER));
        }
    }
}
