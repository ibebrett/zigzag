const std = @import("std");
const Api = @import("api.zig");
const ApiTypes = @import("api_modules.zig");


const RndGen = std.rand.DefaultPrng;

const Object = struct { x: f32 = 0, y: f32 = 0, spr: u32 = 4, draw: bool = true };

const Bullet = struct { 
    x: f32 = 0, 
    y: f32 = 0, 
    spr: u32 = 66, 
    dir: ApiTypes.Direction = ApiTypes.Direction.RIGHT, 
    spd: f32 = 2.0,
    draw: bool = false,
};

const NUM_OBJECTS = 5000;
const NUM_BULLETS = 100;
const BULLET_SPEED = 2.0;

fn make_bullet() Bullet {
    return Bullet{};
}

fn makeObject() Object {
    return Object{ .x = 0.0, .y = 0.0, .spr = 4, .draw = true };
}

fn pointInBox(x: f32, y: f32, bx: f32, by: f32, bw: f32, bh: f32) bool {
    return (x >= bx and x <= bx + bw and y >= by and y <= by + bh);
}

fn boxIntersect(x1: f32, y1: f32, w1: f32, h1: f32, x2: f32, y2: f32, w2: f32, h2: f32) bool {
    // Basically check if any of our points are within
    return (
    // box1 points in box2
        pointInBox(x1, y1, x2, y2, w2, h2) or
        pointInBox(x1 + w1, y1, x2, y2, w2, h2) or
        pointInBox(x1, y1 + h1, x2, y2, w2, h2) or
        pointInBox(x1 + w1, y1 + h1, x2, y2, w2, h2) or
        // box2 points in box1
        pointInBox(x2, y2, x1, y1, w1, h1) or
        pointInBox(x2 + w2, y2, x1, y1, w1, h1) or
        pointInBox(x2, y2 + h2, x1, y1, w1, h1) or
        pointInBox(x2 + w2, y2 + h2, x1, y1, w1, h1));
}

