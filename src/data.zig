const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

//***** Enums *****
pub const editorKey = enum(u16) {
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
    rowoff: u16,
    orig_terminos: posix.termios,
    screenRows: u16,
    screenCols: u16,
    numRows: u16,
    row: []erow,
    pub fn denit(self: *EditorConfig) void {
        for (self.row) |line| {
            self.ally.free(line.chars);
        }
        self.ally.free(self.row);
    }
};

pub const InputData = struct {
    cx: u16,
    cy: u16,
};

pub const erow = struct {
    chars: []u8,
};

//***** Values *****
pub var editor = EditorConfig{
    .ally = undefined,
    .rowoff = undefined,
    .orig_terminos = undefined,
    .screenRows = undefined,
    .screenCols = undefined,
    .numRows = undefined,
    .row = &.{},
};

pub var input = InputData{
    .cx = undefined,
    .cy = undefined,
};

pub const version = "0.0.1";
pub const editorName = "Zigitor";
