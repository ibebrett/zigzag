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

    var renderer = sdl.SDL_CreateRenderer(win, -1, sdl.SDL_RENDERER_ACCELERATED);
    assert(renderer != null);
    defer sdl.SDL_DestroyRenderer(renderer);

    var image_renderer = @ptrCast(?*sdl_image.SDL_Renderer, renderer);
    const img = @ptrCast(?*sdl.SDL_Texture, sdl_image.IMG_LoadTexture(image_renderer, "sprites.png"));
    defer sdl.SDL_DestroyTexture(img);

    //var dest: sdl.SDL_Rect = .{ .w = 100, .h = 100, .x = 10, .y = 10 };

    var done: bool = false;
    while (!done) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT)
                done = true;
        }

        _ = sdl.SDL_RenderClear(renderer);
        // copy the texture to the rendering context
        _ = sdl.SDL_RenderCopy(renderer, img, null, null); //&dest);
        // flip the backbuffer
        // this means that everything that we prepared behind the screens is actually shown
        _ = sdl.SDL_RenderPresent(renderer);
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
