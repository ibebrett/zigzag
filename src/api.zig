const sdl = @import("api_sdl.zig");
const wasm = @import("api_wasm.zig");

pub const Api = wasm.ApiWASM; //sdl.ApiSDL;

//pub const Api = struct {jjjjjjjjjjjj
//    const Self = @This();
//
//    ptr: *anyopaque,
//
//    sprFn: fn (*anyopaque, u32, f32, f32, f32, f32) void,
//    btnpFn: fn (*anyopaque, Button) void,
//    btnFn: fn (*anyopaque, Button) void,
//    cameraFn: fn (*anyopaque, f32, f32) void,
//    mapFn: fn (*anyopaque, u32, u32, f32, f32, u32, u32, u32) void,
//    mset: fn (*anyopaque, u32, u32, u32, u32) void,
//
//    pub fn init(ptr: anytype) Self {
//        const Ptr = @TypeOf(ptr);
//        const ptr_info = @typeInfo(Ptr);
//
//        const alignment = ptr_info.Pointer.alignment;
//
//        const gen = struct {
//            pub fn sprImpl(pointer: *anyopaque, n: u32, x: f32, y: f32, w: f32, h: f32) void {
//                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
//
//                return @call(.{ .modifier = .always_inline }, ptr_info.Pointer.child.spr, .{ self, n, x, y, w, h });
//            }
//
//            pub fn btnpImpl(pointer: *anyopaque, button: Button) bool {
//                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
//
//                return @call(.{ .modifier = .always_inline }, ptr_info.Pointer.child.btnp, .{ self, button });
//            }
//
//            pub fn btnImpl(pointer: *anyopaque, button: Button) bool {
//                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
//
//                return @call(.{ .modifier = .always_inline }, ptr_info.Pointer.child.btn, .{ self, button });
//            }
//
//            pub fn cameraImpl(pointer: *anyopaque, button: Button) bool {
//                const self = @ptrCast(Ptr, @alignCast(alignment, pointer));
//
//                return @call(.{ .modifier = .always_inline }, ptr_info.Pointer.child.btn, .{ self, button });
//            }
//        };
//
//        return .{ .ptr = ptr, .sprFn = gen.sprImpl, .btnpFn = gen.btnpImpl, .btnFn = gen.btnImpl };
//    }
//
//    pub inline fn spr(self: Api, n: u32, x: f32, y: f32, w: f32, h: f32) void {}
//
//    pub inline fn btnp(self: Api, button: Button) bool {}
//
//    pub inline fn btn(self: Api, button: Button) bool {}
//
//    pub inline fn camera(self: *Api, camera_x: f32, camera_y: f32) void {}
//
//    pub inline fn map(self: Api, celx: u32, cely: u32, sx: f32, sy: f32, celw: u32, celh: u32, layer: u32) void {}
//
//    pub inline fn mset(self: *Api, x: u32, y: u32, tile: u8, layer: u32) void {}
//};
//
