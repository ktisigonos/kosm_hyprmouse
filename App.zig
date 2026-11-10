//! hyprmouse's overlay colors and font, set by name in the user's hyprmouse.conf; every other
//! setting stays as it is. Field names are hyprmouse's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// hyprmouse's config; each set option's key must be in it already.
/// Default: `~/.config/hypr/hyprmouse.conf`.
file: []const u8 = "~/.config/hypr/hyprmouse.conf",
/// How values are spelled. Null fields take the adapter's: `#rrggbb`.
format: kosm.Format = .{},
/// The family the coordinates are shown in. null: left as it is.
font: ?[]const u8 = null,
/// Their size, in points. null: left as it is.
font_size: ?i64 = null,
/// The overlay's background; its opacity is `background_opacity`. null: left as it is.
background_color: ?kosm.Color = null,
/// The grid's lines. null: left as it is.
grid_color: ?kosm.Color = null,
/// The dots where grid lines cross. null: left as it is.
dot_color: ?kosm.Color = null,
/// The coordinates' text. null: left as it is.
text_color: ?kosm.Color = null,
/// The outline around the text. null: left as it is.
text_outline_color: ?kosm.Color = null,
/// The background's opacity, 0 (transparent) to 1 (opaque). null: left as it is.
background_opacity: ?f64 = null,

/// Colors from the theme: the background black (white in light mode) at the theme's
/// background alpha, the grid cyan, dots and text white and the text's outline black. The
/// font is left alone.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    const foreground = if (theme.mode == .dark) palette.white else palette.black;
    const background = if (theme.mode == .dark) palette.black else palette.white;
    return .{
        .background_color = background,
        .grid_color = palette.cyan,
        .dot_color = foreground,
        .text_color = foreground,
        .text_outline_color = background,
        .background_opacity = theme.background_alpha,
    };
}

/// Sets every set option in `file`. With none set, the file is not read.
pub fn apply(self: App, output: *kosm.Output) !void {
    var config: ?kosm.Output.Selection = null;
    inline for (@typeInfo(App).@"struct".field_names) |name| {
        if (comptime !std.mem.eql(u8, name, "file") and !std.mem.eql(u8, name, "format")) {
            if (@field(self, name)) |option| {
                if (config == null) config = try output.edit(.{ .files = self.file, .lang = "hyprmouse", .format = self.format });
                try config.?.set(name, option);
            }
        }
    }
}

const testing = std.testing;
const adapter = @import("root.zig").adapter;

const shipped =
    \\show_ui = True
    \\format = x, y
    \\font = Maple Mono Normal NFP
    \\font_size = 25
    \\background_color = #041C26
    \\grid_color = #2D8699
    \\dot_color = #A3C5CC
    \\text_color = #A3C5CC
    \\text_outline_color = #041C26
    \\background_opacity = 0.5
    \\
;

test "only the set options' values change, and a missing key fails naming it" {
    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.createDirPath(testing.io, ".config/hypr");
    try tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/hypr/hyprmouse.conf", .data = shipped });
    var home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    var arena: std.heap.ArenaAllocator = .init(testing.allocator);
    defer arena.deinit();
    var plan: kosm.Plan = .init(testing.allocator, testing.io);
    defer plan.deinit();
    var diagnostics: kosm.Diagnostics = .{};
    var warnings: kosm.Warnings = .init(arena.allocator());
    var output: kosm.Output = .{
        .allocator = arena.allocator(),
        .home = home_buffer[0..try tmp.dir.realPath(testing.io, &home_buffer)],
        .adapters = &.{adapter},
        .plan = &plan,
        .diagnostics = &diagnostics,
        .warnings = &warnings,
        .app = "hyprmouse",
    };
    var app = from(kosm.Theme.from(.{ .black = kosm.hex("000000"), .white = kosm.hex("ffffff"), .cyan = kosm.hex("00ffff") }, .dark));
    app.font = "Iosevka";
    try app.apply(&output);
    try testing.expectEqualStrings(
        \\show_ui = True
        \\format = x, y
        \\font = Iosevka
        \\font_size = 25
        \\background_color = #000000
        \\grid_color = #00ffff
        \\dot_color = #ffffff
        \\text_color = #ffffff
        \\text_outline_color = #000000
        \\background_opacity = 1
        \\
    , plan.files.items[0].new);

    try tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/hypr/other.conf", .data = "show_ui = True\n" });
    const missing: App = .{ .file = "~/.config/hypr/other.conf", .font_size = 12 };
    try testing.expectError(error.NoMatch, missing.apply(&output));
    try testing.expectEqualStrings("~/.config/hypr/other.conf", diagnostics.file);
}
