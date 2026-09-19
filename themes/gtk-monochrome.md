# GTK Oxocarbon coverage

GTK3 and GTK4 use the same widget palette as the DankMaterialShell topbar:
`#131313` backgrounds, `#262626` raised surfaces, `#393939` selections,
`#dde1e6` foregrounds, `#f2f4f8` accents and `#525252` outlines.
Controls use an 8px radius where their native shape permits it. Existing
JetBrains Mono font settings and text sizes are preserved.

The shared rules in `.config/gtk-3.0/widgets.css` cover buttons, text fields,
lists, sidebars, checks, switches, sliders, progress bars, scrollbars, tabs,
tooltips, selection and keyboard focus. GTK-specific rules live in each
version's `gtk.css`. GTK4 also defines libadwaita CSS variables for dialogs,
cards, popovers, navigation sidebars and other library widgets.

Danger and warning states keep semantic colors instead of becoming gray.
Normal text pairs meet WCAG AA contrast. The underlying Breeze/libadwaita
theme continues to supply widget layout, icons and most sizing.

The dotfiles installer links these files into `~/.config`. Restart an app
to ensure it reloads the styles. Do not edit generated `colors.css` to make
widget changes: generation can overwrite it.

This styles GTK applications that load the user stylesheet. Qt, Electron,
web content, and sandboxed apps without access to the stylesheet require
their own theming. Application-specific drawing may also need a separate
override; a GTK stylesheet cannot guarantee every application's coverage.

Reference: [libadwaita color variables](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1-latest/css-variables.html).
