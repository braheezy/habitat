//! A small park told through repeating, timed vignettes. update changes the
//! clock; draw turns that clock into positions and frames. Everything drawn
//! points into static strings in park_art.zig, so cells never borrow a local
//! buffer that disappears before vaxis renders them.
const std = @import("std");
const vaxis = @import("vaxis");
const art = @import("park_art.zig");

const cycle_seconds: f32 = 32;
const Story = enum { bird_lands, kitten_stalks, ball_game, nap };

fn storyAt(time: f32) Story {
    if (time < 7) return .bird_lands;
    if (time < 14) return .kitten_stalks;
    if (time < 23) return .ball_game;
    return .nap;
}

pub const Scene = struct {
    random: std.Random.DefaultPrng,
    width: u16 = 0,
    height: u16 = 0,
    time: f32 = 0,
    cloud_offset: f32 = 0,
    coat: u8 = 11,

    pub fn init(seed: u64) Scene {
        return .{ .random = .init(seed) };
    }

    pub fn reset(self: *Scene, width: u16, height: u16) void {
        self.width = width;
        self.height = height;
        self.time = 0;
        self.cloud_offset = 0;
        const coats = [_]u8{ 11, 7, 3, 15 };
        self.coat = coats[self.random.random().uintLessThan(usize, coats.len)];
    }

    pub fn update(self: *Scene, seconds: f32) void {
        self.time = @mod(self.time + seconds, cycle_seconds);
        self.cloud_offset = @mod(self.cloud_offset + seconds * 1.3, @as(f32, @floatFromInt(@as(u32, self.width) + 24)));
    }

    pub fn draw(self: *const Scene, win: vaxis.Window) void {
        win.clear();
        win.hideCursor();
        const w: i32 = win.width;
        const h: i32 = win.height;
        const ground: i32 = @max(0, h - 3);
        const middle: i32 = @divTrunc(w, 2);
        const compact = w < 60 or h < 18;
        const t = self.time;
        const flutter = @as(u32, @intFromFloat(t * 4)) % 2 == 0;
        const bench = if (compact) art.tiny_bench else art.bench;
        const tree = if (compact) art.tiny_tree else art.tree;
        const cat_sit = if (compact) art.tiny_kitten_sit else art.kitten_sit;
        const cat_walk = if (compact)
            (if (flutter) art.tiny_kitten_walk_a else art.tiny_kitten_walk_b)
        else
            (if (flutter) art.kitten_walk_a else art.kitten_walk_b);
        const cat_pounce = if (compact) art.tiny_kitten_pounce else art.kitten_pounce;
        const cat_sleep = if (compact) art.tiny_kitten_sleep else art.kitten_sleep;
        const perched_bird = if (compact) art.tiny_bird_perch else art.bird_perch;
        const cat_width: i32 = if (compact) 6 else 15;
        const perch_offset: i32 = if (compact) 4 else 5;

        sprite(win, art.sun, if (compact) 1 else 3, 0, 11);
        sprite(win, art.cloud, col(@mod(self.cloud_offset, @as(f32, @floatFromInt(w + 12)))) - 8, 1, 15);
        if (!compact) sprite(win, art.cloud, @divTrunc(w * 2, 3) - col(self.cloud_offset * 0.3), 1, 7);
        if (w >= (if (compact) @as(i32, 16) else 28) and h >= (if (compact) @as(i32, 8) else 14))
            sprite(win, tree, w - (if (compact) @as(i32, 10) else 22), ground - (if (compact) @as(i32, 4) else 9), 2);
        if (w >= (if (compact) @as(i32, 14) else 24) and h >= (if (compact) @as(i32, 8) else 14)) {
            sprite(win, bench, 1, ground - (if (compact) @as(i32, 3) else 5), 3);
            sprite(win, cat_sleep, 2, ground - (if (compact) @as(i32, 6) else 9), 7);
        }

        const flying_bird = if (flutter) art.bird_fly_a else art.bird_fly_b;
        const sky_x = col(@mod(t * 6, @as(f32, @floatFromInt(w + 12)))) - 4;
        sprite(win, flying_bird, sky_x, @max(1, @divTrunc(ground, 3)), 14);
        const butterfly_radius: f32 = if (compact) 4 else 9;
        const butterfly = if (compact)
            (if (flutter) art.tiny_butterfly_a else art.tiny_butterfly_b)
        else
            (if (flutter) art.butterfly_a else art.butterfly_b);
        const butterfly_x = middle + col(@sin(t * 0.9) * butterfly_radius);
        const butterfly_y = ground - (if (compact) @as(i32, 4) else 8) + col(@sin(t * 1.8) * 2);
        sprite(win, butterfly, butterfly_x, butterfly_y, 13);

        const kitten_home = middle - @divTrunc(cat_width, 2);
        const perch_x = @min(@max(0, w - 4), middle + perch_offset);
        switch (storyAt(t)) {
            .bird_lands => {
                sprite(win, cat_sit, kitten_home - (if (compact) @as(i32, 2) else 8), ground - (if (compact) @as(i32, 3) else 5), self.coat);
                if (t < 3) {
                    const x = mix(@floatFromInt(w), @floatFromInt(perch_x), t / 3);
                    const y = mix(3, @floatFromInt(ground - (if (compact) @as(i32, 3) else 4)), t / 3);
                    sprite(win, flying_bird, col(x), col(y), 14);
                } else sprite(win, perched_bird, perch_x, ground - (if (compact) @as(i32, 3) else 4), 14);
            },
            .kitten_stalks => {
                const step = t - 7;
                const start_x = @as(f32, @floatFromInt(kitten_home)) - (if (compact) @as(f32, 2) else 8);
                const end_x: f32 = @floatFromInt(middle - 2);
                const cat_x = mix(start_x, end_x, @min(step / 4, 1));
                const kitten = if (step >= 4 and step < 6) cat_pounce else cat_walk;
                sprite(win, kitten, col(cat_x), ground - (if (compact) @as(i32, 3) else 4), self.coat);
                if (step < 3.5) {
                    sprite(win, perched_bird, perch_x, ground - (if (compact) @as(i32, 3) else 4), 14);
                } else {
                    const takeoff = step - 3.5;
                    sprite(win, flying_bird, perch_x + col(takeoff * (if (compact) @as(f32, 3) else 6)), ground - (if (compact) @as(i32, 3) else 4) - col(takeoff * 2), 14);
                }
            },
            .ball_game => {
                const step = t - 14;
                const progress = if (step < 4.5) step / 4.5 else (9 - step) / 4.5;
                const travel: f32 = if (compact) @floatFromInt(@min(@divTrunc(w, 4), 7)) else 20;
                const ball_x = middle - (if (compact) @as(i32, 1) else 2) + col(progress * travel);
                sprite(win, cat_walk, ball_x - (if (compact) @as(i32, 5) else 10), ground - (if (compact) @as(i32, 3) else 4), self.coat);
                sprite(win, art.ball, ball_x, ground - 1, 9);
                if (!compact) sprite(win, perched_bird, w - 19, ground - 13, 14);
            },
            .nap => {
                sprite(win, cat_sleep, if (compact) kitten_home - 2 else kitten_home + 2, ground - (if (compact) @as(i32, 3) else 4), self.coat);
                sprite(win, perched_bird, perch_x, ground - (if (compact) @as(i32, 3) else 4), 14);
                if (flutter) sprite(win, "z", kitten_home + 3, ground - (if (compact) @as(i32, 4) else 6), 7);
            },
        }

        var x: i32 = 1;
        const flower_spacing: i32 = if (compact) 8 else 13;
        while (x < w) : (x += flower_spacing) sprite(win, art.flower, x, ground + 1, 13);
        if (ground + 2 < h) {
            var offset: i32 = 0;
            while (offset < w) : (offset += @intCast(art.grass.len)) sprite(win, art.grass, offset, ground + 2, 2);
        }
    }
};

