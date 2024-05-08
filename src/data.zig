const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

pub const EditorConfig = struct {
    orig_terminos: posix.termios,
    };

pub var editor = EditorConfig {
    .orig_terminos = undefined,
};