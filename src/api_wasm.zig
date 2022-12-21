const std = @import("std");

const math = std.math;

const Button = @import("api_modules.zig").Button;

// Javascript link
extern fn wasmSprite(f32, f32, f32, f32, f32, f32, f32, f32) void;

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

pub const ApiWASM = struct {
    camera_x: f32 = 0,
    camera_y: f32 = 0,
    map_data: [4 * 256 * 256]u8 = [_]u8{0} ** (4 * 256 * 256),
    input_state: InputState = .{},

    pub fn init() ApiWASM {
        return .{};
    }

    pub fn spr(self: ApiWASM, n: u32, x: f32, y: f32, w: f32, h: f32) void {
        const src_x = @intToFloat(f32, (n % 16) * 8);
        const src_y = @intToFloat(f32, (n / 16) * 8);
        var tx = x;
        var ty = y;
        self.transform(&tx, &ty);
        wasmSprite(tx, ty, w, h, src_x, src_y, 8, 8);
    }

    pub fn btnp(self: ApiWASM, button: Button) bool {
        _ = self;
        _ = button;
        return false;
    }

    pub fn btn(self: ApiWASM, button: Button) bool {
        _ = self;
        _ = button;
        return false;
    }

    pub fn camera(self: *ApiWASM, camera_x: f32, camera_y: f32) void {
        self.camera_x = camera_x;
        self.camera_y = camera_y;
    }

    pub fn map(self: ApiWASM, celx: u32, cely: u32, sx: f32, sy: f32, celw: u32, celh: u32, layer: u32) void {
        const offset: u32 = 256 * 256 * layer;

        // The screen only fits up to 17 tiles on it at most (16 full tiles), so we will work backwards
        // from visible only tiles so we don't end up drawing mostly things we are throwing away.
        // Testing has proven that drawing 256 * 256 tiles is extremely slow so this is a necessary change.
        // we need to know the first visible tile.
        // First find where the camera is in "tile space." Then draw that box.
        var tx = self.camera_x - sx;
        var ty = self.camera_y - sy;

        // Now figure out the first tile.
        // The first tile to be draw in "tile space."
        const first_tile_x = @floatToInt(i32, math.floor(tx / 8));
        const first_tile_y = @floatToInt(i32, math.floor(ty / 8));

        // Now draw each tile
        var screen_tile_x: i32 = -1;
        var screen_tile_y: i32 = -1;
        while (screen_tile_x < 18) {
            defer screen_tile_x += 1;
            screen_tile_y = -1;
            while (screen_tile_y < 18) {
                defer screen_tile_y += 1;
                const source_tile_x = screen_tile_x + first_tile_x + @intCast(i32, celx);
                const source_tile_y = screen_tile_y + first_tile_y + @intCast(i32, cely);

                const tile_x = screen_tile_x + first_tile_x;
                const tile_y = screen_tile_y + first_tile_y;

                // Make sure we are drawing the range of tiles we want to.
                if (source_tile_x < @max(celx, 0) or source_tile_x >= @min(celx + celw, 256)) {
                    continue;
                }

                if (source_tile_y < @max(cely, 0) or source_tile_y >= @min(cely + celh, 256)) {
                    continue;
                }
                const tile = self.map_data[@intCast(u32, source_tile_x + source_tile_y * 256) + offset];
                self.spr(tile, sx + @intToFloat(f32, 8 * tile_x), sy + @intToFloat(f32, 8 * tile_y), 8.0, 8.0);
            }
        }
    }

    pub fn mset(self: *ApiWASM, x: u32, y: u32, tile: u8, layer: u32) void {
        const offset = 256 * 256 * layer;
        self.map_data[offset + x + 256 * y] = tile;
    }

    // Internal Use
    pub fn update_input(self: *ApiWASM, input_state: InputState) void {
        self.input_state = input_state;
    }

    fn transform(self: ApiWASM, x: *f32, y: *f32) void {
        x.* = x.* - self.camera_x;
        y.* = y.* - self.camera_y;
    }
};
