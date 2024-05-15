const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");
const rowop = @import("./rowOps.zig");

pub fn editorInsertChar(c: u16) !void{
    if(data.input.cy == data.editor.numRows){
        try rowop.editorAppendRow("");
    }
    try rowop.editorRowInsertChar(&data.editor.row[data.input.cy],
        data.input.cx, c);
    data.input.cx += 1;
}

pub fn editorDelChar() !void {
    if(data.input.cy == data.editor.numRows) return;

    const row:*data.erow = &data.editor.row[data.input.cy];
    if (data.input.cx > 0) {
        try rowop.editorRowDelChar(row, data.input.cx - 1);
        data.input.cx -= 1;
    }
}