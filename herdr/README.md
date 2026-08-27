# herdr

[herdr](https://herdr.dev) config — replaces the tmux setup in `../tmux/`.
Keymap is deliberately a port of `../tmux/tmux.conf` (prefix `C-a`, `%`/`-`
splits, `prefix+c` new tab, …) so muscle memory carries over.

`config.toml` is symlinked to `~/.config/herdr/config.toml` by `../install.sh`.
Only that file is versioned — everything else under `~/.config/herdr/` is
runtime state: `herdr.sock`, `*.log`, `session.json`, `session-history.json`,
`plugins.json` (registry with absolute paths + content hashes) and the
`plugins/github/` checkouts.

Reload after editing: `prefix+r` or `herdr server reload-config`.

## Not captured by config.toml

Two pieces of the setup live outside this file:

- **`vim-herdr-navigation` plugin** — provides the `ctrl+h/j/k/l` bindings in
  `[[keys.command]]`. Installed by `../install.sh`; without it herdr logs an
  unknown plugin action and those four keys do nothing (fall back to
  `prefix+hjkl` or `ctrl+alt+hjkl`). Editor side lives in
  `../nvim-kickstart/lua/custom/plugins/tmux-navigator.lua`, which resolves the
  managed checkout by glob because its path carries a content hash.

- **`HERDR_NAV_PASSTHROUGH_RE`** in `~/.zshrc` — TUIs that should keep
  `ctrl+h/j/k/l` for themselves instead of moving pane focus:

  ```sh
  export HERDR_NAV_PASSTHROUGH_RE='^(fzf|lazygit|k9s)$'
  ```

  The regex is matched against the `name` field of `herdr pane process-info`,
  which is not always the binary name — Claude Code reports its version string
  (`2.1.221`) as `name` and `claude` only as `argv0`, so `^claude$` never
  matches. Read by the *server* at startup: `herdr server stop` to pick up a
  change.

- **Claude statusLine chaining** in `~/.claude/statusline-command.sh` (not
  versioned here) — feeds the stdin JSON to the `usagebar` plugin before
  rendering:

  ```sh
  for _herdr_usagebar in "$HOME"/.config/herdr/plugins/github/usagebar-*/bin/run-statusline.sh; do
    printf '%s' "$input" | bash "$_herdr_usagebar" >/dev/null 2>&1 || true
    break
  done
  ```

  This is the *only* source of the 5h/7d windows on this machine:
  `~/.claude.json` carries no `cachedUsageUtilization` key, so without the
  chain the plugin's `$limit` token stays empty and the sidebar shows only the
  context gauge. The script writes nothing to stdout — it just fills
  `~/.claude/herdr-usagebar/` and fires the rate-limit toasts. Globbed because
  the plugin path carries a content hash, same as the nvim navigation plugin.

  Replaces the tmux `claude_usage` module (`~/.tmux/claude_usage_module.conf`
  + the `claude-usage` Haskell binary), which is still installed and works.

## Tradeoff to remember

Binding `ctrl+k`/`ctrl+l` globally shadows readline's kill-line and
clear-screen in non-Vim panes — same deal as `vim-tmux-navigator` under tmux.
