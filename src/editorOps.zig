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