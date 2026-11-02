//! Aquarium simulation. This module has no terminal I/O: update advances time,
//! and draw describes the current frame using borrowed, static ASCII strings.
const std = @import("std");
const vaxis = @import("vaxis");
const art = @import("art.zig");
const Allocator = std.mem.Allocator;

const Palette = [10]u8;
const default_palette: Palette = .{ 7, 6, 14, 3, 15, 9, 5, 11, 2, 13 };
const Fish = struct {
    sprite: art.Sprite,
    palette: Palette,
    x: f32,
    y: i32,
    velocity: f32,
    depth: u8,
};
const Plant = struct { x: i32, height: u8, age: f32 = 0, lifetime: f32, period: f32 };
const Bubble = struct { x: i32, y: f32, age: f32 = 0, depth: u8 = 2 };
const Splat = struct { x: i32, y: i32, age: f32 = 0 };
const VisitorKind = enum { ship, whale, monster, big_fish, shark, mini_ship, mini_whale };
const Visitor = struct {
    kind: VisitorKind,
    x: f32,
    y: i32,
    left: bool,
    speed: f32,
    age: f32 = 0,
    alternate: bool = false,
    palette: Palette,
};

// Width and height are classified independently: a short, wide pane still
// has room for more fish, while a tall, narrow pane keeps its deep water.
const Layout = struct {
    narrow: bool,
    short: bool,
    surface_y: u16,
    water_rows: u16,
    underwater_y: u16,

    fn init(width: u16, height: u16) Layout {
        // The original surface plus castle needs 9 + 13 rows.
        const short = height < 22;
        const surface_y: u16 = if (short) @min(2, height) else 5;
        const rows: u16 = if (short) @min(1, height -| surface_y) else 4;
        return .{ .narrow = width < 60, .short = short, .surface_y = surface_y, .water_rows = rows, .underwater_y = surface_y + rows };
    }
};

// Compact scenery for panes where the original 32-by-13 castle would occupy
// most of the aquarium. This is drawn as a separate sprite, never rescaled.
const compact_castle: art.Sprite = .{ .image =
    \\    |~
    \\   /\
    \\ _/  \_
    \\|_|[]|_|
    \\|__||__|
, .mask =
    \\     R
    \\   yy
    \\  y  y
    \\
    \\
};
const mini_ship = "  |\n /|\\\n\\___/";
const mini_whale = "  .\n_(__)\n\\__o>";

