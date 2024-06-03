const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");
const input = @import("./input.zig");
const out = @import("./output.zig");
const data = @import("./data.zig");
const cont = @import("./fileio.zig");
const output = @import("./output.zig");

pub const std_options = .{
    .log_level = .debug,
    .logFn = logToFile,
};

pub fn main() !void {
    try terminal.enableRawMode();
    defer terminal.disableRawMode();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    try initEditor(allocator);
    defer data.editor.denit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        cont.editorOpen(args[1]) catch |err| {
            std.log.err("ERROR Opening File {s}: {!}", .{ args[1], err });
            return err;
        };
    }

    output.editorSetStatusMessage("HELP: Ctrl-S = save | Ctrl-Q = quit | Ctrl-F = find", .{});

    while (true) {
        try out.editorRefreshScreen();
        const op = try input.editorProcessKeyPress();
        switch (op) {
            .Quit => {
                try out.editorRefreshScreen();
                break;
            },
            else => {},
        }
    }
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, n: ?usize) noreturn {
    io.getStdOut().writeAll("\n*****   PANIC   *****\n") catch {};
    //data.editor.denit();
    io.getStdOut().writeAll("\x1B[2J") catch {};
    io.getStdOut().writeAll("\x1B[H") catch {};
    std.builtin.default_panic(msg, error_return_trace, n);
}

pub fn logToFile(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const scope_prefix = "(" ++ switch (scope) {
        std.log.default_log_scope => @tagName(scope),
        else => if (@intFromEnum(level) <= @intFromEnum(std.log.Level.err))
            @tagName(scope)
        else
            return,
    } ++ "): ";

    const prefix = "[" ++ comptime level.asText() ++ "] " ++ scope_prefix;

    const dirname = std.fs.getAppDataDir(std.heap.page_allocator, "sleep") catch {
        std.debug.print("Failed at getting the data dir\n", .{});
        return;
    };
    var dir = std.fs.openDirAbsolute(dirname, .{}) catch {
        std.debug.print("Failed opening dir: {s}\n", .{dirname});
        return;
    };
    var file: std.fs.File = dir.openFile("log", .{ .mode = .write_only }) catch |err| switch (err) {
        std.fs.Dir.OpenError.FileNotFound => dir.createFile("log", .{}) catch return,
        else => return,
    };
    defer file.close();
    file.seekTo(file.getEndPos() catch return) catch return;
    const message = std.fmt.allocPrint(std.heap.page_allocator, prefix ++ format ++ "\n", args) catch return;
    file.writeAll(message) catch return;
}

fn initEditor(alloc: std.mem.Allocator) !void {
    data.editor.ally = alloc;
    data.input.cx = 0;
    data.input.cy = 0;
    data.input.rx = 0;
    data.editor.numRows = 0;
    data.editor.rowoff = 0;
    data.editor.coloff = 0;
    data.editor.row = &.{};

    try terminal.getWindowSize(&data.editor.screenRows, &data.editor.screenCols);

    data.editor.screenRows -= 2;
    data.editor.statustime = 0;
}
