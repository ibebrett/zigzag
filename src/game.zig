const std = @import("std");
const Api = @import("api.zig");
const ApiTypes = @import("api_modules.zig");

const RndGen = std.rand.DefaultPrng;

pub const Game = struct {
    x: f32 = 30.0,
    y: f32 = 30.0,
    cx: f32 = 0.0,
    cy: f32 = 0.0,
    sprite: u32 = 2,
    camera_move: bool = false,
    map_offset: u32 = 0,
    rnd: std.rand.DefaultPrng,
    randomize_count: u32 = 0,

    pub fn init(api: *Api.Api) Game {
        var rnd = RndGen.init(0);

        // Build a map of grass.
        var x: u32 = 0;
        var y: u32 = 0;
        while (x < 256) {
            while (y < 256) {
                api.mset(x, y, 48, 0);
                y += 1;
            }
            x += 1;
            y = 0;
        }

        return .{ .rnd = rnd };
    }

    pub fn update(self: *Game, api: *Api.Api) void {
        if (api.btn(ApiTypes.Button.RIGHT)) {
            if (!self.camera_move) {
                self.x += 1.0;
            } else {
                self.cx += 1.0;
            }
        }
        if (api.btn(ApiTypes.Button.LEFT)) {
            if (!self.camera_move) {
                self.x -= 1.0;
            } else {
                self.cx -= 1.0;
            }
        }
        if (api.btn(ApiTypes.Button.DOWN)) {
            if (!self.camera_move) {
                self.y += 1.0;
            } else {
                self.cy += 1.0;
            }
        }
        if (api.btn(ApiTypes.Button.UP)) {
            if (!self.camera_move) {
                self.y -= 1.0;
            } else {
                self.cy -= 1.0;
            }
        }
        if (api.btnp(ApiTypes.Button.A)) {
            self.sprite = (self.sprite + 1) % 16;
        }
        if (api.btnp(ApiTypes.Button.B)) {
            self.camera_move = !self.camera_move;
        }

        self.randomize_count = (self.randomize_count + 1) % 10;
        // Randomize.
        if (self.randomize_count == 0) {
            var x: u32 = 0;
            var y: u32 = 0;
            while (x < 256) {
                while (y < 256) {
                    if (self.rnd.random().int(u8) % 10 == 0) {
                        api.mset(x, y, 38 + self.rnd.random().int(u8) % 4, 1);
                    } else {
                        api.mset(x, y, 0, 1);
                    }
                    y += 1;
                }
                x += 1;
                y = 0;
            }
        }

        api.camera(self.cx, self.cy);
    }

    pub fn draw(self: *Game, api: *Api.Api) void {
        // draw the map
        api.map(0, 0, 0, 0, 256, 256, 0);
        api.spr(self.sprite, self.x, self.y, 8.0, 8.0);
        api.map(0, 0, 0, 0, 256, 256, 1);
    }
};