pub const Scene = struct {
    allocator: Allocator,
    prng: std.Random.DefaultPrng,
    classic: bool,
    width: u16 = 0,
    height: u16 = 0,
    layout: Layout = Layout.init(0, 0),
    fish: std.ArrayList(Fish) = .empty,
    plants: std.ArrayList(Plant) = .empty,
    bubbles: std.ArrayList(Bubble) = .empty,
    splats: std.ArrayList(Splat) = .empty,
    visitor: ?Visitor = null,

    pub fn init(allocator: Allocator, seed: u64, classic: bool) Scene {
        return .{ .allocator = allocator, .prng = .init(seed), .classic = classic };
    }

    pub fn deinit(self: *Scene) void {
        self.fish.deinit(self.allocator);
        self.plants.deinit(self.allocator);
        self.bubbles.deinit(self.allocator);
        self.splats.deinit(self.allocator);
    }

    // Retain list capacities on restart. Allocation failures propagate to main,
    // whose defers still restore the terminal and release all scene storage.
    pub fn reset(self: *Scene, width: u16, height: u16) !void {
        self.width = width;
        self.height = height;
        self.layout = Layout.init(width, height);
        self.fish.clearRetainingCapacity();
        self.plants.clearRetainingCapacity();
        self.bubbles.clearRetainingCapacity();
        self.splats.clearRetainingCapacity();
        self.visitor = null;
        if (width == 0 or height == 0) return;
        const water_height = height -| self.layout.underwater_y;
        const compact = self.layout.short or self.layout.narrow;
        const area = @as(usize, water_height) * width;
        const compact_count = @min(@as(usize, width) / 10, area / 180);
        const count = if (compact)
            (if (width >= 12 and water_height >= 3) @max(1, compact_count) else compact_count)
        else
            area / 350;
        for (0..count) |i| {
            var fish = self.spawnFish() orelse break;
            // Distribute the initial population; later fish enter at an edge.
            const fish_width: usize = @intCast(dimensions(fish.sprite.image).width);
            const max_x = @as(usize, width) - fish_width;
            fish.x = @floatFromInt(@min(max_x, (i * @as(usize, width) + width / 4) / count));
            try self.fish.append(self.allocator, fish);
        }
        if (water_height >= 3) {
            for (0..width / 15) |_| try self.plants.append(self.allocator, self.spawnPlant());
        }
        if (width >= 8 and self.layout.water_rows > 0) self.visitor = self.spawnVisitor();
    }

    fn range(self: *Scene, min: f32, max: f32) f32 {
        return min + self.prng.random().float(f32) * @max(0, max - min);
    }

    fn choose(self: *Scene, count: usize) usize {
        return self.prng.random().uintLessThan(usize, count);
    }

    fn palette(self: *Scene) Palette {
        const colors = [_]u8{ 6, 14, 1, 9, 3, 11, 4, 12, 2, 10, 5, 13 };
        var result = default_palette;
        for (result[1..]) |*color| color.* = colors[self.choose(colors.len)];
        return result;
    }

    fn spawnFish(self: *Scene) ?Fish {
        const sprites: []const art.Sprite = if (!self.classic and self.choose(12) > 8) &art.new_fish else &art.classic_fish;
        return self.chooseFish(sprites) orelse if (sprites.ptr != art.classic_fish[0..].ptr) self.chooseFish(&art.classic_fish) else null;
    }

    fn chooseFish(self: *Scene, sprites: []const art.Sprite) ?Fish {
        // Select only drawings that fit entirely in the water. Preserve pairs
        // in their original order, where even faces right and odd faces left.
        const water_height: i32 = self.height -| self.layout.underwater_y;
        const max_height: i32 = if (self.layout.short) @min(3, water_height) else water_height;
        const max_width: i32 = if (self.layout.narrow) @max(1, @divTrunc(@as(i32, self.width), 3)) else self.width;
        var candidates: [32]usize = undefined;
        var count: usize = 0;
        for (sprites, 0..) |candidate, i| {
            const size = dimensions(candidate.image);
            if (size.width <= max_width and size.height <= max_height) {
                candidates[count] = i;
                count += 1;
            }
        }
        // The newer collection has no small fish. Fall back to the original
        // collection when a small viewport cannot fit any of its sprites.
        if (count == 0) return null;
        return self.makeFish(sprites, candidates[self.choose(count)]);
    }

    fn makeFish(self: *Scene, sprites: []const art.Sprite, index: usize) Fish {
        const sprite = sprites[index];
        const size = dimensions(sprite.image);
        const left = index % 2 == 1;
        var colors = self.palette();
        colors[4] = 15; // Eyes stay bright white, regardless of body colors.
        return .{
            .sprite = sprite,
            .palette = colors,
            .x = if (left) @as(f32, @floatFromInt(self.width)) - 2 else 1 - @as(f32, @floatFromInt(size.width)),
            .y = @intFromFloat(self.range(@floatFromInt(self.layout.underwater_y), @floatFromInt(@as(i32, self.height) - size.height + 1))),
            .velocity = self.range(2.5, if (self.layout.narrow) 12 else 22.5) * (if (left) @as(f32, -1) else 1),
            .depth = @intCast(3 + self.choose(17)),
        };
    }

    fn spawnPlant(self: *Scene) Plant {
        return .{
            .x = @intFromFloat(self.range(1, @floatFromInt(if (self.layout.narrow) self.width / 2 else self.width -| 2))),
            .height = @intCast(3 + self.choose(@min(@as(usize, 4), @as(usize, self.height -| self.layout.underwater_y) - 2))),
            .lifetime = self.range(480, 720),
            .period = self.range(0.25, 0.30),
        };
    }

    fn spawnVisitor(self: *Scene) Visitor {
        var candidates: [5]VisitorKind = undefined;
        var count: usize = 2;
        if (self.layout.short or self.width < 30) {
            candidates[0] = .mini_ship;
            candidates[1] = .mini_whale;
        } else {
            candidates[0] = .ship;
            candidates[1] = .whale;
            const water_height = self.height -| self.layout.underwater_y;
            if (!self.layout.narrow and self.width >= 70) {
                candidates[count] = .monster;
                count += 1;
            }
            if (!self.layout.narrow and water_height >= 15) {
                candidates[count] = .big_fish;
                count += 1;
            }
            if (!self.layout.narrow and water_height >= 10) {
                candidates[count] = .shark;
                count += 1;
            }
        }
        const kind = candidates[self.choose(count)];
        var visitor: Visitor = .{
            .kind = kind,
            .left = self.choose(2) == 1,
            .x = 0,
            .y = 0,
            .speed = 10,
            .palette = self.palette(),
            .alternate = !self.classic and self.choose(3) == 2,
        };
        switch (kind) {
            .ship, .whale => {},
            .mini_ship, .mini_whale => visitor.y = @as(i32, self.layout.surface_y) - 2,
            .monster => {
                visitor.y = 2;
                visitor.speed = 20;
            },
            .big_fish => {
                visitor.speed = if (visitor.alternate) 25 else 30;
                visitor.y = @intFromFloat(self.range(9, @floatFromInt(@as(i32, self.height) - 15)));
            },
            .shark => {
                visitor.speed = 20;
                visitor.y = @intFromFloat(self.range(9, @floatFromInt(@as(i32, self.height) - 19)));
            },
        }
        visitor.x = if (visitor.left) @floatFromInt(self.width -| 2) else -@as(f32, @floatFromInt(visitorWidth(visitor, self.classic)));
        return visitor;
    }

    pub fn update(self: *Scene, seconds: f32) !void {
        // Main bounds elapsed time after slow terminal operations. No updates
        // run while paused, so lifetimes and frame selection freeze together.
        for (self.plants.items) |*plant| {
            plant.age += seconds;
            if (plant.age >= plant.lifetime) plant.* = self.spawnPlant();
        }
        for (self.fish.items) |*fish| {
            fish.x += fish.velocity * seconds;
            if (offscreen(fish.x, dimensions(fish.sprite.image).width, self.width, fish.velocity < 0)) {
                fish.* = self.spawnFish() orelse continue;
            }
            // Original chance was 2% per 100 ms update. Scale it with time.
            if (self.range(0, 1) < 1 - std.math.pow(f32, 0.98, seconds * 10)) {
                const size = dimensions(fish.sprite.image);
                try self.bubbles.append(self.allocator, .{
                    .x = column(fish.x) + (if (fish.velocity > 0) size.width else @as(i32, 0)),
                    .y = @floatFromInt(fish.y + @divTrunc(size.height, 2)),
                    .depth = fish.depth - 1,
                });
            }
        }
        var i: usize = 0;
        while (i < self.bubbles.items.len) {
            const bubble = &self.bubbles.items[i];
            const previous_y = bubble.y;
            bubble.y -= seconds * 10;
            bubble.age += seconds;
            if (bubble.y < 0 or bubble.x < 0 or bubble.x >= self.width or hitsWaterline(self.layout, bubble.x, previous_y, bubble.y)) {
                _ = self.bubbles.swapRemove(i);
            } else i += 1;
        }
        i = 0;
        while (i < self.splats.items.len) {
            self.splats.items[i].age += seconds;
            if (self.splats.items[i].age >= 1.5) {
                _ = self.splats.swapRemove(i);
            } else i += 1;
        }
        if (self.visitor) |*visitor| {
            visitor.age += seconds;
            visitor.x += seconds * visitor.speed * (if (visitor.left) @as(f32, -1) else 1);
            if (visitor.kind == .shark) {
                // The original has a separate invisible teeth entity. A mouth
                // rectangle covers its swept path, avoiding missed fast bites.
                const mouth_x = visitor.x + (if (visitor.left) @as(f32, 9) else @as(f32, 44));
                const mouth_y = visitor.y + 7;
                const sweep = visitor.speed * seconds;
                for (self.fish.items) |*fish| {
                    const size = dimensions(fish.sprite.image);
                    if (size.height > 5) continue;
                    if (mouth_x + sweep >= fish.x and mouth_x - sweep < fish.x + @as(f32, @floatFromInt(size.width)) and mouth_y >= fish.y and mouth_y < fish.y + size.height) {
                        try self.splats.append(self.allocator, .{ .x = column(mouth_x) - 4, .y = mouth_y - 2 });
                        fish.* = self.spawnFish() orelse continue;
                    }
                }
            }
            if (offscreen(visitor.x, visitorWidth(visitor.*, self.classic), self.width, visitor.left)) {
                self.visitor = self.spawnVisitor();
            }
        }
    }

    pub fn draw(self: *const Scene, win: vaxis.Window) void {
        win.clear();
        win.hideCursor();
        if (self.layout.narrow or self.layout.short) {
            if (win.width >= 20 and win.height -| self.layout.underwater_y >= 5)
                drawSprite(win, compact_castle, @as(i32, win.width) - 10, @as(i32, win.height) - 5, .{ .default_color = 8 });
        } else {
            drawSprite(win, art.castle, @as(i32, win.width) - 32, @as(i32, win.height) - 13, .{ .default_color = 8 });
        }
        for (self.plants.items) |plant| {
            const frame = frameIndex(plant.age, plant.period, art.seaweed.len);
            drawSprite(win, .{ .image = rowsPrefix(art.seaweed[frame], plant.height) }, plant.x, @as(i32, win.height) - plant.height, .{ .default_color = 2 });
        }
        var depth: u8 = 20;
        while (depth > 2) {
            depth -= 1;
            for (self.fish.items) |fish| {
                if (fish.depth == depth) drawSprite(win, fish.sprite, column(fish.x), fish.y, .{ .palette = fish.palette });
            }
            for (self.bubbles.items) |bubble| {
                if (bubble.depth != depth) continue;
                const index = @min(@as(usize, @intFromFloat(bubble.age / 0.1)), art.bubbles.len - 1);
                drawSprite(win, .{ .image = art.bubbles[index] }, bubble.x, column(bubble.y), .{ .default_color = 14 });
            }
        }
        if (self.visitor) |visitor| if (visitor.kind == .shark or visitor.kind == .big_fish) self.drawVisitor(win, visitor);
        for (self.splats.items) |splat| {
            const index = @min(@as(usize, @intFromFloat(splat.age / 0.25)), art.splat.len - 1);
            drawSprite(win, .{ .image = art.splat[index] }, splat.x, splat.y, .{ .default_color = 9, .transparent_spaces = true });
        }
        drawWaterline(win, self.layout, 0);
        drawWaterline(win, self.layout, 1);
        if (self.visitor) |visitor| if (visitor.kind == .ship) self.drawVisitor(win, visitor);
        drawWaterline(win, self.layout, 2);
        if (self.visitor) |visitor| if (visitor.kind == .whale or visitor.kind == .monster) self.drawVisitor(win, visitor);
        if (self.visitor) |visitor| if (visitor.kind == .mini_ship or visitor.kind == .mini_whale) self.drawVisitor(win, visitor);
        drawWaterline(win, self.layout, 3);
    }

    fn drawVisitor(self: *const Scene, win: vaxis.Window, visitor: Visitor) void {
        const direction: usize = @intFromBool(visitor.left);
        const x = column(visitor.x);
        switch (visitor.kind) {
            .ship => drawSprite(win, art.ship[direction], x, visitor.y, .{}),
            .shark => drawSprite(win, art.shark[direction], x, visitor.y, .{ .default_color = 14 }),
            .mini_ship => drawSprite(win, .{ .image = mini_ship }, x, visitor.y, .{ .default_color = 11 }),
            .mini_whale => drawSprite(win, .{ .image = mini_whale }, x, visitor.y, .{ .default_color = 14 }),
            .big_fish => {
                const sprites = if (visitor.alternate) &art.new_big_fish else &art.classic_big_fish;
                drawSprite(win, sprites[direction], x, visitor.y, .{ .palette = visitor.palette, .default_color = 11 });
            },
            .monster => {
                const frames = monsterFrames(self.classic, visitor.left);
                const masks = if (self.classic) &art.classic_monster_masks else &art.new_monster_masks;
                drawSprite(win, .{ .image = frames[frameIndex(visitor.age, 0.25, frames.len)], .mask = masks[direction] }, x, visitor.y, .{ .default_color = 10 });
            },
            .whale => {
                // Masks have three spout rows before their body rows. Slice
                // those off for the body, and reuse them for the spout colors.
                const body_mask = skipRows(imageBody(art.whale[direction].mask), 3);
                drawSprite(win, .{ .image = art.whale[direction].image, .mask = body_mask }, x, visitor.y + 3, .{ .default_color = 12 });
                const frame = frameIndex(visitor.age, 0.1, 12);
                if (frame >= 5) {
                    drawSprite(win, .{ .image = art.water_spout[frame - 5] }, x + (if (visitor.left) @as(i32, 1) else 11), visitor.y, .{ .default_color = 14, .transparent_spaces = true });
                }
            },
        }
    }
};

