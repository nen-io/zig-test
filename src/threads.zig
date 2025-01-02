const std = @import("std");
const csv = @import("csv.zig");
const print = std.debug.print;

pub fn RunTasks(
    csv_data: *csv.Data,
    allocator: std.mem.Allocator,
    work_fn: anytype,
    return_fn: anytype,
) !u64 {
    const thread_count = try std.Thread.getCpuCount();
    const num_of_data_per_thread = csv_data.*.data.items.len / thread_count;
    print("num_of_data_per_thread: {d}\n", .{num_of_data_per_thread});

    var headers_it = std.mem.splitScalar(u8, csv_data.*.header, ',');
    var headers = std.ArrayList([]const u8).init(allocator);
    defer headers.deinit();
    while (headers_it.next()) |header| {
        try headers.append(header);
    }
    const data = csv_data.*.data;
    const header_idx = headers.items.len - 1;

    print("header idx: {d}", .{header_idx});

    // Create a thread pool
    var pool = std.ArrayList(std.Thread).init(allocator);
    defer pool.deinit();

    // Create a list to store return values
    var results = try std.ArrayList(u64).initCapacity(allocator, thread_count);
    try results.resize(thread_count);
    defer results.deinit();

    std.debug.print("data: {any}\n", .{results.items}); // This causes a panic ???

    // calc start and end of each threads data

    for (0..thread_count) |i| {
        const start = i * num_of_data_per_thread;
        var end = start + num_of_data_per_thread;
        if (end > data.items.len or i == thread_count - 1) {
            end = data.items.len;
        }
        const t = try std.Thread.spawn(.{}, work_fn, .{ i, allocator, data.items[start..end], header_idx, results });
        try pool.append(t);

        std.debug.print("Spawned handle for: {d} handle: {}, start: {d}, end: {d}, max: {d}\n", .{ i, t.getHandle(), start, end, data.items.len });
    }

    // std.debug.print("data: {s}\n", .{data.*}); // This prints out the data fine.

    for (pool.items) |thread| {
        thread.join();
    }

    return return_fn(results);
}
