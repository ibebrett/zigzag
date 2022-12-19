const std = @import("std");
const sdl = @cImport(@cInclude("SDL.h"));
const sdl_image = @cImport(@cInclude("SDL_image.h"));

pub const Button = enum { LEFT, RIGHT, UP, DOWN, A, B };

pub const Api = struct {
    renderer: *sdl.SDL_Renderer,
    texture: *sdl.SDL_Texture,

    pub fn init(renderer: *sdl.SDL_Renderer, texture: *sdl.SDL_Texture) Api {
        return .{ .renderer = renderer, .texture = texture };
    }

    pub fn spr(self: Api, n: u32, x: f32, y: f32, w: f32, h: f32) void {
        const src_x = (n % 16) * 8;
        const src_y = (n / 16) * 8;
        const src: sdl.SDL_Rect = .{ .x = @intCast(i32, src_x), .y = @intCast(i32, src_y), .w = 8, .h = 8 };
        const dest: sdl.SDL_Rect = .{ .w = @floatToInt(i32, w), .h = @floatToInt(i32, h), .x = @floatToInt(i32, x), .y = @floatToInt(i32, y) };
        _ = sdl.SDL_RenderCopy(self.renderer, self.texture, &src, &dest);
    }

    pub fn btn(self: Api) bool {
        _ = self;
        return true;
    }

    pub fn btnp(self: Api) bool {
        _ = self;
        return true;
    }
};
