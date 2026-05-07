# dotfiles

My personal dotfiles for Hyprland on Fedora 41, managed with [GNU Stow](https://www.gnu.org/software/stow/).

> Screenshots coming soon.

---

## Setup

### Requirements

- Fedora 43
- GNU Stow (`sudo dnf install stow`)

### Fresh install

```zsh
git clone git@github.com:queirozz8/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */
```

That's it. Stow will create all symlinks automatically.

---

## Structure

Each subdirectory is a **Stow package** — its internal structure mirrors `$HOME`, so Stow knows exactly where to symlink each file.

```
dotfiles/
├── cava/           → ~/.config/cava/
├── fastfetch/      → ~/.config/fastfetch/
├── gtk-3.0/        → ~/.config/gtk-3.0/
├── gtk-4.0/        → ~/.config/gtk-4.0/
├── hyprland/       → ~/.config/hypr/
├── kitty/          → ~/.config/kitty/
├── micro/          → ~/.config/micro/
├── rofi/           → ~/.config/rofi/
├── swaync/         → ~/.config/swaync/
├── wallust/        → ~/.config/wallust/
├── waybar/         → ~/.config/waybar/
├── wlogout/        → ~/.config/wlogout/
└── zsh/            → ~/.zshrc
```

---

## Stack

| Tool | Role |
|---|---|
| [Hyprland](https://hyprland.org/) | Wayland compositor |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [Rofi](https://github.com/davatorium/rofi) | App launcher |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | Terminal emulator |
| [Swaync](https://github.com/ErikReider/SwayNotificationCenter) | Notification center |
| [Wlogout](https://github.com/ArtsyMacaw/wlogout) | Logout menu |
| [Wallust](https://codeberg.org/explosion-mental/wallust) | Colorscheme generator |
| [Cava](https://github.com/karlstav/cava) | Audio visualizer |
| [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info |
| [Micro](https://micro-editor.github.io/) | Terminal text editor |
| Zsh | Shell |

---

## Useful Stow commands

```zsh
# Apply a single package
stow kitty

# Remove symlinks from a package
stow -D kitty

# Reapply (useful after moving files)
stow -R kitty

# Dry run before applying
stow --simulate kitty
```