const std = @import("std");

pub fn GetCSVData(
    allocator: std.mem.Allocator,
) !*const []u8 {

    //open file
    const path = "Samsung_Dataset.csv";
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    //read file
    const file_size = (try file.stat()).size;
    const file_buffer = try file.readToEndAlloc(allocator, file_size);

    return &file_buffer;
}

pub fn ProcessData(raw_data: *const []u8) void {
    const split_data = std.mem.splitAny(u8, raw_data.*, "\n");
    std.debug.print("split_data: {}\n", .{split_data});
}
