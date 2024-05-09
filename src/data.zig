const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

pub const EditorConfig = struct {
    orig_terminos: posix.termios,
    screenRows: u16,
    screenHeight: u16,
    };

pub var editor = EditorConfig {
    .orig_terminos = undefined,
    .screenRows = undefined,
    .screenHeight = undefined,
};