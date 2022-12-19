const std = @import("std");
const sdl = @cImport(@cInclude("SDL.h"));
const sdl_image = @cImport(@cInclude("SDL_image.h"));

const Api = @import("api.zig");
const Game = @import("game.zig").Game;
const assert = std.debug.assert;

pub fn main() !void {
    assert(sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) == 0);
    _ = sdl_image.IMG_Init(sdl_image.IMG_INIT_PNG);

    const allocator = std.heap.page_allocator;

    const win = sdl.SDL_CreateWindow("ZigZag", 100, 100, 512, 512, 0);
    assert(win != null);
    defer sdl.SDL_DestroyWindow(win);

    var renderer = sdl.SDL_CreateRenderer(win, -1, sdl.SDL_RENDERER_ACCELERATED);
    assert(renderer != null);
    defer sdl.SDL_DestroyRenderer(renderer);

    // set up scaling.
    _ = sdl.SDL_RenderSetLogicalSize(renderer, 128, 128);
    _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "nearest");

    var image_renderer = @ptrCast(?*sdl_image.SDL_Renderer, renderer);
    const img = @ptrCast(?*sdl.SDL_Texture, sdl_image.IMG_LoadTexture(image_renderer, "sprites.png"));
    defer sdl.SDL_DestroyTexture(img);

    var api = Api.Api.init(renderer.?, img.?);
    var game = Game.init();

    var done: bool = false;
    while (!done) {
        var event: sdl.SDL_Event = undefined;

        var input_state: Api.InputState = .{};
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                done = true;
            }

            if (event.type == sdl.SDL_KEYDOWN) {
                // Detect key presses.
                _ = switch (event.key.keysym.sym) {
                    sdl.SDLK_a => input_state.a_pressed = true,
                    sdl.SDLK_b => input_state.b_pressed = true,
                    sdl.SDLK_LEFT => input_state.left_pressed = true,
                    sdl.SDLK_RIGHT => input_state.right_pressed = true,
                    sdl.SDLK_UP => input_state.up_pressed = true,
                    sdl.SDLK_DOWN => input_state.down_pressed = true,
                    else => {},
                };
            }
        }

        // Update the input_state based on key down
        const keys = sdl.SDL_GetKeyboardState(null);
        input_state.a_down = keys[sdl.SDL_SCANCODE_A] == 1;
        input_state.b_down = keys[sdl.SDL_SCANCODE_B] == 1 ;
        input_state.left_down = keys[sdl.SDL_SCANCODE_LEFT] == 1;
        input_state.right_down = keys[sdl.SDL_SCANCODE_RIGHT] == 1;
        input_state.up_down = keys[sdl.SDL_SCANCODE_UP] == 1;
        input_state.down_down = keys[sdl.SDL_SCANCODE_DOWN] == 1;

        // Update the api based on input
        api.update_input(input_state);

        _ = sdl.SDL_RenderClear(renderer);

        // Update the game.
        game.update(api);
        // Draw the game.
        game.draw(api);

        // copy the texture to the rendering context
        //_ = sdl.SDL_RenderCopy(renderer, img, null, null); //&dest);
        // flip the backbuffer
        // this means that everything that we prepared behind the screens is actually shown
        _ = sdl.SDL_RenderPresent(renderer);

        // For now just sleep at 30fps.
        _ = sdl.SDL_Delay(1000 / 30);
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
