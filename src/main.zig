const std = @import("std");
const threads = @import("threads.zig");
const csv = @import("csv.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();

    const allocator = arena.allocator();

    const csv_data = try csv.GetCSVData(allocator);
    const result = try threads.RunTasks(u8, csv_data, allocator, worker, return_fn);
    // std.debug.print("{any} \n", .{csv_data.*});

    std.debug.print("Result: {d}\n", .{result});
}

fn return_fn(return_vals: std.ArrayList(u8)) u8 {
    std.debug.print("Return values: {d}\n", .{return_vals.items});
    return 12;
}

fn worker(id: usize) void {
    std.debug.print("Worker thread {d} \n", .{id});
}
