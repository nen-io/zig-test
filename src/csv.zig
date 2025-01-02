const std = @import("std");

pub fn GetCSVData(
    allocator: std.mem.Allocator,
) ![]u8 {

    //open file
    const path = "Samsung_Dataset.csv";
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    //read file
    const file_size = (try file.stat()).size;
    const file_buffer = try file.readToEndAlloc(allocator, file_size);

    return file_buffer;
}

pub const Data = struct {
    header: []const u8,
    data: std.ArrayList([]const u8),
};

pub fn ProcessData(allocator: std.mem.Allocator, raw_data: []u8) !*Data {
    var it_data = std.mem.splitScalar(u8, raw_data, '\n');
    const header = it_data.first();
    var data = std.ArrayList([]const u8).init(allocator);
    while (it_data.next()) |line| {
        try data.append(line);
    }

    const data_ptr = try allocator.create(Data);

    data_ptr.* = Data{ .header = header, .data = data };

    return data_ptr;
}
