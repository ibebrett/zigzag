const std = @import("std");
const sdl = @cImport(@cInclude("SDL.h"));
const sdl_image = @cImport(@cInclude("SDL_image.h"));

pub const Button = enum { LEFT, RIGHT, UP, DOWN, A, B };

pub const InputState = struct {
    left_down: bool = false,
    left_pressed: bool = false,

    right_down: bool = false,
    right_pressed: bool = false,

    up_down: bool = false,
    up_pressed: bool = false,

    down_down: bool = false,
    down_pressed: bool = false,

    a_down: bool = false,
    a_pressed: bool = false,

    b_down: bool = false,
    b_pressed: bool = false,

    d_down: bool = false,
    d_pressed: bool = false,
};

pub const Api = struct {
    renderer: *sdl.SDL_Renderer,
    texture: *sdl.SDL_Texture,
    input_state: InputState,

    pub fn init(renderer: *sdl.SDL_Renderer, texture: *sdl.SDL_Texture) Api {
        return .{ .renderer = renderer, .texture = texture, .input_state = .{} };
    }

    pub fn spr(self: Api, n: u32, x: f32, y: f32, w: f32, h: f32) void {
        const src_x = (n % 16) * 8;
        const src_y = (n / 16) * 8;
        const src: sdl.SDL_Rect = .{ .x = @intCast(i32, src_x), .y = @intCast(i32, src_y), .w = 8, .h = 8 };
        const dest: sdl.SDL_Rect = .{ .w = @floatToInt(i32, w), .h = @floatToInt(i32, h), .x = @floatToInt(i32, x), .y = @floatToInt(i32, y) };
        _ = sdl.SDL_RenderCopy(self.renderer, self.texture, &src, &dest);
    }

    pub fn btnp(self: Api, button: Button) bool {
        return switch (button) {
            Button.LEFT => self.input_state.left_pressed,
            Button.RIGHT => self.input_state.right_pressed,
            Button.UP => self.input_state.up_pressed,
            Button.DOWN => self.input_state.down_pressed,
            Button.A => self.input_state.a_pressed,
            Button.B => self.input_state.b_pressed,
        };
    }

    pub fn btn(self: Api, button: Button) bool {
        return switch (button) {
            Button.LEFT => self.input_state.left_down,
            Button.RIGHT => self.input_state.right_down,
            Button.UP => self.input_state.up_down,
            Button.DOWN => self.input_state.down_down,
            Button.A => self.input_state.a_down,
            Button.B => self.input_state.b_down,
        };
    }

    pub fn update_input(self: *Api, input_state: InputState) void {
        self.input_state = input_state;
    }
};
