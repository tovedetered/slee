const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");

pub fn editorRowCxToRx(row: *data.erow, cx: usize) usize{
    var rx:usize = 0;
    for(0..cx) |j| {
        if(row.chars[j] == '\t'){
            rx += (data.TABSTOP - 1) - (rx % data.TABSTOP);
        }
        rx += 1;
    }
    return rx;
}

pub fn editorAppendRow(row:[]u8) !void{
    data.editor.row = try data.editor.ally.realloc(data.editor.row,
        data.editor.numRows + 1);

    const at = data.editor.numRows;
    data.editor.row[at].chars = try data.editor.ally.alloc(u8, row.len);
    @memcpy(data.editor.row[at].chars, row);

    data.editor.row[at].render = &.{};
    try editorUpdateRow(&data.editor.row[at]);
    data.editor.numRows += 1;
    data.editor.dirty += 1;
}

pub fn editorUpdateRow(row: *data.erow) !void{
    var tabs:u8 = 0;

    for(0..row.chars.len) |j| {
        if(row.chars[j] == '\t') tabs += 1;
    }

    const alloc = data.editor.ally;
    alloc.free(row.render);
    row.render = try alloc.alloc(u8, row.chars.len + tabs*(data.TABSTOP - 1));

    var idx:usize = 0;
    for(0..row.chars.len) |j| {
        if(row.chars[j] == '\t'){
            row.render[idx] = ' ';
            idx += 1;
            while(idx % data.TABSTOP != 0){
                row.render[idx] = ' ';
                idx += 1;
            }
        }else{
            row.render[idx] = row.chars[j];
            idx += 1;
        }
    }
}

pub fn editorRowInsertChar(row: *data.erow, at_: usize, key: u16) !void {
    var alloc = data.editor.ally;
    var at:usize = at_;
    if(at < 0 or at > row.chars.len) at = row.chars.len;
    row.chars = try alloc.realloc(row.chars, row.chars.len + 1);
    row.chars[at] = @as(u8, @intCast(key));
    try editorUpdateRow(row);
    data.editor.dirty += 1;
}

pub fn editorRowDelChar(row: *data.erow, at:usize) !void{
    if(at < 0 or at >= row.chars.len) return;
    std.mem.copyBackwards(u8, row.chars[at..], row.chars[at + 1..]);
    data.editor.ally.realloc(row.chars, row.chars.len - 1);
    editorUpdateRow(row);
    data.editor.dirty += 1;
}