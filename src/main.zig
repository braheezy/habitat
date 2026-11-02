const std = @import("std");
const vaxis = @import("vaxis");
const Aquarium = @import("scene.zig").Scene;
const Park = @import("park.zig").Scene;

// Both scenes share the same terminal loop; each owns its own animation state.
const Scene = union(enum) {
    aquarium: Aquarium,
    park: Park,

    fn init(allocator: std.mem.Allocator, seed: u64, options: Options) Scene {
        return if (options.park) .{ .park = Park.init(seed) } else .{ .aquarium = Aquarium.init(allocator, seed, options.classic) };
    }
    fn deinit(self: *Scene) void {
        switch (self.*) {
            .aquarium => |*scene| scene.deinit(),
            .park => {},
        }
    }
    fn reset(self: *Scene, width: u16, height: u16) !void {
        switch (self.*) {
            .aquarium => |*scene| try scene.reset(width, height),
            .park => |*scene| scene.reset(width, height),
        }
    }
    fn update(self: *Scene, seconds: f32) !void {
        switch (self.*) {
            .aquarium => |*scene| try scene.update(seconds),
            .park => |*scene| scene.update(seconds),
        }
    }
    fn draw(self: *const Scene, win: vaxis.Window) void {
        switch (self.*) {
            .aquarium => |*scene| scene.draw(win),
            .park => |*scene| scene.draw(win),
        }
    }
};

// Debug logs written to stderr would land inside the aquarium screen.
pub const std_options: std.Options = .{
    .log_scope_levels = &.{.{ .scope = .vaxis, .level = .warn }},
};

// Let vaxis restore the terminal if a debug assertion or panic fires.
pub const panic = std.debug.FullPanic(restoreAndPanic);
fn restoreAndPanic(message: []const u8, address: ?usize) noreturn {
    vaxis.recover();
    std.debug.defaultPanic(message, address);
}

const usage =
    \\Usage: habitat [-c] [--park]
    \\
    \\  -c          Classic artwork (original fish and sea monster)
    \\  --park      Visit the kitten and bird park
    \\  --help      Show this help
    \\  --version   Show the port version
    \\
    \\Keys: q / Ctrl-C quit, p pause, r recreate scene.
    \\
;

const Options = struct {
    classic: bool = false,
    park: bool = false,
    action: enum { run, help, version } = .run,

    // args excludes the executable name. Parse before opening the terminal,
    // so help and invalid arguments also work when stdout is redirected.
    fn parse(args: []const []const u8) !Options {
        var result: Options = .{};
        var options_done = false;
        for (args) |arg| {
            if (!options_done and std.mem.eql(u8, arg, "--")) {
                options_done = true;
            } else if (!options_done and std.mem.eql(u8, arg, "--help")) {
                result.action = .help;
            } else if (!options_done and std.mem.eql(u8, arg, "--version")) {
                result.action = .version;
            } else if (!options_done and std.mem.eql(u8, arg, "--park")) {
                result.park = true;
            } else if (!options_done and arg.len > 1 and arg[0] == '-' and arg[1] != '-') {
                // Getopt::Std allows repeated/combined short flags: -c -c, -cc.
                for (arg[1..]) |flag| switch (flag) {
                    'c' => result.classic = true,
                    else => return error.UnknownOption,
                };
            } else if (!options_done and std.mem.startsWith(u8, arg, "--")) {
                return error.UnknownOption;
            } else {
                return error.UnexpectedArgument;
            }
        }
        return result;
    }
};

const App = struct {
    paused: bool = false,
    restart: bool = false,
    quit: bool = false,

    fn handleKey(self: *App, key: vaxis.Key) void {
        if (key.matchesAny(&.{ 'q', 'Q' }, .{}) or key.matches('c', .{ .ctrl = true })) {
            self.quit = true;
        } else if (key.matchesAny(&.{ 'p', 'P' }, .{})) {
            self.paused = !self.paused;
        } else if (key.matchesAny(&.{ 'r', 'R' }, .{})) {
            self.restart = true;
        }
    }
};

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const options = Options.parse(args[1..]) catch |err| {
        var buffer: [1024]u8 = undefined;
        var stderr = std.Io.File.Writer.init(.stderr(), init.io, &buffer);
        try stderr.interface.print("habitat: {s}\n{s}", .{ @errorName(err), usage });
        try stderr.interface.flush();
        std.process.exit(2);
    };
    if (options.action != .run) {
        var buffer: [1024]u8 = undefined;
        var stdout = std.Io.File.Writer.init(.stdout(), init.io, &buffer);
        try stdout.interface.writeAll(switch (options.action) {
            .help => usage,
            .version => "habitat 0.0.0 (Zig port of Asciiquarium 1.1)\n",
            .run => unreachable,
        });
        try stdout.interface.flush();
        return;
    }
    try run(init, options);
}

