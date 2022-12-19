const Api = @import("api.zig");

pub const Game = struct {
    x: f32 = 30.0,
    y: f32 = 30.0,

    pub fn init() Game {
        return .{};
    }

    pub fn update(self: *Game, api: Api.Api) void {
        if (api.btn(Api.Button.RIGHT)) {
            self.x += 1.0;
        }
        if (api.btn(Api.Button.LEFT)) {
            self.x -= 1.0;
        }
        if (api.btn(Api.Button.DOWN)) {
            self.y += 1.0;
        }
        if (api.btn(Api.Button.UP)) {
            self.y -= 1.0;
        }
    }

    pub fn draw(self: *Game, api: Api.Api) void {
        api.spr(2, self.x, self.y, 8.0, 8.0);
    }
};