fn monsterFrames(classic: bool, left: bool) []const []const u8 {
    if (classic) return if (left) &art.classic_monster_left else &art.classic_monster_right;
    return if (left) &art.new_monster_left else &art.new_monster_right;
}

fn visitorWidth(visitor: Visitor, classic: bool) i32 {
    const direction: usize = @intFromBool(visitor.left);
    return dimensions(switch (visitor.kind) {
        .ship => art.ship[direction].image,
        .whale => art.whale[direction].image,
        .monster => monsterFrames(classic, visitor.left)[0],
        .big_fish => if (visitor.alternate) art.new_big_fish[direction].image else art.classic_big_fish[direction].image,
        .shark => art.shark[direction].image,
        .mini_ship => mini_ship,
        .mini_whale => mini_whale,
    }).width;
}

fn offscreen(x: f32, width: i32, screen_width: u16, left: bool) bool {
    return if (left) x + @as(f32, @floatFromInt(width)) < 0 else x >= @as(f32, @floatFromInt(screen_width));
}
fn column(x: f32) i32 {
    return @intFromFloat(@floor(x));
}
fn frameIndex(age: f32, period: f32, count: usize) usize {
    return @as(usize, @intFromFloat(@floor(age / period))) % count;
}
fn imageBody(image: []const u8) []const u8 {
    return if (std.mem.startsWith(u8, image, "\n")) image[1..] else image;
}
fn skipRows(image: []const u8, count: usize) []const u8 {
    var rest = image;
    for (0..count) |_| {
        const end = std.mem.indexOfScalar(u8, rest, '\n') orelse return "";
        rest = rest[end + 1 ..];
    }
    return rest;
}
fn rowsPrefix(image: []const u8, count: usize) []const u8 {
    const rest = skipRows(image, count);
    return image[0 .. image.len - rest.len];
}
fn dimensions(image: []const u8) struct { width: i32, height: i32 } {
    var rows = std.mem.splitScalar(u8, std.mem.trimEnd(u8, imageBody(image), "\n"), '\n');
    var width: usize = 0;
    var height: i32 = 0;
    while (rows.next()) |row| {
        width = @max(width, row.len);
        height += 1;
    }
    return .{ .width = @intCast(width), .height = height };
}