fn run(init: std.process.Init, options: Options) !void {
    const io = init.io;
    const allocator = init.gpa;
    // tty owns raw terminal mode and its output buffer. Vaxis owns the cell
    // grids. Defers run in reverse order: stop input, restore vaxis, close tty.
    var tty_buffer: [4096]u8 = undefined;
    var tty = try vaxis.Tty.init(io, &tty_buffer);
    defer tty.deinit();
    var vx = try vaxis.init(io, allocator, init.environ_map, .{});
    defer vx.deinit(allocator, tty.writer());

    const Event = union(enum) { key_press: vaxis.Key, winsize: vaxis.Winsize };
    var loop: vaxis.Loop(Event) = .init(io, &tty, &vx);
    try loop.start();
    defer loop.stop();
    try vx.enterAltScreen(tty.writer());
    try vx.queryTerminal(tty.writer(), .fromSeconds(1));
    // Modern terminals report resize events in-band; others need SIGWINCH.
    if (!vx.state.in_band_resize) try loop.installResizeHandler();
    defer loop.uninstallResizeHandler();
    try vx.resize(allocator, tty.writer(), try tty.getWinsize());

    var app: App = .{};
    var seed: u64 = undefined;
    io.random(std.mem.asBytes(&seed));
    var scene = Scene.init(allocator, seed, options);
    defer scene.deinit();
    try scene.reset(vx.window().width, vx.window().height);
    const frame_interval: std.Io.Duration = .fromMilliseconds(100);
    var next_frame = std.Io.Timestamp.now(io, .awake);
    var previous_frame = next_frame;
    while (!app.quit) {
        // Bound the batch so a stream of input cannot prevent a frame.
        for (0..512) |_| {
            const event = try loop.tryEvent() orelse break;
            switch (event) {
                .key_press => |key| app.handleKey(key),
                .winsize => |size| {
                    try vx.resize(allocator, tty.writer(), size);
                    app.restart = true;
                },
            }
        }
        if (app.quit) break;
        const frame_time = std.Io.Timestamp.now(io, .awake);
        if (app.restart) {
            vx.queueRefresh();
            try scene.reset(vx.window().width, vx.window().height);
            app.restart = false;
        } else if (!app.paused) {
            // Bound stalls rather than jumping through the whole aquarium.
            const elapsed = previous_frame.durationTo(frame_time).nanoseconds;
            const seconds = @as(f32, @floatFromInt(@max(0, elapsed))) / std.time.ns_per_s;
            try scene.update(@min(seconds, 0.25));
        }
        previous_frame = frame_time;
        scene.draw(vx.window());
        try vx.render(tty.writer());
        try tty.writer().flush();

        next_frame = next_frame.addDuration(frame_interval);
        const now = std.Io.Timestamp.now(io, .awake);
        const remaining = now.durationTo(next_frame);
        if (remaining.nanoseconds > 0) {
            try io.sleep(remaining, .awake);
        } else {
            // Avoid a burst of catch-up frames after a slow render or resize.
            next_frame = now;
        }
    }
}

test "options: default, classic, repeated flags and non-terminal actions" {
    try std.testing.expect(!(try Options.parse(&.{})).classic);
    try std.testing.expect((try Options.parse(&.{"-c"})).classic);
    try std.testing.expect((try Options.parse(&.{"--park"})).park);
    try std.testing.expect((try Options.parse(&.{ "-cc", "-c", "--" })).classic);
    try std.testing.expectEqual(.help, (try Options.parse(&.{"--help"})).action);
    try std.testing.expectEqual(.version, (try Options.parse(&.{"--version"})).action);
    try std.testing.expectError(error.UnknownOption, Options.parse(&.{"-x"}));
    try std.testing.expectError(error.UnknownOption, Options.parse(&.{"--classic"}));
    try std.testing.expectError(error.UnexpectedArgument, Options.parse(&.{ "--", "-c" }));
    try std.testing.expectError(error.UnexpectedArgument, Options.parse(&.{"fish"}));
}

test "keys: pause toggles, restart preserves pause, quit" {
    var app: App = .{};
    app.handleKey(.{ .codepoint = 'p' });
    try std.testing.expect(app.paused);
    app.handleKey(.{ .codepoint = 'R' });
    try std.testing.expect(app.paused);
    try std.testing.expect(app.restart);
    app.handleKey(.{ .codepoint = 'P' });
    try std.testing.expect(!app.paused);
    app.handleKey(.{ .codepoint = 'c', .mods = .{ .ctrl = true } });
    try std.testing.expect(app.quit);
}

test {
    _ = @import("scene.zig");
    _ = @import("park.zig");
}