fn mix(a: f32, b: f32, fraction: f32) f32 {
    return a + (b - a) * std.math.clamp(fraction, 0, 1);
}
fn col(value: f32) i32 {
    return @intFromFloat(@floor(value));
}

// Spaces are transparent so the background shows through each drawing.
fn sprite(win: vaxis.Window, drawing: []const u8, x: i32, y: i32, color: u8) void {
    var rows = std.mem.splitScalar(u8, drawing, '\n');
    var row = y;
    while (rows.next()) |line| : (row += 1) {
        if (row < 0 or row >= win.height) continue;
        for (line, 0..) |byte, i| {
            if (byte == ' ') continue;
            const screen_x = x + @as(i32, @intCast(i));
            if (screen_x < 0 or screen_x >= win.width) continue;
            win.writeCell(@intCast(screen_x), @intCast(row), .{
                .char = .{ .grapheme = line[i..][0..1] },
                .style = .{ .fg = .{ .index = color } },
            });
        }
    }
}

test "stories advance, loop, and restart" {
    var scene = Scene.init(42);
    scene.reset(80, 24);
    try std.testing.expectEqual(Story.bird_lands, storyAt(scene.time));
    scene.update(7);
    try std.testing.expectEqual(Story.kitten_stalks, storyAt(scene.time));
    scene.update(7);
    try std.testing.expectEqual(Story.ball_game, storyAt(scene.time));
    scene.update(9);
    try std.testing.expectEqual(Story.nap, storyAt(scene.time));
    scene.update(9);
    try std.testing.expectEqual(Story.bird_lands, storyAt(scene.time));
    scene.update(10);
    scene.reset(40, 10);
    try std.testing.expectEqual(0, scene.time);
    try std.testing.expectEqual(40, scene.width);
}

