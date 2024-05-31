const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const term = @import("./terminal.zig");
const util = @import("./utilities.zig");
const data = @import("./data.zig");
const ediops = @import("./editorOps.zig");
const fileops = @import("./fileio.zig");
const output = @import("./output.zig");

const KeyAction = enum {
    Quit,
    NoOp,
    MoveCursor,
    Random,
};

const inputErrors = error{
    Max_Size_Exceeded,
};

pub fn editorProcessKeyPress() !KeyAction {
    const state = struct {
        var quit_times: usize = data.QUIT_TIMES;
    };

    const c = try term.editorReadKey();
    switch (c) {
        '\r' => {
            try ediops.editorInsertNewLine();
        },

        @intFromEnum(data.editorKey.BACKSPACE), util.ctrlKey('h'), @intFromEnum(data.editorKey.DEL_KEY) => {
            if (c == @intFromEnum(data.editorKey.DEL_KEY))
                editorMoveCursor(@intFromEnum(data.editorKey.ARROW_RIGHT));
            try ediops.editorDelChar();
        },

        util.ctrlKey('s') => {
            try fileops.editorSave();
        },

        util.ctrlKey('q') => {
            if (data.editor.dirty > 0 and state.quit_times > 0) {
                try output.editorSetStatusMessage("WARNING: File has unsaved changes. Press Ctrl-Q {d} more times to quit.", .{state.quit_times});
                state.quit_times -= 1;
                return .NoOp;
            } else {
                return .Quit;
            }
        },
        @intFromEnum(data.editorKey.ARROW_LEFT),
        @intFromEnum(data.editorKey.ARROW_RIGHT),
        @intFromEnum(data.editorKey.ARROW_UP),
        @intFromEnum(data.editorKey.ARROW_DOWN),
        => {
            editorMoveCursor(c);
        },

        @intFromEnum(data.editorKey.PAGE_UP), @intFromEnum(data.editorKey.PAGE_DOWN) => {
            var times = data.editor.screenRows;
            if (c == @intFromEnum(data.editorKey.PAGE_UP)) {
                data.input.cy = data.editor.rowoff;
            } else {
                data.input.cy = data.editor.rowoff + data.editor.screenRows - 1;
                if (data.input.cy > data.editor.numRows) data.input.cy = data.editor.numRows;
            }

            while (times > 0) : (times -= 1) {
                if (c == @intFromEnum(data.editorKey.PAGE_UP)) {
                    editorMoveCursor(@intFromEnum(data.editorKey.ARROW_UP));
                } else {
                    editorMoveCursor(@intFromEnum(data.editorKey.ARROW_DOWN));
                }
            }
        },

        @intFromEnum(data.editorKey.HOME_KEY) => {
            data.input.cx = 0;
        },

        @intFromEnum(data.editorKey.END_KEY) => {
            if (data.input.cy < data.editor.numRows) {
                data.input.cx = data.editor.row[data.input.cy].render.len;
            }
        },

        util.ctrlKey('l'), '\x1b' => {
            //TODO
        },

        else => {
            try ediops.editorInsertChar(c);
        },
    }
    state.quit_times = data.QUIT_TIMES;
    return .NoOp;
}

pub fn editorMoveCursor(key: u16) void {
    var row: ?*data.erow =
        if (data.input.cy >= data.editor.numRows or data.editor.row.len == 0) null else &data.editor.row[data.input.cy];

    switch (key) {
        @intFromEnum(data.editorKey.ARROW_LEFT) => {
            if (data.input.cx > 0) {
                data.input.cx -= 1;
            } else if (data.input.cy > 0) {
                data.input.cy -= 1;
                data.input.cx = @as(u16, @intCast(data.editor.row[data.input.cy].chars.len));
            }
        },

        @intFromEnum(data.editorKey.ARROW_RIGHT) => {
            if (row != null) {
                if (data.input.cx < row.?.*.chars.len) {
                    data.input.cx += 1;
                } else if (data.input.cx > data.editor.row.len - 1) {
                    data.input.cy += 1;
                    data.input.cx = 0;
                }
            }
        },
        @intFromEnum(data.editorKey.ARROW_UP) => if (data.input.cy > 0) {
            data.input.cy -= 1;
        },
        @intFromEnum(data.editorKey.ARROW_DOWN) => if (data.input.cy < data.editor.numRows) {
            data.input.cy += 1;
        },
        else => unreachable,
    }

    row = if (data.input.cy >= data.editor.numRows) null else &data.editor.row[data.input.cy];
    const rowlen = if (row != null) row.?.chars.len else 0;
    if (data.input.cx > rowlen) {
        data.input.cx = @as(u16, @intCast(rowlen));
    }
}

pub fn editorPrompt(comptime prompt: []const u8) ![]u8 {
    const max_buf_size = 1024; // If the prompt takes up almost a KB,
    // we are doing something wrong
    var bufsize: usize = 128;
    var buf = try data.editor.ally.alloc(u8, 128);
    var buf_len: usize = 0;

    while (true) {
        try output.editorSetStatusMessage(prompt, .{buf[0..buf_len]});
        try output.editorRefreshScreen();

        const c: u16 = try term.editorReadKey();

        if (c == '\r') {
            if (buf_len != 0) {
                try output.editorSetStatusMessage("", .{});
                const result = data.editor.ally.resize(buf, buf_len);
                if (result == false) {
                    buf = try data.editor.ally.realloc(buf, bufsize);
                }
                return buf[0..buf_len];
            }
        } else if (c < 128) {
            if (!std.ascii.isControl(@as(u8, @intCast(c)))) {
                if (buf_len == bufsize - 1) {
                    bufsize *= 2;
                    if (bufsize > max_buf_size) {
                        data.editor.ally.free(buf);
                        return inputErrors.Max_Size_Exceeded;
                    }
                    const result = data.editor.ally.resize(buf, buf_len);
                    if (result == false) {
                        buf = try data.editor.ally.realloc(buf, bufsize);
                    }
                }
                buf[buf_len] = @as(u8, @intCast(c));
                buf_len += 1;
            }
        }
    }
}
