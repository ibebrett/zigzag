const sdl = @import("api_sdl.zig");
const wasm = @import("api_wasm.zig");

// TODO: To compile for wasm, set this to the wasm API. To compile for SDL, set this to the SDL api.
pub const Api = wasm.ApiWASM; //sdl.ApiSDL;