const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const build_native = b.option(bool, "native", "Build the native executable.") orelse false;
    const build_wasm = b.option(bool, "wasm", "Build the wasm library.") orelse false;

    if (build_native) {
        const installSprites = b.addInstallFile(.{ .path = "assets/sprites.png" }, "bin/sprites.png");

        // Standard release options allow the person running `zig build` to select
        // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
        const exe = b.addExecutable("game1", "src/main_sdl.zig");

        exe.addLibraryPath("SDL2-devel-2.26.1-VC/SDL2-2.26.1/lib/x64");
        exe.addIncludePath("SDL2-devel-2.26.1-VC/SDL2-2.26.1/include");
        exe.addLibraryPath("SDL2_image-devel-2.6.2-VC/SDL2_image-2.6.2/lib/x64");
        exe.addIncludePath("SDL2_image-devel-2.6.2-VC/SDL2_image-2.6.2/include");

        const installSDLImageDLL = b.addInstallFile(.{ .path = "SDL2_image-devel-2.6.2-VC/SDL2_image-2.6.2/lib/x64/SDL2_image.dll" }, "bin/SDL2_image.dll");
        const installSDLDLL = b.addInstallFile(.{ .path = "SDL2-devel-2.26.1-VC/SDL2-2.26.1/lib/x64/SDL2.dll" }, "bin/SDL2.dll");

        exe.linkLibC();
        exe.linkSystemLibraryName("SDL2");
        exe.linkSystemLibraryName("SDL2_image");

        exe.setTarget(target);
        exe.setBuildMode(mode);

        exe.install();

        exe.step.dependOn(&installSDLImageDLL.step);
        exe.step.dependOn(&installSDLDLL.step);
        exe.step.dependOn(&installSprites.step);
    }

    // add a step for wasm
    if (build_wasm) {
        const wasm = b.addSharedLibrary("wasm", "src/main_wasm.zig", .unversioned);

        wasm.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
        wasm.setBuildMode(.ReleaseFast);

        wasm.install();
        const wasm_step = b.step("wasm", "build wasm");
        wasm_step.dependOn(&wasm.step);
    }
}