test "every vignette draws safely at different terminal sizes" {
    for ([_][2]u16{ .{ 0, 0 }, .{ 1, 1 }, .{ 20, 5 }, .{ 80, 24 }, .{ 160, 60 } }) |size| {
        var screen = try vaxis.Screen.init(std.testing.allocator, .{ .cols = size[0], .rows = size[1], .x_pixel = 0, .y_pixel = 0 });
        defer screen.deinit(std.testing.allocator);
        const win: vaxis.Window = .{ .x_off = 0, .y_off = 0, .parent_x_off = 0, .parent_y_off = 0, .width = size[0], .height = size[1], .screen = &screen };
        var scene = Scene.init(42);
        scene.reset(size[0], size[1]);
        for (0..320) |_| {
            scene.draw(win);
            scene.update(0.1);
        }
    }
}

test "bird lands and takes flight, then the ball and nap appear" {
    var screen = try vaxis.Screen.init(std.testing.allocator, .{ .cols = 80, .rows = 30, .x_pixel = 0, .y_pixel = 0 });
    defer screen.deinit(std.testing.allocator);
    const win: vaxis.Window = .{ .x_off = 0, .y_off = 0, .parent_x_off = 0, .parent_y_off = 0, .width = 80, .height = 30, .screen = &screen };
    var scene = Scene.init(1);
    scene.reset(80, 30);
    scene.time = 4;
    scene.draw(win);
    try std.testing.expectEqualStrings(",", win.readCell(47, 23).?.char.grapheme);
    scene.time = 11.5;
    scene.draw(win);
    try std.testing.expect(!std.mem.eql(u8, ",", win.readCell(47, 23).?.char.grapheme));
    scene.time = 14;
    scene.draw(win);
    try std.testing.expectEqualStrings("@", win.readCell(38, 26).?.char.grapheme);
    scene.time = 24;
    scene.draw(win);
    try std.testing.expectEqualStrings("z", win.readCell(44, 23).?.char.grapheme);
}
