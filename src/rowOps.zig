const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");

pub fn editorAppendRow(row:[]u8) !void{
    data.editor.row = try data.editor.ally.realloc(data.editor.row,
        data.editor.numRows + 1);

    const at = data.editor.numRows;
    data.editor.row[at].chars = try data.editor.ally.alloc(u8, row.len);
    @memcpy(data.editor.row[at].chars, row);
    data.editor.numRows += 1;
}