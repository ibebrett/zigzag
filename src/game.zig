const Api = @import("api.zig");

pub const Game = struct {
    x: f32,

    pub fn init() Game {
        return .{ .x = 0.0 };
    }

    pub fn update(self: *Game, api: Api.Api) void {
        if (api.btnp()) {
            self.x += 1.0;
        }
    }

    pub fn draw(self: *Game, api: Api.Api) void {
        api.spr(2, 30.0 + self.x, 30.0, 8.0, 8.0);
    }
};
