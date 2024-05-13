const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");

pub fn editorRowCxToRx(row: *data.erow, cx: u16) u16{
    var rx:u16 = 0;
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