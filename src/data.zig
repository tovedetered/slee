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
		var count:usize = 0;
		std.log.debug("Starting Denit with {d} rows, numrows: {d}", .{self.row.len, self.numRows});
		for (self.row) |line| {
			count += 1;
			self.ally.free(line.chars);
			self.ally.free(line.render);
			std.log.debug("Deinit succeeded for {d} rows", .{count});
			//What is happening is that the row count is not resetting
		}
		std.log.debug("Sucessfully deinialized the rows", .{});
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
pub const QUIT_TIMES = 3;
