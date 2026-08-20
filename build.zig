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
    const sdl_lib = sdl_dep.artifact("SDL3");

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/sdl_headers.c"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.addIncludePath(sdl_lib.getEmittedIncludeTree());

    exe.root_module.linkLibrary(sdl_lib);
    exe.root_module.addImport("c", translate_c.createModule());

    // Add analog-vectors module
    const vectors_dep = b.dependency("vectors", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("vectors", vectors_dep.module("vectors"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const ecs_test_module = b.createModule(.{
        .root_source_file = b.path("src/ecs/ecs.zig"),
        .target = target,
        .optimize = optimize,
    });
    const ecs_tests = b.addTest(.{ .root_module = ecs_test_module });
    const run_ecs_tests = b.addRunArtifact(ecs_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_ecs_tests.step);
}
