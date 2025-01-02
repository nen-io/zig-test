const std = @import("std");
const threads = @import("threads.zig");
const csv = @import("csv.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const csv_data = try csv.GetCSVData(allocator);
    defer allocator.free(csv_data);

    const processed_data = try csv.ProcessData(allocator, csv_data);

    defer {
        processed_data.*.data.deinit();
        allocator.destroy(processed_data);
    }

    const result = try threads.RunTasks(processed_data, allocator, worker, return_fn);

    // std.debug.print("{any} \n", .{csv_data.*});

    std.debug.print("Result: {any}\n", .{result});
}

fn return_fn(return_vals: std.ArrayList(u64)) u64 {
    std.debug.print("Return values: {}\n", .{return_vals});
    var total: u64 = 0;
    for (return_vals.items) |val| {
        total += val;
    }
    return total;
}

fn worker(thread_id: usize, allocator: std.mem.Allocator, data: [][]const u8, idx: usize, result: std.ArrayList(u64)) !void {
    var sum: u64 = 0;
    for (data) |line| {
        var items = std.mem.splitScalar(u8, line, ',');

        var items_array = std.ArrayList([]const u8).init(allocator);
        defer items_array.deinit();

        while (items.next()) |item| {
            try items_array.append(item);
        }

        const str_item = items_array.items[idx];
        const item = try std.fmt.parseInt(u64, str_item, 10);
        sum += item;
    }

    result.items[thread_id] = sum;

    std.debug.print("Worker thread {d} finished with result: {d} \n", .{ thread_id, sum });
}
