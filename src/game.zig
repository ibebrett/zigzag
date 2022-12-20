const std = @import("std");
const Api = @import("api.zig");

const RndGen = std.rand.DefaultPrng;

pub const Game = struct {
    x: f32 = 30.0,
    y: f32 = 30.0,
    cx: f32 = 0.0,
    cy: f32 = 0.0,
    sprite: u32 = 2,
    camera_move: bool = false,
    map_offset: u32 = 0,

    pub fn init(api: *Api.Api) Game {
        var x: u32 = 0;
        var y: u32 = 0;
        var rnd = RndGen.init(0);
        while (x < 256) {
            while (y < 256) {
                api.mset(x, y, 48 + rnd.random().int(u8) % 4, 0);
                y += 1;
            }
            x += 1;
            y = 0;
        }

        return .{};
    }

    pub fn update(self: *Game, api: *Api.Api) void {
        if (api.btn(Api.Button.RIGHT)) {
            if (!self.camera_move) {
                self.x += 1.0;
            } else {
                self.cx += 1.0;
            }
        }
        if (api.btn(Api.Button.LEFT)) {
            if (!self.camera_move) {
                self.x -= 1.0;
            } else {
                self.cx -= 1.0;
            }
        }
        if (api.btn(Api.Button.DOWN)) {
            if (!self.camera_move) {
                self.y += 1.0;
            } else {
                self.cy += 1.0;
            }
        }
        if (api.btn(Api.Button.UP)) {
            if (!self.camera_move) {
                self.y -= 1.0;
            } else {
                self.cy -= 1.0;
            }
        }
        if (api.btnp(Api.Button.A)) {
            self.sprite = (self.sprite + 1) % 16;
        }
        if (api.btnp(Api.Button.B)) {
            self.camera_move = !self.camera_move;
        }

        //self.map_offset = (1 + self.map_offset) % 4;

        api.camera(self.cx, self.cy);
    }

    pub fn draw(self: *Game, api: *Api.Api) void {
        // draw the map
        api.map(self.map_offset, 12, 4, 4, 8, 8, 0);

        api.spr(self.sprite, self.x, self.y, 8.0, 8.0);
    }
};
