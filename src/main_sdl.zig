const std = @import("std");
const sdl = @cImport(@cInclude("SDL.h"));
const sdl_image = @cImport(@cInclude("SDL_image.h"));

const Api = @import("api_sdl.zig");
const Game = @import("game.zig").Game;
const assert = std.debug.assert;

const FPS_PERIOD = 1000 / 30;

const FPSResult = struct { freq: f32, period: u32 };

const FPSCounter = struct {
    last_ticks: u32,

    pub fn init() FPSCounter {
        return .{ .last_ticks = sdl.SDL_GetTicks() };
    }

    pub fn update(self: *FPSCounter) FPSResult {
        const curr = sdl.SDL_GetTicks();
        const diff = curr - self.last_ticks;
        const freq = 1.0 / (0.000000001 + (@as(f32, @floatFromInt(diff)) / 1000.0));
        self.last_ticks = curr;
        return .{ .freq = freq, .period = diff };
    }
};

pub fn main() !void {
    assert(sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) == 0);
    _ = sdl_image.IMG_Init(sdl_image.IMG_INIT_PNG);

    //const allocator = std.heap.page_allocator;

    const win = sdl.SDL_CreateWindow("ZigZag", 100, 100, 512, 512, 0);
    assert(win != null);
    defer sdl.SDL_DestroyWindow(win);

    const renderer = sdl.SDL_CreateRenderer(win, -1, sdl.SDL_RENDERER_ACCELERATED);
    assert(renderer != null);
    defer sdl.SDL_DestroyRenderer(renderer);

    // set up scaling.
    _ = sdl.SDL_RenderSetLogicalSize(renderer, 128, 128);
    _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "nearest");

    const image_renderer: ?*sdl_image.SDL_Renderer = @ptrCast(renderer);
    const img: ?*sdl.SDL_Texture = @ptrCast(sdl_image.IMG_LoadTexture(image_renderer, "sprites.png"));
    defer sdl.SDL_DestroyTexture(img);

    var api = Api.ApiSDL.init(renderer.?, img.?);
    var game = Game.init(&api);

    var fps = FPSCounter.init();

    var done: bool = false;
    var paused: bool = false;
    while (!done) {
        var print_debug = false;
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
                    sdl.SDLK_s => input_state.b_pressed = true,
                    sdl.SDLK_LEFT => input_state.left_pressed = true,
                    sdl.SDLK_RIGHT => input_state.right_pressed = true,
                    sdl.SDLK_UP => input_state.up_pressed = true,
                    sdl.SDLK_DOWN => input_state.down_pressed = true,
                    sdl.SDLK_p => paused = !paused,
                    sdl.SDLK_i => print_debug = true,
                    else => {},
                };
            }
        }

        // Update the input_state based on key down
        const keys = sdl.SDL_GetKeyboardState(null);
        input_state.a_down = keys[sdl.SDL_SCANCODE_A] == 1;
        input_state.b_down = keys[sdl.SDL_SCANCODE_S] == 1;
        input_state.left_down = keys[sdl.SDL_SCANCODE_LEFT] == 1;
        input_state.right_down = keys[sdl.SDL_SCANCODE_RIGHT] == 1;
        input_state.up_down = keys[sdl.SDL_SCANCODE_UP] == 1;
        input_state.down_down = keys[sdl.SDL_SCANCODE_DOWN] == 1;

        // Update the api based on input
        if (!paused) {
            api.update_input(input_state);

            _ = sdl.SDL_RenderClear(renderer);

            // Update the game.
            game.update(&api);

            // Draw the game.
            game.draw(&api);
        }

        // this means that everything that we prepared behind the screens is actually shown
        _ = sdl.SDL_RenderPresent(renderer);

        // Attempt to stay stable at 30fps.
        const fps_result = fps.update();
        if (print_debug) {
            std.debug.print("ZigZag Debug\n----------\n", .{});
            std.debug.print("FPS {} {}\n", .{ fps_result.freq, fps_result.period });
        }

        if (fps_result.period < FPS_PERIOD) {
            _ = sdl.SDL_Delay(FPS_PERIOD - fps_result.period);
        }
    }
}
