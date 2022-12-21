const std = @import("std");

const Api = @import("api_wasm.zig");
const Game = @import("game.zig").Game;
const assert = std.debug.assert;

var api: Api.ApiWASM =  undefined; 
var game: Game = undefined; 

export fn setup() void {
    api = Api.ApiWASM.init();
    game = Game.init(&api);
    //game.init(&api);
}

export fn loop() void {
    game.update(&api);
    game.draw(&api);
    //api.spr(1, 10, 10, 10, 10);
}