const DrawOptions = struct { palette: Palette = default_palette, default_color: u8 = 7, transparent_spaces: bool = false };
fn maskColor(code: u8, options: DrawOptions) u8 {
    if (code >= '1' and code <= '9') return options.palette[code - '0'];
    return switch (code) {
        'k' => 0,
        'r' => 1,
        'g' => 2,
        'y' => 3,
        'b' => 4,
        'm' => 5,
        'c' => 6,
        'w' => 7,
        'K' => 8,
        'R' => 9,
        'G' => 10,
        'Y' => 11,
        'B' => 12,
        'M' => 13,
        'C' => 14,
        'W' => 15,
        else => options.default_color,
    };
}

// Terminal cells borrow these slices until render completes. Every slice here
// points into static art, so no temporary formatting buffer can dangle.
fn drawSprite(win: vaxis.Window, sprite: art.Sprite, x: i32, y: i32, options: DrawOptions) void {
    var rows = std.mem.splitScalar(u8, imageBody(sprite.image), '\n');
    var masks = std.mem.splitScalar(u8, imageBody(sprite.mask), '\n');
    var row = y;
    while (rows.next()) |line| : (row += 1) {
        const mask = masks.next() orelse "";
        if (row < 0 or row >= win.height) continue;
        const start = std.mem.indexOfNone(u8, line, " ") orelse continue;
        const end = std.mem.trimEnd(u8, line, " ").len;
        for (line[start..end], start..) |byte, col| {
            if (byte == '?' or (options.transparent_spaces and byte == ' ')) continue;
            const screen_col = x + @as(i32, @intCast(col));
            if (screen_col < 0 or screen_col >= win.width) continue;
            win.writeCell(@intCast(screen_col), @intCast(row), .{
                .char = .{ .grapheme = line[col..][0..1] },
                .style = .{ .fg = .{ .index = maskColor(if (col < mask.len) mask[col] else ' ', options) } },
            });
        }
    }
}
// Test every row crossed this update, including holes in the wave pattern.
fn hitsWaterline(layout: Layout, x: i32, previous_y: f32, y: f32) bool {
    if (x < 0) return false;
    for (art.waterline, 0..) |line, index| {
        if (index >= layout.water_rows) break;
        const row: f32 = @floatFromInt(index + layout.surface_y);
        if (y < row + 1 and previous_y >= row and line[@as(usize, @intCast(x)) % line.len] != ' ') return true;
    }
    return false;
}

