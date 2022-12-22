const builtin = @import("builtin");

const sdl = @import("api_sdl.zig");
const wasm = @import("api_wasm.zig");

pub const Api = switch(builtin.cpu.arch) {
    .wasm32, .wasm64 => wasm.ApiWASM,
    else => sdl.ApiSDL
};