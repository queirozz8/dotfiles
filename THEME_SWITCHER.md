# Alternar entre Darkmatter e Vesper

- Atalho Hyprland: `Super + Alt + Shift + T` abre o seletor no Rofi.
- Terminal: `theme-switch darkmatter`, `theme-switch vesper` ou `theme-switch status`.
- Sem argumentos, `theme-switch` abre o seletor.

O seletor alterna GTK, Rofi, Waybar, Kitty, SwayNC, Wlogout, Hyprlock, wallpaper e tema TUI do Codex. Os snapshots locais usados ficam em `~/.theme-backup/theme-presets/`; o backup Vesper original continua preservado em `~/.theme-backup/2026-10-04_212546-darkmatter/`.

O Brave segue sem tema customizado ativado, então o seletor não altera o navegador. Codex aplica o tema após reiniciar o app. Como os arquivos ativos são Stow-managed, escolher Vesper altera os arquivos correspondentes em `~/dotfiles`; escolher Darkmatter os restaura ao preset Darkmatter.
