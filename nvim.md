# Neovim Configuration Cheat Sheet

Leader key: `<Space>`

## Basics

`<C-U>` / `<C-D>`: page up / page down
`}` / `{`: move to the next blank line (paragraph)
`w` / `e` / `b`: word motions (enhanced by nvim-spider)

`i` / `a` / `o` / `O`: insert, append, insert next line, insert previous line
`p` / `P`: paste after / paste above (in visual mode, `p` pastes without overwriting register)
`/` / `?`: search and N or n to go backward / forward
`*` / `#`: search word under cursor forward / backward
`qq`: recording macro in q
`q`: stop recording macro
`@q`: play the q macro
`<C-o>` / `<C-i>`: jump list (back/next)
`gf`: go to file
`gx`: go to url
`0`: go beginning of line
`^`: go to first non-blank char in line
`$`: end of line
`g_`: end of line without newline char
`gg`: beginning of file
`G`: end of file
`.`: repeat last command
`=`: indent
`>>` / `<<`: indent right / left
`gU`: uppercase
`gu`: lowercase
`"+p`: paste from system clipboard
`"0p`: paste from last yanked register
`<Esc>`: clear search highlights
`<Esc><Esc>`: exit terminal mode
`<C-^>` / `<C-6>`: last file visited

# Surround (mini.surround)

`di'`: delete inner quote
`gsd'`: delete surround quote
`gsr'"`: change surround quote to double quote
`gsaiw'`: add surround quotes to inner word
`gsf` / `gsF`: find surrounding (right/left)
`gsh`: highlight surrounding
`gsn`: update n_lines

# Flash (Precision Motion)

`s`: flash jump to any location
`S`: flash treesitter selection
`r`: remote flash (operator mode) - e.g., `yr[label]iw` (yank remotely inner word)
`R`: treesitter search (visual/operator mode)
`f` / `F` / `t` / `T`: enhanced with jump labels (repeat to cycle matches)
`<C-s>`: toggle flash search (command mode)


## Text Objects (mini.ai)

`iw` / `aw`: inner/around word
`i"` / `a"`: inner/around double quote
`it` / `at`: inner/around tag
`%`: jump to matching bracket

`gn`: next match text object (search with `/`, then `cgn`, then `.` to repeat)

Enhanced with mini.ai (n_lines = 500):
- Use `in` / `an` for next object
- Use `il` / `al` for last (previous) object
- Works with quotes, brackets, tags, etc.

## LSP (Standard Bindings)

`K`: show hover documentation (press twice to enter popup)
`grd`: go to definition
`grD`: go to declaration
`gri`: go to implementation
`grr`: find references (telescope)
`grt`: go to type definition
`grn`: rename symbol
`gra`: code actions
`gO`: document symbols (outline)
`gW`: workspace symbols
`<leader>de`: diagnostic in floating window
`<leader>q`: open diagnostic quickfix list


## Bracketed Navigation (AZERTY-friendly)

Next/Previous with `<` / `>` + suffix:
- `<d` / `>d`: diagnostic
- `<q` / `>q`: quickfix
- `<b` / `>b`: buffer
- `<j` / `>j`: jump
- `<f` / `>f`: file
- `<l` / `>l`: location
- `<t` / `>t`: treesitter
- `<u` / `>u`: undo
- `<w` / `>w`: window
- `<y` / `>y`: yank

Use uppercase for first/last (e.g., `<Q` for first quickfix, `>Q` for last)

## Git (Gitsigns + Neogit)

Navigation:
- `]c` / `[c`: next/previous hunk

Hunk operations (visual mode supported):
- `<leader>hs`: stage hunk
- `<leader>hr`: reset hunk
- `<leader>hp`: preview hunk
- `<leader>hS`: stage buffer
- `<leader>hR`: reset buffer

Info:
- `<leader>hb`: blame line
- `<leader>hD`: diff against last commit
- `<leader>hq`: show all hunks in quickfix list

Git UI:
- `<leader>hg`: open Neogit
- `<leader>hd`: diff history for current file (Diffview)

## Telescope

Files:
- `<leader>sf`: git files
- `<leader><space>`: recent files (oldfiles)
- `<leader>s.`: recent files (current directory only)
- `<leader>,`: open buffers
- `<leader>sc` / `<leader>sn`: search config files

Search:
- `<leader>/`: live grep
- `<leader>sw`: search current word
- `<leader>sg`: ast-grep (structural search)
- `<leader>sd`: search diagnostics

Meta:
- `<leader>sh`: search help
- `<leader>sk`: search keymaps
- `<leader>ss`: telescope builtin pickers
- `<leader>sr`: resume last search  

## Multi-Cursor (multicursor.nvim)

Add/skip cursors:
- `<Up>` / `<Down>`: add cursor above/below
- `<leader><Up>` / `<leader><Down>`: skip cursor above/below
- `<leader>n` / `<leader>N`: match add cursor forward/backward
- `<leader>s` / `<leader>S`: match skip cursor forward/backward (conflicts with Flash, use in specific contexts)
- `<C-LeftMouse>`: add cursor with mouse
- `<C-q>`: toggle cursor

When multiple cursors active:
- `<Left>` / `<Right>`: navigate between cursors
- `<leader>x`: delete cursor
- `<Esc>`: enable/clear cursors
- `<leader>gv`: restore cursors

## File Explorer

Oil.nvim (edit directories like buffers):
- `-`: open parent directory
- Edit files directly in the buffer, save to apply changes

Neo-tree:
- Standard file tree navigation

## Other Utilities

TypeScript:
- `<leader>tt`: run TSC
- `<leader>to`: open TSC window
- `<leader>tc`: close TSC window

Toggles:
- `<leader>tb`: toggle git blame line
- `<leader>tD`: toggle show deleted lines (inline)
- `<leader>th`: toggle inlay hints

Scratch buffers (Snacks):
- `<leader>.`: toggle scratch buffer
- `<leader>S`: select scratch buffer

Save:
- `<leader>w`: write current buffer
- `<leader>y`: yank to system clipboard (normal/visual)
- `<leader>Y`: copy last yanked text to system clipboard

## Search and Replace

`:cdo s/old/new/g`: apply substitution on quickfix list (each line)
`:cfdo s/old/new/g`: apply substitution on quickfix list (each file)
`:cdo norm @q`: apply macro q to each line in quickfix list
`:cfdo norm @q`: apply macro q to each file in quickfix list
`:cdo up`: save all files in quickfix list
`gn`: next match text object (search with `/`, then `cgn` to change, `.` to repeat)

## Misc

`&`: full match in regex (e.g., `s/.*/&  /` adds 2 spaces at end of line)
Folding: configured with Treesitter (`za` to toggle, `zR` to open all, `zM` to close all)
Auto-pairs: automatic bracket/quote pairing enabled
Spell checking: cspell integration for diagnostics  
