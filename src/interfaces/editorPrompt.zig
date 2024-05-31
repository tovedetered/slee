const std = @import("std");
const output = @import("./../output.zig");
const term = @import("./../terminal.zig");

pub fn editorPrompt(comptime prompt: []const u8) ![]u8 {
    const max_buf_size = 1024; // If the prompt takes up almost a KB,
    // we are doing something wrong
    var bufsize: usize = 128;
    var buf = try std.BoundedArray(u8, max_buf_size).init(bufsize);
    var buf_len: usize = 0;

    while (true) {
        try output.editorSetStatusMessage(prompt, .{buf});
        try output.editorRefreshScreen();

        const c = try term.editorReadKey();
        if (c == 'r') {
            if (buf_len != 0) {
                try output.editorSetStatusMessage("", .{});
                try buf.resize(buf_len);
                return buf.slice();
            }
        } else if (c < 128) {
            if (!std.ascii.isControl(@as(u8, @intCast(c)))) {
                if (buf_len == bufsize - 1) {
                    bufsize *= 2;
                    try buf.resize(bufsize);
                }
                buf.slice()[buf_len] = @as(u8, @intCast(c));
                buf_len += 1;
            }
        }
    }
}
