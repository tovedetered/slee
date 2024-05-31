const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");
const rowop = @import("./rowOps.zig");

pub fn editorInsertChar(c: u16) !void{
	if(data.input.cy == data.editor.numRows){
		try rowop.editorInsertRow(data.editor.numRows, "");
	}
	try rowop.editorRowInsertChar(&data.editor.row[data.input.cy],
		data.input.cx, c);
	data.input.cx += 1;
}

pub fn editorDelChar() !void {
	if(data.input.cy == data.editor.numRows) return;
	if(data.input.cx == 0 and data.input.cy == 0) return;

	const row:*data.erow = &data.editor.row[data.input.cy];
	if (data.input.cx > 0) {
		try rowop.editorRowDelChar(row, data.input.cx - 1);
		data.input.cx -= 1;
	}
	else {
		data.input.cx = data.editor.row[data.input.cy - 1].chars.len;
		try rowop.editorRowAppendString(&data.editor.row[data.input.cy - 1], row.chars);
		try rowop.editorDelRow(data.input.cy);
		data.input.cy -= 1;
	}
}

pub fn editorInsertNewLine() !void {
	if(data.input.cx == 0){
		try rowop.editorInsertRow(data.input.cy + 1, "");
	}else{
		var row: *data.erow = &data.editor.row[data.input.cy];
		try rowop.editorInsertRow(data.input.cy + 1, row.chars[data.input.cx..]);
		row = &data.editor.row[data.input.cy];
		row.chars.len = data.input.cx;
		try rowop.editorUpdateRow(row);
	}
	data.input.cy += 1;
	data.input.cx = 0;
}
