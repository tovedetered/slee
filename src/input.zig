const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const term = @import("./terminal.zig");
const util = @import("./utilities.zig");
const data = @import("./data.zig");

const KeyAction = enum {
    Quit,
    NoOp,
    MoveCursor,
};

pub fn editorProcessKeyPress() !KeyAction {
    const c = try term.editorReadKey();
    return switch (c) {
        util.ctrlKey('q') => .Quit,
        @intFromEnum(data.editorKey.ARROW_LEFT),
        @intFromEnum(data.editorKey.ARROW_RIGHT),
        @intFromEnum(data.editorKey.ARROW_UP),
        @intFromEnum(data.editorKey.ARROW_DOWN),
        => {
            editorMoveCursor(c);
            return .NoOp;
        },
        @intFromEnum(data.editorKey.PAGE_UP), @intFromEnum(data.editorKey.PAGE_DOWN) => {
            var times = data.editor.screenRows;
            while (times > 0) : (times -= 1) {
                if (c == @intFromEnum(data.editorKey.PAGE_UP)) {
                    editorMoveCursor(@intFromEnum(data.editorKey.ARROW_UP));
                } else {
                    editorMoveCursor(@intFromEnum(data.editorKey.ARROW_DOWN));
                }
            }
            return .NoOp;
        },
        @intFromEnum(data.editorKey.HOME_KEY) => {
            data.input.cx = 0;
            return .NoOp;
        },
        @intFromEnum(data.editorKey.END_KEY) => {
            data.input.cx = data.editor.screenCols - 1;
            return .NoOp;
        },
        else => .NoOp,
    };
}

pub fn editorMoveCursor(key: u16) void {
    switch (key) {
        @intFromEnum(data.editorKey.ARROW_LEFT) => {
            if (data.input.cx > 0) {
                data.input.cx -= 1;
            } else {}
        },
        @intFromEnum(data.editorKey.ARROW_RIGHT) => if (data.input.cx < data.editor.screenCols) {
            data.input.cx += 1;
        },
        @intFromEnum(data.editorKey.ARROW_UP) => if (data.input.cy > 0) {
            data.input.cy -= 1;
        },
        @intFromEnum(data.editorKey.ARROW_DOWN) => if (data.input.cy < data.editor.numRows) {
            data.input.cy += 1;
        },
        else => unreachable,
    }
}