pub const Game = struct {
    x: f32 = 30.0,
    y: f32 = 30.0,
    sprite: u32 = 2,
    map_offset: u32 = 0,
    rnd: std.rand.DefaultPrng,
    randomize_count: u32 = 0,
    random_seed: u32 = 0,
    objects: [NUM_OBJECTS]Object,
    bullets: [NUM_BULLETS]Bullet = [_]Bullet{make_bullet()} ** NUM_BULLETS,
    last_bullet_idx: u32 = 0,



    pub fn init(api: *Api.Api) Game {
        var rnd = RndGen.init(0);

        // Build a map of grass.
        var x: u32 = 0;
        var y: u32 = 0;
        while (x < 256) {
            while (y < 256) {
                if (rnd.random().int(u8) % 10 == 0) {
                    api.mset(x, y, 1, 0);
                } else {
                    api.mset(x, y, 48, 0);
                }

                y += 1;
            }
            x += 1;
            y = 0;
        }

        var objects = [_]Object{makeObject()} ** NUM_OBJECTS;

        // Place the birds on the grass.
        for (objects) |*o| {
            // Don't place the birds on obstacles.
            while (true) {
                var o_x = rnd.random().int(u32) % 100;
                var o_y = rnd.random().int(u32) % 100;
                if (api.mget(o_x, o_y, 0) == 48) {
                    o.*.x = @intToFloat(f32, o_x) * 8.0 + 0.1;
                    o.*.y = @intToFloat(f32, o_y) * 8.0 + 0.1;
                    break;
                }
            }
        }

        return .{ .rnd = rnd, .objects = objects };
    }

    pub fn walkableTile(self: Game, api: *Api.Api, x: f32, y: f32) bool {
        _ = self;
        if (x < 0 or x >= 256 * 8 or y < 0 or y > 256 * 8) {
            return false;
        }
        const tx = @floatToInt(u32, std.math.floor(x / 8.0));
        const ty = @floatToInt(u32, std.math.floor(y / 8.0));

        const tile = api.mget(tx, ty, 0); // == 48; // only grass is walkable.

        // Only grass is walkable.
        return tile == 48;
    }

    pub fn worldMove(self: Game, api: *Api.Api, x: f32, y: f32, w: f32, h: f32, dx: *f32, dy: *f32) void {
        // Keep world moving, ta
        self.worldMovePoint(api, x, y, dx, dy);
        self.worldMovePoint(api, x + w, y, dx, dy);
        self.worldMovePoint(api, x, y + h, dx, dy);
        self.worldMovePoint(api, x + w, y + h, dx, dy);
    }

    pub fn worldMovePoint(self: Game, api: *Api.Api, x: f32, y: f32, dx: *f32, dy: *f32) void {
        // Right now we want to see if we can move a single point.
        // We will separate moves into first left and right and then up and down.

        // First attempt to left and right.
        if (dx.* > 0.0 and !self.walkableTile(api, x + dx.*, y)) {
            dx.* = 0.0;
        }
        if (dx.* < 0.0 and !self.walkableTile(api, x + dx.*, y)) {
            dx.* = 0.0;
        }

        // Now update and move right and left.
        if (dy.* > 0.0 and !self.walkableTile(api, x + dx.*, y + dy.*)) {
            dy.* = 0.0;
        }
        if (dy.* < 0.0 and !self.walkableTile(api, x + dx.*, y + dy.*)) {
            dy.* = 0.0;
        }
    }

    fn get_free_bullet_idx(self: *Game) u32 {
        var idx: u32 = 0;

        for (self.bullets) |b| {
            if (b.draw == false) {
                return idx;
            } else if (idx + 1 < NUM_BULLETS) {
                idx += 1;
            } 
        }

        if(self.last_bullet_idx + 1 < 100) {
            self.last_bullet_idx += 1;
        } else {
            self.last_bullet_idx = 0;
        }
        return self.last_bullet_idx;
    }

    fn bullet_collision(bullet: Bullet) bool {
        if (bullet.draw){
            return false;
        }
        return false;
    }

    fn update_bullets(self: *Game) void {
        //TODO: figure out how to copy an array.
        for (self.bullets) |*b, index| {
            if (bullet_collision(self.bullets[index])) {
                b.*.draw = false;
                continue;
            }

            if (b.*.dir == ApiTypes.Direction.RIGHT) {
                b.*.x += BULLET_SPEED;
            } else if (b.*.dir == ApiTypes.Direction.LEFT) {
                b.*.x -= BULLET_SPEED;
            } else if (b.*.dir == ApiTypes.Direction.UP) {
                b.*.y -= BULLET_SPEED;
            } else if (b.*.dir == ApiTypes.Direction.DOWN) {
                b.*.y += BULLET_SPEED;
            }

        }
    }

    pub fn update(self: *Game, api: *Api.Api) void {
        var dx: f32 = 0;
        var dy: f32 = 0;

        self.update_bullets();

        if (api.btn(ApiTypes.Button.RIGHT)) {
            if (api.btn(ApiTypes.Button.A)) {
                self.bullets[self.get_free_bullet_idx()] = Bullet{
                    .x = self.x + BULLET_SPEED,
                    .y = self.y,
                    .dir = ApiTypes.Direction.RIGHT,
                    .draw = true
                };
            }
            dx = 1.0;
        }
        if (api.btn(ApiTypes.Button.LEFT)) {
            if (api.btn(ApiTypes.Button.A)) {
                self.bullets[self.get_free_bullet_idx()] = Bullet{
                    .x = self.x - BULLET_SPEED,
                    .y = self.y,
                    .dir = ApiTypes.Direction.LEFT,
                    .draw = true
                };
            }
            dx = -1.0;
        }
        if (api.btn(ApiTypes.Button.DOWN)) {
            if (api.btn(ApiTypes.Button.A)) {
                self.bullets[self.get_free_bullet_idx()] = Bullet{
                    .x = self.x,
                    .y = self.y + BULLET_SPEED,
                    .dir = ApiTypes.Direction.DOWN,
                    .draw = true
                };
            }
            dy = 1.0;
        }
        if (api.btn(ApiTypes.Button.UP)) {
            if (api.btn(ApiTypes.Button.A)) {
                self.bullets[self.get_free_bullet_idx()] = Bullet{
                    .x = self.x,
                    .y = self.y - BULLET_SPEED,
                    .dir = ApiTypes.Direction.UP,
                    .draw = true
                };
            }
            dy = -1.0;
        }

        // Our game objects are really 7x7 so they can fit into the cracks of the tile.
        self.worldMove(api, self.x, self.y, 7.0, 7.0, &dx, &dy);

        self.x += dx;
        self.y += dy;

        for (self.objects) |*o| {
            var o_dx = (self.rnd.random().float(f32) - 0.5) * 2.0;
            var o_dy = (self.rnd.random().float(f32) - 0.5) * 2.0;

            var target_x = self.x - o.*.x;
            var target_y = self.y - o.*.y;

            const scale = 1.0 / (std.math.sqrt(target_x * target_x + target_y * target_y) + 0.0001);

            o_dx += target_x * scale;
            o_dy += target_y * scale;

            self.worldMove(api, o.*.x, o.*.y, 7.0, 7.0, &o_dx, &o_dy);
            o.*.x += o_dx;
            o.*.y += o_dy;

            if (boxIntersect(self.x, self.y, 8.0, 8.0, o.*.x, o.*.y, 8.0, 8.0)) {
                o.*.spr = 5;
                o.*.draw = false;
            }
        }

        self.randomize_count = (self.randomize_count + 1) % 20;

        // Randomize.

        //if (self.randomize_count == 0) {
        //    self.random_seed = (self.random_seed + 1) % 3;
        //    var rnd = RndGen.init(self.random_seed);

        //    var x: u32 = 0;
        //    var y: u32 = 0;
        //    while (x < 256) {
        //        while (y < 256) {
        //            if (rnd.random().int(u8) % 10 == 0) {
        //                api.mset(x, y, 38 + rnd.random().int(u8) % 4, 1);
        //            } else {
        //                api.mset(x, y, 0, 1);
        //            }
        //            y += 1;
        //        }
        //        x += 1;
        //        y = 0;
        //    }
        //}

        api.camera(self.x - 64 - 4, self.y - 64 - 4);
    }

    pub fn draw(self: *Game, api: *Api.Api) void {
        // draw the map
        api.map(0, 0, 0, 0, 256, 256, 0);

        for (self.objects) |o| {
            if (o.draw) {
                api.spr(o.spr, o.x, o.y, 8.0, 8.0);
            }
        }

        for (self.bullets) |b| {
            if(b.draw) {
                api.spr(b.spr, b.x, b.y, 8.0, 8.0);
            }
        }

        api.spr(self.sprite, self.x, self.y, 8.0, 8.0);

        //api.map(0, 0, 0, 0, 256, 256, 1);
    }
};
