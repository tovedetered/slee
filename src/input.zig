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

pub fn editorProcessKeyPress() !KeyAction{
    const c = try term.editorReadKey();
    return switch (c) {
    util.ctrlKey('q') => .Quit,
    'a','d','w','s', => {
        editorMoveCursor(c);
        return .NoOp;
    },
    else => .NoOp
    };
}

pub fn editorMoveCursor(key:u8) void{
    switch (key) {
    'a' => {
        if(data.input.cx > 0) {data.input.cx -= 1;}
        else {}
    },
    'd' => if(data.input.cx < data.editor.screenCols) {data.input.cx += 1;},
    'w' => if(data.input.cy > 0) {data.input.cy -= 1;},
    's' => if(data.input.cy < data.editor.screenRows) {data.input.cy += 1;},
    else => unreachable,
    }
}