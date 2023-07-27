# How I use vim and mnemonics

# Basics

`<C-U>` / `<C-D>`: page up / page down  
`}` / `{` : move to the next blank like (paragraph)  

`i` / `a` / `o` / `O` : insert, append, insert next line, insert previous line  
`p` / `P` : past after / Past above  
`/` / `?` : search and N or n to go backward / forward  
`*` / `#` Search word under cursor forward / backward  
`qq` : recording macro on q  
`q` : stop recording macro  
`@q` : play the q macro  
`ctrl o` / `ctrl i` : jump list (back next)  
`gf` : go to file  
`gx`: go to url  
`0` go beggining in line  
`^` go to first non blank char in line  
`$` eol  
`g_` : eol but without the newline char 
`gg` : beggining of a file  
`G` : eof  
`.` : repeat  
`=` : indent  
`gU` : uppercase (put random line in lowercase with flash for example (gur[label]_))  
`gu` : lowercase  
`past clipboard` : "+p ("+ is the system clipboard)  
`"0p` : last yanked register  
`gs` = change case (`gsc` change to camel case, `gst`: title case, `gsU` : uppercase, `gs_`: snake case) (vim-caser plugin)  
`//`: nohlsearch
`]q` / `[q`: quickfix next and prev

# Surround (gz)

From mini.surround, keybindings from Lazyvim distribution. (avoid conflicting with Flash)

`di'` : delete inner quote  
`gzd'` : delete surround quote  
`gzr'"` : change surround quote to double quote  
`gzaiw'`: add surround quotes to inner word  

# Comment (gc / gb)

`gc` : comment (but need to be associated with text-object or motion)  
`gcc` : comment current line  
`gcG` : comment until end (or gggcG)  

`gb` for block comment (`gbc` ...)  

# Moving accuratly

`s` and / = flash (default mode)  
`f` / `F` / `t` / `T` (represse `f` or `F` or `t` or `T` to move between matches)  
doing an action remotly (`r`) for example `yr[label]iw` = (yank remotly [label] inner word) (`dr[label]d`) delete line remotly  


## Text objects

`iw` / `ax`: word  

`i"` : inner double quote  
`it` : inner tag  

`%` : end of closing bracket  

`ix` / `ax` : html attribute (so useful)  
`aa` / `ia` : argument text object (target)  

`im` / `am` : member (chaining) ex .Map().Bind().Bind() (so dim very userful)  

`gn`: next match text object (search, then `cgn`, then repeat with dot)  

for text objects (handled by targets.vim), can use l (last = previous) or n (next) like: `cil`)  


## LSP

`gd` : go to def  
`K` : hover (KK move to the popup)  
`gl` : diagnostic in window  
`<leader>lj` / `<leader>lk` : next prev diagnostic  
`<leader>a` : code action  
`<leader>lr` : rename symbol  
`gs `: signature  
`gr`: references  
`]p` / `[p`: diagnostics


## Git
`<leader>gg` : Neogit  
`<leader>gd` : DiffView  
`]c` / `[c` : next hunk / previous hunk  

## Telescope

`<leader>f` : git files  
`<leader>sr` : recent  
`<leader>st` : search text (grep)  
`<leader>sf` : search file (from current dir)  
`<leader>sk` : search key map  
`<leader>ss` : git status  

## jumplist
`C-^` / `C-6` : last file visited  
`C-o`: previous element in jumplist  
`C-i`: next  
`:Telescope jumplist`  

## Search and replace
`:cdo s/dede/dede/g` : apply command on qf list (c do)  
`:cdo up` : save all file matching qf list (so good after cdo s/dede/dede/g)  
`:Ack 'searchpattern' [path]`  

## Misc

`&`: for full match for regex, example, add 2 spaces at the end of line `s/.*/&  /`  
