const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{ .linkage = std.builtin.LinkMode.static, .name = "lib", .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    }) });

    const eigen3_dep = b.dependency("eigen", .{});
    lib.addIncludePath(eigen3_dep.path("."));

    lib.addCSourceFiles(.{ .files = &.{"lib/lib.cpp"} });
    lib.addIncludePath(b.path("include"));
    lib.linkLibC();
    if (target.query.abi != std.Target.Abi.msvc) {
        lib.linkLibCpp();
    }
    lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ "h", "hpp" },
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(eigen3_dep.path("."));

    exe.addCSourceFiles(.{ .files = &.{"example/main.cpp"} });
    exe.linkLibrary(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run example");
    run_step.dependOn(&run_cmd.step);

    const googletest_dep = b.dependency("googletest", .{});

    const gtest = b.addLibrary(.{ .linkage = std.builtin.LinkMode.static, .name = "gtest", .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    }) });
    gtest.linkLibC();
    if (target.query.abi != std.Target.Abi.msvc) {
        gtest.linkLibCpp();
    }
    gtest.addCSourceFile(.{
        .file = googletest_dep.path("googletest/src/gtest-all.cc"),
    });
    gtest.addIncludePath(googletest_dep.path("googletest/include"));
    gtest.addIncludePath(googletest_dep.path("googletest"));
    gtest.installHeadersDirectory(googletest_dep.path("googletest/include"), ".", .{});

    const gtest_main = b.addLibrary(.{ .linkage = std.builtin.LinkMode.static, .name = "gtest_main", .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    }) });
    gtest_main.linkLibC();
    if (target.query.abi != std.Target.Abi.msvc) {
        gtest_main.linkLibCpp();
    }
    gtest_main.addCSourceFile(.{
        .file = googletest_dep.path("googletest/src/gtest_main.cc"),
    });
    gtest_main.addIncludePath(googletest_dep.path("googletest/include"));
    gtest_main.addIncludePath(googletest_dep.path("googletest"));
    gtest_main.installHeadersDirectory(googletest_dep.path("googletest/include"), ".", .{});

    const exe_tests = b.addExecutable(.{
        .name = "test",
        .target = target,
        .optimize = optimize,
    });
    exe_tests.addCSourceFiles(.{ .files = &.{ "tests/main.cpp", "tests/test.cpp" } });
    exe_tests.linkLibrary(lib);
    exe_tests.linkLibrary(gtest);
    exe_tests.linkLibrary(gtest_main);
    exe_tests.addIncludePath(eigen3_dep.path("."));

    const run_test_cmd = b.addRunArtifact(exe_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_test_cmd.step);
}
