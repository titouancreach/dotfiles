# prtour.nvim 🧭

A Graphite-style **PR code tour** for Neovim. Pick a PR you're reviewing, read it
top-to-bottom like a book — the AI orders the changes high→low signal, writes a
"what & why" for each section, inlines the real diff, and pushes lockfiles/generated
noise to a folded "Skim" section at the bottom. Comment as you read, then approve /
request changes / push your review back to GitHub.

Built on the `gh` and `claude` CLIs, and reuses [review.nvim](https://github.com/georgeguimaraes/review.nvim)'s
comment popup + highlight primitives.

## Requirements

- Neovim ≥ 0.10 (`vim.system`)
- `gh` CLI, authenticated (`gh auth status`)
- `claude` CLI (for AI tour generation; falls back gracefully if missing)
- `telescope.nvim` (PR picker; falls back to `vim.ui.select`)
- `review.nvim` + `nui.nvim` (comment input popup + highlights)

## Install (lazy.nvim, local dir)

```lua
{
  dir = '~/Code/dotfiles/prtour.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'MunifTanjim/nui.nvim',
    { dir = '~/Code/dotfiles/review.nvim' },
  },
  cmd = { 'PrTour' },
  keys = { { '<leader>pt', '<cmd>PrTour<cr>', desc = 'PR Tour' } },
  opts = {},
}
```

## Usage

```vim
:PrTour                 " telescope picker of PRs where you're review-requested
:PrTour local           " tour your uncommitted working-tree changes (vs HEAD)
:PrTour <number>        " open a PR in the current repo by number
:PrTour <url>           " open any PR by URL (works across repos)
:PrTour owner/repo#123  " open a PR in another repo by shorthand
:PrTour url             " prompt for a PR URL / shorthand
:PrTour refresh         " re-fetch + regenerate the tour
:PrTour comments        " reload existing GitHub review comments
:PrTour export          " copy comments markdown to clipboard
:PrTour approve         " submit an APPROVE review to GitHub
:PrTour request-changes " submit a REQUEST_CHANGES review
:PrTour push            " submit a COMMENT review (inline comments only)
:PrTour close           " close the tour (auto-exports comments)
```

The tour opens in its own tab. Comments are stored locally per PR
(`~/.local/share/nvim/prtour/`) and only sent to GitHub when you explicitly
approve / request changes / push.

While the PR list / diff load, an animated spinner shows on the command line. The
tour renders **all-or-nothing**: you see a short loading view, then the complete tour
appears at once (no confusing re-ordering as the AI lands). Section headers are
colored by signal — 🔴 high, 🟡 med, ⚪ low.

The tour is generated with a fast model (`opts.model = "sonnet"` by default; set `""`
to use your Claude default) and **cached per head commit** — reopening the same PR is
instant. `:PrTour refresh` (or `<leader>R`) regenerates and updates the cache.

Between hunks, hidden lines show as a `⊿ N hidden lines … <CR> to expand` marker.
Pressing `<CR>` there fetches the file at the PR head (works for forks) and reveals
20 more lines of context each press — the revealed lines are commentable like any other.

### Notion ticket context

If the PR links a Notion ticket (a `notion.so` / `notion.site` URL anywhere in the body,
title, or branch name), the headless `claude` fetches that page via the **Notion MCP** and
adds a `🎫 <ticket> — <purpose>` line near the top of the tour explaining *why* the PR
exists. Requires the Notion MCP connected in your Claude CLI (`claude mcp list`). Toggle
with `opts.notion.enabled`; set the allowed tool names via `opts.notion.tools`. If no link
is found or the fetch fails, the tour is generated as usual.

The diff code is **syntax-highlighted with treesitter** (per file language, layered on
the red/green diff backgrounds) — applied a tick after the tour paints, so it's never
blocking. Languages without an installed parser just render uncolored. The tour buffer
is its own filetype (`prtour`) with manual folding pinned via `ftplugin/prtour.lua`, so
`za`/`zc`/`zR`/`zM` work regardless of your global fold settings.

`D` opens the file under the cursor in [codediff.nvim](https://github.com/esmuellert/codediff.nvim).
It best-effort `git fetch`es the PR head (works for forks) and base, computes the
merge-base, and shows that one file base…head. Requires codediff.nvim installed.

This codediff view is a **read-only side-by-side viewer** — prtour suppresses
review.nvim from attaching its comment keymaps to it (review.nvim otherwise hijacks
any codediff session). Add your review comments in the **tour buffer** with `i`, not
in the `D` view.

## Local mode

`:PrTour local` (or `<leader>pl`) gives you the same tour — AI ordering, semantic
comments, syntax-highlighted diff, context expansion — for your **uncommitted changes**
(`git diff HEAD`, staged + unstaged). Comments persist per branch and export to the
clipboard with `C` / `q`. There's no GitHub PR, so approve/request-changes/push are
disabled; `D` opens the file as HEAD vs working tree, and context expansion reads the
file from disk. Handy as a pre-commit self-review (a gradual replacement for `:Review`).

## Keymaps (in the tour buffer)

| Key | Action |
|-----|--------|
| `i` | add comment at cursor (visual-select a range first for a multi-line comment) |
| `e` / `d` | edit / delete comment at cursor |
| `]n` / `[n` | next / prev comment |
| `<Tab>` / `<S-Tab>` | next / prev section |
| `za` | toggle fold (section) |
| `<CR>` | on a `⊿ N hidden lines` marker: reveal hidden context; otherwise toggle fold |
| `y` | yank `path:line` + hunk block to clipboard (paste into Claude) |
| `D` | open the file under the cursor in codediff (PR base…head, side-by-side) |
| `gP` | reload existing GitHub review comments onto the tour |
| `C` | export all comments to clipboard |
| `<leader>a` / `<leader>r` / `<leader>p` | approve / request-changes / push review |
| `<leader>R` | refresh |
| `q` | close (auto-export) |
| `g?` | show the keybinding cheatsheet (floating, grouped) |

All maps are registered with **which-key** (with labels + icons), so the `<leader>`
actions pop up automatically. Press `g?` any time for the full grouped cheatsheet —
you don't need to memorize anything.

### Semantic comment labels

Comments use the [m31coding "semantic reviews"](https://www.m31coding.com/blog/semantic-reviews.html)
labels, ordered by escalating expectation — the label alone tells the author what's
expected of them:

| Label | Icon | Meaning |
|-------|------|---------|
| Remark | 💬 | A simple remark; no change or answer expected |
| Hint | 💡 | FYI — consider for the future; no change expected |
| Question | ❓ | An honest question; expects an answer |
| Suggestion | 🔧 | Consider it; accepting is your call |
| Important | ❗ | Expects a change; discuss if you disagree |
| Crucial | 🛑 | Must not be merged; severe issue |

Cycle the label with `<Tab>` in the comment editor. Exports/GitHub bodies render as
`Important: …` (not `[IMPORTANT]`). Customize via `opts.comment_types` / `opts.comment_type_order`.

### Existing GitHub comments

When a tour opens, prtour also pulls the PR's existing inline review comments and shows
them as read-only `💬 @author (GitHub)` boxes on the matching lines. Reload them anytime
(e.g. after a teammate comments) with **`gP`** or `:PrTour comments` — no need to
regenerate the whole tour.

### Comment editor

By default (`opts.comment_ui = "buffer"`), pressing `i` opens a **real editable
buffer** in a bottom split — full vim motions and modes:

- `:wq` / `:x` / `ZZ` — **save** the comment
- `:q` / `ZQ` — **discard**
- `<Tab>` (normal mode) — change the comment type (shown in the winbar)

Set `opts.comment_ui = "popup"` to use review.nvim's nui popup instead (`<C-s>`
submit, `<Tab>` cycle type, `Esc`/`q` cancel).

## How the tour is built

1. `gh pr diff <n>` → parsed into files/hunks/lines (`diff.lua`).
2. The diff + PR title/body is piped to `claude -p --output-format json`, which
   returns a JSON tour spec (sections, signal, descriptions, skim list).
3. The spec is reconciled against the real file list (unknown paths dropped,
   unmentioned files funneled into Skim), ordered high→med→low, and rendered.
4. If Claude is unavailable or returns bad JSON, a **fallback** tour (files in diff
   order, lockfiles in Skim) is used so the tour always opens.

Every diff line carries an anchor `{path, side, file_line}` — the single source of
truth for commenting, the `y` yank, and mapping comments back to GitHub inline
review comments.

## Tests

```bash
make test                 # unit + render smoke tests (no network)
make live DIFF=some.diff   # live parse + AI tour generation
make ui   DIFF=some.diff   # UI render smoke test
```
