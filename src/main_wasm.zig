const std = @import("std");

const Api = @import("api_wasm.zig");
const Game = @import("game.zig").Game;
const assert = std.debug.assert;

var api: Api.ApiWASM = undefined;
var game: Game = undefined;

export fn setup() void {
    api = Api.ApiWASM.init();
    game = Game.init(&api);
}

export fn loop(right_down: bool, right_pressed: bool, up_down: bool, up_pressed: bool, down_down: bool, down_pressed: bool, left_down: bool, left_pressed: bool, a_down: bool, a_pressed: bool, b_down: bool, b_pressed: bool) void {
    var input_state: Api.InputState = .{};
    input_state.right_down = right_down;
    input_state.right_pressed = right_pressed;
    input_state.up_down = up_down;
    input_state.up_pressed = up_pressed;
    input_state.left_down = left_down;
    input_state.left_pressed = left_pressed;
    input_state.down_down = down_down;
    input_state.down_pressed = down_pressed;
    input_state.a_down = a_down;
    input_state.a_pressed = a_pressed;
    input_state.b_down = b_down;
    input_state.b_pressed = b_pressed;

    api.update_input(input_state);

    game.update(&api);
    game.draw(&api);
}
