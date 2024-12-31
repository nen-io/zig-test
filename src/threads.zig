const std = @import("std");
const print = std.debug.print;

pub fn RunTasks(
    T: type,
    data: *const []T,
    allocator: std.mem.Allocator,
    work_fn: anytype,
    return_fn: anytype,
) !T {
    const thread_count = try std.Thread.getCpuCount();
    print("threads:{d}, data_len: {d}\n", .{ thread_count, data.*.len });
    const num_of_data_per_thread: usize = data.*.len / thread_count;

    print("num_of_data_per_thread: {d}\n", .{num_of_data_per_thread});

    // Create a thread pool
    var pool = std.ArrayList(std.Thread).init(allocator);
    defer pool.deinit();

    var return_values = std.ArrayList(T).init(allocator);
    defer return_values.deinit();

    for (0..thread_count) |i| {
        const t = try std.Thread.spawn(.{}, work_fn, .{i});
        try pool.append(t);

        std.debug.print("Spawned handle for: {d} handle: {}\n", .{ i, t.getHandle() });
    }

    std.debug.print("data: {s}\n", .{data.*}); // This prints out the data fine.

    for (pool.items) |thread| {
        thread.join();
    }

    std.debug.print("data: {s}\n", .{data.*}); // This causes a panic ???

    return return_fn(return_values);
}
