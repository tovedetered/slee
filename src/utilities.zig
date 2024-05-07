pub fn ctrlKey(comptime ch:u8) u8 {
    return ch & 0x1f;
}