fn drawWaterline(win: vaxis.Window, layout: Layout, row: u16) void {
    if (row >= layout.water_rows) return;
    const line = art.waterline[row];
    for (0..win.width) |col| {
        const byte = line[col % line.len ..][0..1];
        if (byte[0] == ' ') continue;
        win.writeCell(@intCast(col), row + layout.surface_y, .{ .char = .{ .grapheme = byte }, .style = .{ .fg = .{ .index = 6 } } });
    }
}

fn testWindow(screen: *vaxis.Screen) vaxis.Window {
    return .{ .x_off = 0, .y_off = 0, .parent_x_off = 0, .parent_y_off = 0, .width = screen.width, .height = screen.height, .screen = screen };
}

test "sprite clipping, transparency and mask alignment" {
    var screen = try vaxis.Screen.init(std.testing.allocator, .{ .cols = 3, .rows = 2, .x_pixel = 0, .y_pixel = 0 });
    defer screen.deinit(std.testing.allocator);
    const win = testWindow(&screen);
    win.fill(.{ .char = .{ .grapheme = "." } });
    drawSprite(win, .{ .image = "\nignored\nAB?\n C!\n", .mask = "\n\nrgW\n Y\n" }, -1, -1, .{});
    try std.testing.expectEqualStrings("B", win.readCell(0, 0).?.char.grapheme);
    try std.testing.expectEqual(2, win.readCell(0, 0).?.style.fg.index);
    try std.testing.expectEqualStrings(".", win.readCell(1, 0).?.char.grapheme);
    try std.testing.expectEqualStrings("C", win.readCell(0, 1).?.char.grapheme);
    try std.testing.expectEqual(11, win.readCell(0, 1).?.style.fg.index);
}

