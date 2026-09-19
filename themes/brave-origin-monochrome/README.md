# vrdq Monochrome for Brave Origin

A native Chromium theme using the desktop's existing monochrome palette.
The companion `themes/jetbrains-web` extension makes semantic webpage text
and form controls use JetBrains Mono while preserving native icon fonts.

## Install

The installed launcher already loads both directories through
`~/.config/brave-origin-flags.conf`.

If you launch Brave another way, open `brave://extensions`, enable
**Developer mode**, choose **Load unpacked**, and select
`~/dotfiles/themes/brave-origin-monochrome`.

After changing the files, open `brave://extensions`, click **Reload** on the
theme, then reload open tabs. The stylesheet applies to ordinary web pages,
including custom elements; browser-internal pages such as `brave://settings`
do not allow extension CSS. Closed shadow roots, canvas-rendered text,
images, and PDFs cannot be overridden by webpage CSS.

Keep the directory in place. To undo, open `brave://settings/appearance`
and reset the theme to its default. The dotfiles installer does not install
this theme automatically.

## Palette and design

### Text size

Keep normal display scaling. A device-scale override enlarges the entire
browser, which is unsuitable for adjusting only small labels. Chromium
color themes cannot override individual fonts on Brave's internal pages.

### Colors

| Role | Color | Source |
| --- | --- | --- |
| Frame, inactive tabs, address field | `#131313` | Kitty background / GTK window |
| Toolbar | `#1f1f1f` | GTK cards and popovers |
| Active tab | `#393939` | DMS selected surface |
| Inactive tab | `#131313` | Kitty background |
| Main text and icons | `#e2e2e2` | Kitty / GTK foreground |
| Inactive tab text | `#c6c6c6` | Kitty inactive tabs |
| Unfocused tab text | `#ababab` | Kitty selection background |
| Active tab text and links | `#ffffff` | DMS / GTK accent |

The Brave-specific theme mapping assigns the DMS selected surface to the
visible active tab, while inactive tabs recede
into the Kitty background without a white flash.

```text
charcoal frame   [ inactive tab ] [ ACTIVE TAB ]
raised charcoal toolbar         [ dark address field ]
page content
```

Brave retains its native typography, layout, keyboard focus and responsive
behavior; Chromium themes cannot select UI fonts or change tab geometry.
The theme uses opaque colors; compositor opacity remains a desktop setting.
Brave's own new-tab page and private-window styling may override theme
colors. Websites keep their own appearance. This is a fixed palette, not
a Matugen hook.

Sources: `~/.config/kitty/dank-theme.conf`, `dank-tabs.conf`, and
`~/.config/gtk-3.0/dank-colors.css`.

Format: [Chromium themes](https://developer.chrome.com/docs/extensions/develop/ui/themes).
