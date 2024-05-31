const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const data = @import("./data.zig");
const c = @import("std").c;
const util = @import("./utilities.zig");

const termError = error{
read,
window_size,
cursor_pos,
};

pub fn enableRawMode() !void {
	const fd = io.getStdIn().handle;
	data.editor.orig_terminos = try posix.tcgetattr(fd);
	var raw = data.editor.orig_terminos;

	raw.iflag.IXON = false;
	raw.iflag.ICRNL = false;
	raw.iflag.BRKINT = false;
	raw.iflag.INPCK = false;
	raw.iflag.ISTRIP = false;

	raw.oflag.OPOST = false;

	raw.cflag.CSIZE = .CS8;

	raw.lflag.ECHO = false;
	raw.lflag.ICANON = false;
	raw.lflag.ISIG = false;
	raw.lflag.IEXTEN = false;

	raw.cc[@intFromEnum(posix.V.MIN)] = 1;
	raw.cc[@intFromEnum(posix.V.TIME)] = 0;

	try posix.tcsetattr(fd, .FLUSH, raw);
}

pub fn disableRawMode() void{
	const fd = io.getStdIn().handle;
	posix.tcsetattr(fd, .FLUSH, data.editor.orig_terminos) catch |err|{
		std.log.err("{any}", .{err});
		std.posix.exit(1);
	};
}

pub fn editorReadKey() !u16 {
	const stdinread = io.getStdIn().reader();
	var buf:[1] u8 = undefined;
	buf[0] = 0;
	const n = try stdinread.read(buf[0..]);
	if (n == -1) {return termError.read;}
	if(buf[0] == '\x1b'){
		var seq:[3] u8 = undefined;
		seq[0] = stdinread.readByte() catch |err| {
			std.log.debug("\n ERROR {any} \n", .{err});
			return '\x1b';
		};
		seq[1] = stdinread.readByte() catch |err| {
			std.log.debug("\n ERROR {any} \n", .{err});
			return '\x1b';
		};

		if(seq[0] == '['){
			if(seq[1] >= '0' and seq[1] <= '9'){
				seq[2] = stdinread.readByte() catch |err| {
					std.log.debug("\n ERROR {any} \n", .{err});
					return '\x1b';
				};
				switch (seq[1]) {
					'1' => return @intFromEnum(data.editorKey.HOME_KEY),
					'3' => return @intFromEnum(data.editorKey.DEL_KEY),
					'4' => return @intFromEnum(data.editorKey.END_KEY),
					'5' => return @intFromEnum(data.editorKey.PAGE_UP),
					'6' => return @intFromEnum(data.editorKey.PAGE_DOWN),
					'7' => return @intFromEnum(data.editorKey.HOME_KEY),
					'8' => return @intFromEnum(data.editorKey.END_KEY),
					else => {},
				}
			} else{
				switch (seq[1]) {
					'A' => return @intFromEnum(data.editorKey.ARROW_UP),
					'B' => return @intFromEnum(data.editorKey.ARROW_DOWN),
					'C' => return @intFromEnum(data.editorKey.ARROW_RIGHT),
					'D' => return @intFromEnum(data.editorKey.ARROW_LEFT),
					'H' => return @intFromEnum(data.editorKey.HOME_KEY),
					'F' => return @intFromEnum(data.editorKey.END_KEY),
					else => {},
				}
			}
		}else if(seq[0] == 'O'){
			switch (seq[1]) {
				'H' => return @intFromEnum(data.editorKey.HOME_KEY),
				'F' => return @intFromEnum(data.editorKey.END_KEY),
				else => {},
			}
		}

		return '\x1b';
	}

	return buf[0];
}

pub fn getWindowSize(rows: *usize, cols: *usize) !void{
	var ws = posix.winsize{
		.ws_col = undefined,
		.ws_row = undefined,
		.ws_xpixel = undefined,
		.ws_ypixel = undefined,
	};
	//NOTE: This is from zig ~0.13 this may change as it has for me
	//This only works on linux (I think) so you may have to find a more cross platform
	//solution if it is nessessary, but I use arch btw
	switch(posix.errno(os.linux.ioctl(os.linux.STDOUT_FILENO, os.linux.T.IOCGWINSZ,
		@intFromPtr(&ws)))){
		os.linux.E.SUCCESS => {
			rows.* = ws.ws_row;
			cols.* = ws.ws_col;
		},

		posix.E.BADF => return error.BadFileDescriptor,
		posix.E.INVAL => return error.InvalidRequest,
		posix.E.NOTTY => return error.NotATerminal,
		else => {
			try io.getStdOut().writeAll("\x1b[999C\x1b[999B");
			try getCursorPosition(rows, cols);
			return error.window_size;
		}
	}
}

fn getCursorPosition(rows: *usize, cols: *usize) !void {
	var buf:[32] u8 = undefined;
	var i: usize = 0;

	try io.getStdOut().writeAll("\x1b[6n");

	var ch: u8 = undefined;
	while(i < buf.len - 1) : (i += 1){
		ch = io.getStdIn().reader().readByte() catch |err| switch (err) {
			error.EndOfStream => break,
			else => return err,
		};
		buf[i] = ch;
		if(buf[i] == 'R') {break;}
	}
	i += 1;
	buf[i] = 0;
	if(buf[0] != '\x1b' or buf[1] != '[') return error.cursor_pos;

	var splits = std.mem.split(u8, buf[2..], ";");
	var line = splits.next();
	std.debug.print("{any}", .{line.?});
	rows.* = try std.fmt.parseInt(u16, line.?, 10);
	line = splits.next();
	std.debug.print("{any}", .{line.?});
	cols.* = try std.fmt.parseInt(u16, line.?, 10);
}