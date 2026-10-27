# Niri host settings

`config.kdl` contains the shared layout and shortcuts used with Noctalia.
Flux selects `hosts/horus.kdl` or `hosts/shu.kdl` by hostname and links it to
`~/.config/niri-host.kdl`, which is included last. Other hosts use the shared
defaults when that optional file is absent.

Horus uses Alt for `Mod` shortcuts and mouse `accel-speed -0.4`. Shu uses
Super and the default mouse speed (`0.0`). Mouse speed ranges from `-1.0`
(slowest) to `1.0` (fastest). Edit the matching host file to tune it.

Add host-specific `binds` entries to the matching file to override shared
shortcuts. Explicit `Super+Alt` shortcuts for locking and Orca remain unchanged;
`mod-key` changes shortcuts written with `Mod`.

After pulling changes on either machine, run
`flux --config ~/.dotfiles/config.toml apply --dry-run --diff`, inspect the
preview, then run `flux --config ~/.dotfiles/config.toml apply` to install
the host link. Niri reloads included configuration files automatically.

## Automatic game mode on Horus

`niri-game-mode.service` watches Niri's IPC events. While a focused Gamescope
tile fills its monitor, desktop `Mod` shortcuts use Super, leaving Alt available
to the game. Leaving the game, opening the overview, closing it, or stopping the
service restores the host default. Explicit Alt/Super bindings are unchanged.
Niri 26.04 doesn't expose fullscreen state over IPC, so this uses tile dimensions;
a manually sized Gamescope window that exactly fills its monitor also matches.

After installing the Flux links, enable it with
`systemctl --user enable --now niri-game-mode.service`.
Disable it and restore normal shortcuts with
`systemctl --user disable --now niri-game-mode.service`.
The generated override lives in `~/.local/state/niri/game-mode.kdl`; the service
resets it on startup, shutdown, and failure. The host settings are never rewritten.
