//! hyprmouse: the colors and font of its overlay, set in the user's hyprmouse.conf.

const std = @import("std");
const kosm_ini = @import("kosm_ini");

/// hyprmouse's colors and font; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// hyprmouse.conf: flat `key = value` lines, `#` comments and `#rrggbb` colors. The app writes
/// no booleans; hyprmouse spells its own `True` and `False`.
pub const adapter = kosm_ini.dialect(.{
    .name = "hyprmouse",
    .default_format = .{ .color = .hex, .boolean = .true_false },
    .comments = &.{"#"},
    .nested_headers = false,
});

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
