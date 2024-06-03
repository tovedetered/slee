const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");
const row = @import("./rowOps.zig");
const output = @import("./output.zig");
const input = @import("./input.zig");

pub fn editorRowsToString() ![]u8 {
    var totlen: usize = 0;
    for (0..data.editor.numRows) |j| {
        totlen += data.editor.row[j].chars.len + 1;
    }

    var buffer = try data.editor.ally.alloc(u8, totlen);
    var p: usize = 0;
    for (0..data.editor.numRows) |j| {
        @memcpy(buffer[p .. p + data.editor.row[j].chars.len], data.editor.row[j].chars);
        p += data.editor.row[j].chars.len;
        buffer[p] = '\n';
        p += 1;
    }

    return buffer;
}

pub fn editorOpen(filename: []const u8) !void {
    data.editor.ally.free(data.editor.filename);
    data.editor.filename = try data.editor.ally.alloc(u8, filename.len);
    @memcpy(data.editor.filename, filename);

    const cwd = std.fs.cwd();
    var file: std.fs.File = cwd.openFile(filename, .{ .mode = .read_write }) catch |err| switch (err) {
        std.fs.Dir.OpenError.FileNotFound => try cwd.createFile(filename, .{}),
        else => return err,
    };
    defer file.close();

    const list = std.ArrayList(u8);
    var line = list.init(data.editor.ally);
    file.reader().streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    };

    while (true) {
        //Trim the \ns and \rs
        while (line.items.len > 0 and (line.getLast() == '\n' or line.getLast() == '\r')) {
            _ = line.pop();
        }
        try row.editorInsertRow(data.editor.numRows, line.items);
        line.clearAndFree();
        file.reader().streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                try row.editorInsertRow(data.editor.numRows, line.items);
                line.clearAndFree();
                break;
            },
            else => return err,
        };
    }
    line.deinit();
    data.editor.dirty = 0;
}

pub fn editorSave() !void {
    var newFile = false;
    if (data.editor.filename.len == 0) {
        const file = try input.editorPrompt("Save As: {s} (ESC to cancel)");
        if (file == null) {
            output.editorSetStatusMessage("Save Aborted", .{});
            return;
        } else {
            data.editor.filename = file.?;
        }
        newFile = true;
    }
    const cwd = std.fs.cwd();
    std.log.debug("what filename is: {s}", .{data.editor.filename});
    var tmpFile: std.fs.File = try cwd.createFile("temp9089", .{});
    errdefer tmpFile.close();

    const buf = try editorRowsToString();
    defer data.editor.ally.free(buf);

    try tmpFile.writeAll(buf);
    tmpFile.close();

    if (!newFile) {
        try cwd.deleteFile(data.editor.filename);
    } else {
        //somehow it is saving not as an array of u8 but as something something else
        std.log.debug("Creating file with name: {s}", .{data.editor.filename});
        const thing = try cwd.createFile(data.editor.filename, .{});
        thing.close();
    }

    try cwd.rename("temp9089", data.editor.filename);

    output.editorSetStatusMessage("{d} bytes written to disk", .{buf.len});
    data.editor.dirty = 0;
}
