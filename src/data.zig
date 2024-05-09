const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

//***** Enums *****

pub const editorKey = enum(u16){
    ARROW_LEFT = 1000,
    ARROW_RIGHT = 1001,
    ARROW_UP = 1002,
    ARROW_DOWN = 1003,
    };

//***** Defs *****
pub const EditorConfig = struct {
    orig_terminos: posix.termios,
    screenRows: u16,
    screenCols: u16,
    };

pub const InputData = struct{
    cx: u16,
    cy: u16,
    };

//***** Values *****
pub var editor = EditorConfig {
    .orig_terminos = undefined,
    .screenRows = undefined,
    .screenCols = undefined,
};

pub var input = InputData {
    .cx = undefined,
    .cy = undefined,
};

pub const version = "0.0.1";
pub const editorName = "Zigitor";