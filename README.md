# kosm_hyprmouse

hyprmouse for kosm: the colors and font of its overlay, and the `hyprmouse` adapter for its
flat `key = value` config.

The app sets each set option by name in `~/.config/hypr/hyprmouse.conf` and changes nothing
else, so hyprmouse's behaviour settings stay yours. Every set option's key must be in the
file already; a missing one fails the apply, naming it.

`from(theme)` sets the background black (white in light mode) at the theme's
`background_alpha`, the grid cyan, dots and text white and the text's outline black. The font
is left alone.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/hypr/hyprmouse.conf` |
| `format` | the adapter's: `#rrggbb` |
| `font`, `font_size` | null: left as it is |
| `background_color`, `grid_color`, `dot_color`, `text_color`, `text_outline_color` | null: left as it is |
| `background_opacity` | null: left as it is; 0..1 |
