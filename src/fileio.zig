const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");
const row = @import("./rowOps.zig");

pub fn editorOpen(filename: []const u8) !void {
    data.editor.ally.free(data.editor.filename);
    data.editor.filename = try data.editor.ally.alloc(u8, filename.len);
    @memcpy(data.editor.filename, filename);

    const cwd = std.fs.cwd();
    var file: std.fs.File = try cwd.openFile(filename, .{ .mode = .read_write });
    defer file.close();

    const list = std.ArrayList(u8);
    var line = list.init(data.editor.ally);
    file.reader().streamUntilDelimiter(line.writer(),
        '\n', null) catch |err| switch (err) {
    error.EndOfStream => {},
    else => return err,
    };

    while(true){
        //Trim the \ns and \rs
        while(line.items.len > 0 and (line.getLast() == '\n' or line.getLast() == '\r')){
            _ = line.pop();
        }
        try row.editorAppendRow(line.items);
        line.clearAndFree();
        file.reader().streamUntilDelimiter(line.writer(),
            '\n', null) catch |err| switch (err) {
        error.EndOfStream => {
            try row.editorAppendRow(line.items);
            line.clearAndFree();
            break;
        },
        else => return err,
        };
    }
    line.deinit();
}