test "movement and offscreen replacement preserve population" {
    var scene = Scene.init(std.testing.allocator, 42, true);
    defer scene.deinit();
    try scene.reset(80, 24);
    try std.testing.expectEqual(3, scene.fish.items.len);
    const old_x = scene.fish.items[0].x;
    const velocity = scene.fish.items[0].velocity;
    try scene.update(0.01);
    try std.testing.expectApproxEqAbs(old_x + velocity * 0.01, scene.fish.items[0].x, 0.001);
    scene.fish.items[0].x = 1000;
    scene.fish.items[0].velocity = 10;
    try scene.update(0.1);
    try std.testing.expectEqual(3, scene.fish.items.len);
    try std.testing.expect(scene.fish.items[0].x < 80);
}

test "bubbles expire at surface and splats expire with age" {
    var scene = Scene.init(std.testing.allocator, 42, false);
    defer scene.deinit();
    try scene.reset(10, 24);
    try scene.bubbles.append(scene.allocator, .{ .x = 0, .y = 9.1 });
    try scene.splats.append(scene.allocator, .{ .x = 2, .y = 10, .age = 1.49 });
    try scene.update(0.1);
    try std.testing.expectEqual(0, scene.bubbles.items.len);
    try std.testing.expectEqual(0, scene.splats.items.len);
}

