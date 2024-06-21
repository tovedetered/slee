const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const time = @import("std").time;
const data = @import("./data.zig");
const string = @import("./data-struct/string.zig");
const rowOp = @import("./rowOps.zig");
const syntax = @import("./syntax_highlighting.zig");

pub fn editorScroll() void {
    data.input.rx = 0;
    if (data.input.cy < data.editor.numRows) {
        data.input.rx = rowOp.editorRowCxToRx(&data.editor.row[data.input.cy], data.input.cx);
    }

    if (data.input.cy < data.editor.rowoff) {
        data.editor.rowoff = data.input.cy;
    }
    if (data.input.cy >= data.editor.rowoff + data.editor.screenRows) {
        data.editor.rowoff = data.input.cy - data.editor.screenRows + 1;
    }
    if (data.input.rx < data.editor.coloff) {
        data.editor.coloff = data.input.rx;
    }
    if (data.input.rx >= data.editor.coloff + data.editor.screenCols) {
        data.editor.coloff = data.input.rx - data.editor.screenCols + 1;
    }
}

pub fn editorRefreshScreen() !void {
    editorScroll();

    var buf = string.init(data.editor.ally);
    defer buf.free();

    try buf.append("\x1b[?25l");
    try buf.append("\x1b[H");

    try editorDrawRows(&buf);
    try editorDrawStatusBar(&buf);
    try editorDrawMessageBar(&buf);

    const setCursorPos =
        try std.fmt.allocPrint(std.heap.page_allocator, "\x1b[{d};{d}H", .{ (data.input.cy - data.editor.rowoff) + 1, (data.input.rx - data.editor.coloff) + 1 });
    try buf.append(setCursorPos);

    try buf.append("\x1b[?25h");

    try io.getStdOut().writeAll(buf.b);
}

pub fn editorDrawRows(ab: *string.string) !void {
    for (0..data.editor.screenRows) |y| {
        const filerow = y + data.editor.rowoff;
        if (filerow >= data.editor.numRows) {
            if (data.editor.numRows == 0 and y == data.editor.screenRows / 3) {
                const welcome: []u8 = try std.fmt.allocPrint(std.heap.page_allocator, "{s} Editor -- version: {s}", .{ data.editorName, data.version });
                var padding: usize = (data.editor.screenCols - welcome.len) / 2;
                if (padding != 0) {
                    try ab.append("~");
                    padding -= 1;
                }
                while (padding > 0) : (padding -= 1) {
                    try ab.append(" ");
                }
                try ab.*.append(welcome);
            } else {
                try ab.*.append("~");
            }
        } else {
            var len: i65 = @as(i65, @intCast(data.editor.row[filerow].render.len)) -
                @as(i65, @intCast(data.editor.coloff));
            if (len < 0) len = 0;
            if (len > data.editor.screenCols) len = data.editor.screenCols;

            const bar: *const []u8 = &data.editor.row[filerow].render[data.editor.coloff..];
            const hl: *const []data.editorHighlight = &data.editor.row[filerow].highlight[data.editor.coloff..];

            for (0..@as(usize, @intCast(len))) |j| {
                if (hl.*[j] == data.editorHighlight.HL_NORMAL) {
                    try ab.append("\x1b[39m"); //default color
                    try ab.append(&.{bar.*[j]});
                } else {
                    const color: u8 = syntax.editorSyntaxToColor(hl.*[j]);
                    try ab.print("\x1b[{d}m", .{color}, data.editor.ally);
                    try ab.append(&.{bar.*[j]}); // highlight color
                }
            }
            try ab.append("\x1b[39m");
        }
        try ab.*.append("\x1b[K");
        try ab.*.append("\r\n");
    }
}

pub fn editorDrawStatusBar(str: *string.string) !void {
    try str.append("\x1b[7m");
    var status: []u8 = &.{};
    var rstatus: []u8 = &.{};

    status = try std.fmt.allocPrint(data.editor.ally, "{s} - {d} lines {s}", .{
        if (data.editor.filename.len > 0) data.editor.filename else "[NO NAME]",
        data.editor.numRows,
        if (data.editor.dirty > 0) "(modified)" else "",
    });
    defer data.editor.ally.free(status);

    rstatus = try std.fmt.allocPrint(data.editor.ally, "{d}:{d}", .{ data.input.cy + 1, data.input.rx + 1 });
    defer data.editor.ally.free(rstatus);

    const rlen = rstatus.len;
    var len: usize = status.len;
    if (len > data.editor.screenCols) len = data.editor.screenCols;
    try str.append(status[0..len]);

    while (len < data.editor.screenCols) {
        if (data.editor.screenCols - len == rlen) {
            try str.append(rstatus);
            break;
        } else {
            try str.append(" ");
            len += 1;
        }
    }
    try str.append("\x1b[m");
    try str.append("\r\n");
}

pub fn editorDrawMessageBar(str: *string.string) !void {
    try str.append("\x1b[K");
    var len: usize = data.editor.statusmsg.len;
    if (len > data.editor.screenCols) len = data.editor.screenCols;
    if (len > 0 and time.milliTimestamp() - data.editor.statustime < 5000) {
        try str.append(data.editor.statusmsg);
    }
}

pub fn editorSetStatusMessage(comptime fmt: []const u8, args: anytype) void {
    data.editor.ally.free(data.editor.statusmsg);
    data.editor.statusmsg = std.fmt.allocPrint(data.editor.ally, fmt, args) catch |err| errblock: {
        std.log.err("(recoverable) In output.zig - editorSetStatusMessage(): {!}", .{err});
        break :errblock "ERROR when setting status message";
    };
    data.editor.statustime = time.milliTimestamp();
}
