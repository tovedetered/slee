const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const data = @import("./data.zig");
const abuf = @import("./data-struct/abuf.zig");

pub fn editorRefreshScreen() !void {
    var buf = abuf.init(std.heap.page_allocator);
    defer buf.free();

    try buf.append("\x1b[?25l");
    try buf.append("\x1b[H");

    try editorDrawRows(&buf);

    const setCursorPos = try std.fmt.allocPrint(std.heap.page_allocator,
        "\x1b[{d};{d}H", .{data.input.cx + 1, data.input.cy + 1});
    try buf.append(setCursorPos);

    try buf.append("\x1b[?25h");

    try io.getStdOut().writeAll(buf.b);
}

pub fn editorDrawRows(ab: *abuf.abuf) !void {
    for(0..data.editor.screenRows) |y| {
        if(y >= data.editor.numRows){
            if(data.editor.numRows == 0 and y == data.editor.screenRows/3){
                const welcome:[] u8 = try std.fmt.allocPrint(std.heap.page_allocator,
                    "{s} Editor -- version: {s}",
                    .{data.editorName, data.version});
                var padding:usize = (data.editor.screenCols - welcome.len) / 2;
                if(padding != 0){
                    try ab.append("~");
                    padding -= 1;
                }
                while(padding > 0) : (padding -= 1){try ab.append(" ");}
                try ab.*.append(welcome);
            }else{
                try ab.*.append("~");
            }
        }else{
            const len = data.editor.row.chars.len;
            if(len > data.editor.screenCols) {
                //TODO
            }
            try ab.*.append(data.editor.row.chars);
        }
        try ab.*.append("\x1b[K");
        if(y < data.editor.screenRows - 1){
            try ab.*.append("\r\n");
        }
    }
}