test "shark eats small fish and leaves a splat" {
    var scene = Scene.init(std.testing.allocator, 42, false);
    defer scene.deinit();
    try scene.reset(100, 40);
    scene.fish.clearRetainingCapacity();
    try scene.fish.append(scene.allocator, .{ .sprite = art.classic_fish[6], .palette = default_palette, .x = 45, .y = 16, .velocity = 1, .depth = 3 });
    scene.visitor = .{ .kind = .shark, .x = 0, .y = 9, .left = false, .speed = 20, .palette = default_palette };
    try scene.update(0.1);
    try std.testing.expectEqual(1, scene.splats.items.len);
    try std.testing.expect(scene.fish.items[0].x != 45.1);
}

test "every visitor draws and animates in both directions, modes and small sizes" {
    for ([_][2]u16{ .{ 0, 0 }, .{ 1, 1 }, .{ 20, 5 }, .{ 80, 24 }, .{ 160, 60 } }) |size| {
        var screen = try vaxis.Screen.init(std.testing.allocator, .{ .cols = size[0], .rows = size[1], .x_pixel = 0, .y_pixel = 0 });
        defer screen.deinit(std.testing.allocator);
        for ([_]bool{ false, true }) |classic| {
            var scene = Scene.init(std.testing.allocator, 123, classic);
            defer scene.deinit();
            try scene.reset(size[0], size[1]);
            for (std.enums.values(VisitorKind)) |kind| {
                for ([_]bool{ false, true }) |left| {
                    for ([_]bool{ false, true }) |alternate| {
                        scene.visitor = .{ .kind = kind, .left = left, .x = 1, .y = 1, .speed = 10, .palette = default_palette, .alternate = alternate };
                        for (0..16) |_| {
                            try scene.update(0.1);
                            scene.draw(testWindow(&screen));
                        }
                    }
                }
            }
            try scene.reset(size[0], size[1]);
        }
    }
}

test "classic spawning stays classic and long runs keep transient objects bounded" {
    var scene = Scene.init(std.testing.allocator, 9876, true);
    defer scene.deinit();
    try scene.reset(100, 40);
    const count = scene.fish.items.len;
    for (0..8000) |_| {
        try scene.update(0.1);
        for (scene.fish.items) |fish| {
            var classic_sprite = false;
            for (art.classic_fish) |sprite| {
                if (fish.sprite.image.ptr == sprite.image.ptr) classic_sprite = true;
            }
            try std.testing.expect(classic_sprite);
        }
        if (scene.visitor) |visitor| try std.testing.expect(!visitor.alternate);
        try std.testing.expect(scene.bubbles.items.len < 100);
        try std.testing.expect(scene.splats.items.len <= count);
    }
    try std.testing.expectEqual(count, scene.fish.items.len);
    for (scene.plants.items) |plant| try std.testing.expect(plant.age < plant.lifetime);
}

