const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

//***** Enums *****
pub const editorKey = enum(u16) {
    BACKSPACE = 127,

    ARROW_LEFT = 1000,
    ARROW_RIGHT,
    ARROW_UP,
    ARROW_DOWN,
    DEL_KEY,
    HOME_KEY,
    END_KEY,
    PAGE_UP,
    PAGE_DOWN,
    };

//***** Defs *****
pub const EditorConfig = struct {
    ally: std.mem.Allocator,
    rowoff: usize,
    coloff: usize,
    orig_terminos: posix.termios,
    screenRows: usize,
    screenCols: usize,
    numRows: usize,
    row: []erow,
    filename: []u8,
    statusmsg: []u8,
    statustime: i64,
    dirty: usize,
    pub fn denit(self: *EditorConfig) void {
        for (self.row) |line| {
            self.ally.free(line.chars);
            self.ally.free(line.render);
        }
        self.ally.free(self.row);
        self.ally.free(self.filename);
        self.ally.free(self.statusmsg);
    }
};

pub const InputData = struct {
    cx: usize,
    cy: usize,
    rx: usize,
    };

pub const erow = struct {
    chars: []u8,
    render: []u8,
    };

//***** Values *****
pub var editor = EditorConfig{
    .ally = undefined,
    .rowoff = undefined,
    .coloff = undefined,
    .orig_terminos = undefined,
    .screenRows = undefined,
    .screenCols = undefined,
    .numRows = undefined,
    .filename = &.{},
    .row = &.{},
    .statusmsg = &.{},
    .statustime = undefined,
    .dirty = 0,
};

pub var input = InputData{
    .cx = undefined,
    .cy = undefined,
    .rx = undefined,
};

pub const version = "0.0.1";
pub const editorName = "Zigitor";

pub const TABSTOP = 4;
