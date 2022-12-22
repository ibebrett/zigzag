const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.

    const target = b.standardTargetOptions(.{});

    const installSprites = b.addInstallFile(.{ .path = "assets/sprites.png" }, "bin/sprites.png");

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("game1", "src/main.zig");
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

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    // add a step for wasm
    const wasm = b.addSharedLibrary("wasm", "src/main_wasm.zig", .unversioned);
    wasm.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    wasm.setBuildMode(.ReleaseFast);
    wasm.install();

    const wasm_step = b.step("wasm", "build wasm");
    wasm_step.dependOn(&wasm.step);
}
