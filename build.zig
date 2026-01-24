const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(sdl_dep.artifact("SDL3"));

    // Add SDL3_gfx source files
    // Use -fwrapv to make signed integer overflow well-defined (wrapping behavior)
    exe.addCSourceFile(.{
        .file = b.path("vendor/sdl3_gfx/SDL3_gfxPrimitives.c"),
        .flags = &.{ "-std=c99", "-fwrapv", "-fno-sanitize=undefined" },
    });
    exe.addCSourceFile(.{
        .file = b.path("vendor/sdl3_gfx/SDL3_rotozoom.c"),
        .flags = &.{ "-std=c99", "-fwrapv", "-fno-sanitize=undefined" },
    });
    exe.addIncludePath(b.path("vendor/sdl3_gfx"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
