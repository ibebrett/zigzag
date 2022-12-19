const std = @import("std");
const sdl = @cImport(@cInclude("SDL.h"));
const sdl_image = @cImport(@cInclude("SDL_image.h"));

const assert = std.debug.assert;

pub fn main() !void {
    assert(sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) == 0);
    _ = sdl_image.IMG_Init(sdl_image.IMG_INIT_PNG);
    const allocator = std.heap.page_allocator;

    const win = sdl.SDL_CreateWindow("Hello", 100, 100, 256, 256, 0);
    assert(win != null);
    defer sdl.SDL_DestroyWindow(win);

    var done: bool = false;
    while (!done) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT)
                done = true;
        }
    }

    const f = try std.fs.openFileAbsolute(
        "C:\\Users\\ibebr\\OneDrive\\Documents\\hello.txt",
        .{},
    );
    defer f.close();

    const contents = try f.reader().readAllAlloc(
        allocator,
        10000,
    );

    std.debug.print(
        "some content: {s} {d}\n",
        .{ contents, contents.len },
    );
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Hello", .{});
    try bw.flush(); // don't forget to flush!
    sdl.SDL_Log("HELLO FROM SDL");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
