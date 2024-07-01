const std = @import("std");
const data = @import("./data.zig");

pub fn editorUpdateSyntax(row: *data.erow) !void {
    row.highlight = try data.editor.ally.realloc(row.highlight, row.render.len);
    @memset(row.highlight, data.editorHighlight.HL_NORMAL);

    for (0..row.render.len) |i| {
        if (std.ascii.isDigit(row.render[i])) {
            row.highlight[i] = data.editorHighlight.HL_NUMBER;
        }
    }
}

pub fn editorSyntaxToColor(hl: data.editorHighlight) u8 {
    const H = data.editorHighlight;
    return switch (hl) {
        H.HL_NUMBER => 31,
        else => 37,
    };
}