test "independent size buckets retain fitting fish and scenery after resize" {
    var scene = Scene.init(std.testing.allocator, 19, false);
    defer scene.deinit();
    const cases = [_]struct { width: u16, height: u16, narrow: bool, short: bool }{
        .{ .width = 80, .height = 24, .narrow = false, .short = false },
        .{ .width = 40, .height = 24, .narrow = true, .short = false },
        .{ .width = 80, .height = 12, .narrow = false, .short = true },
        .{ .width = 40, .height = 12, .narrow = true, .short = true },
        .{ .width = 20, .height = 8, .narrow = true, .short = true },
        .{ .width = 59, .height = 21, .narrow = true, .short = true },
        .{ .width = 60, .height = 22, .narrow = false, .short = false },
    };
    for (cases) |case| {
        try scene.reset(case.width, case.height);
        try std.testing.expectEqual(case.narrow, scene.layout.narrow);
        try std.testing.expectEqual(case.short, scene.layout.short);
        try std.testing.expect(scene.fish.items.len > 0);
        try std.testing.expect(scene.plants.items.len > 0);
        try std.testing.expect(scene.visitor != null);
        // Sample spawns, including the newer-to-classic fallback, and verify
        // the entire fish can swim between the surface and the bottom.
        for (0..100) |_| {
            const fish = scene.spawnFish().?;
            const size = dimensions(fish.sprite.image);
            try std.testing.expect(size.width <= case.width);
            try std.testing.expect(fish.y >= scene.layout.underwater_y);
            try std.testing.expect(fish.y + size.height <= case.height);
            if (case.short) try std.testing.expect(size.height <= 3);
            if (case.narrow) try std.testing.expect(size.width <= case.width / 3);
            const visitor = scene.spawnVisitor();
            if (case.short) try std.testing.expect(visitor.kind == .mini_ship or visitor.kind == .mini_whale) else if (case.narrow) try std.testing.expect(visitor.kind == .ship or visitor.kind == .whale);
        }
        var screen = try vaxis.Screen.init(std.testing.allocator, .{ .cols = case.width, .rows = case.height, .x_pixel = 0, .y_pixel = 0 });
        defer screen.deinit(std.testing.allocator);
        const win = testWindow(&screen);
        scene.visitor = null;
        scene.fish.clearRetainingCapacity();
        scene.plants.clearRetainingCapacity();
        scene.draw(win);
        try std.testing.expectEqualStrings("~", win.readCell(0, scene.layout.surface_y).?.char.grapheme);
        if (case.narrow or case.short) {
            try std.testing.expectEqualStrings("|", win.readCell(case.width - 6, case.height - 5).?.char.grapheme);
        }
    }
}

test "compact classic mode keeps its fish in bounds" {
    var scene = Scene.init(std.testing.allocator, 88, true);
    defer scene.deinit();
    try scene.reset(40, 12);
    for (0..100) |_| {
        const fish = scene.spawnFish().?;
        var found = false;
        for (art.classic_fish) |candidate| {
            if (candidate.image.ptr == fish.sprite.image.ptr) found = true;
        }
        try std.testing.expect(found);
        try std.testing.expect(fish.y >= scene.layout.underwater_y);
        try std.testing.expect(fish.y + dimensions(fish.sprite.image).height <= 12);
    }
}

test "bubbles collide with the surface chosen for each size" {
    const compact = Layout.init(40, 12);
    const standard = Layout.init(80, 24);
    try std.testing.expect(hitsWaterline(compact, 0, 3.1, 2.9));
    try std.testing.expect(!hitsWaterline(compact, 0, 9.1, 8.9));
    try std.testing.expect(hitsWaterline(standard, 0, 9.1, 8.9));
}
