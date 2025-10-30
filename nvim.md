# How I use vim and mnemonics

# Basics

`<C-U>` / `<C-D>`: page up / page down  
`}` / `{` : move to the next blank like (paragraph)  

`i` / `a` / `o` / `O` : insert, append, insert next line, insert previous line  
`p` / `P` : past after / Past above  
`/` / `?` : search and N or n to go backward / forward  
`*` / `#` Search word under cursor forward / backward  
`qq` : recording macro in q  
`q` : stop recording macro  
`@q` : play the q macro  
`ctrl o` / `ctrl i` : jump list (back next)  
`gf` : go to file  
`gx`: go to url  
`0` go beginning in line  
`^` go to first non blank char in line  
`$` eol  
`g_` : eol but without the newline char 
`gg` : beginning of a file  
`G` : eof  
`.` : repeat  
`=` : indent  
`gU` : uppercase (put random line in lowercase with flash for example (gur[label]_))  
`gu` : lowercase  
`past clipboard` : "+p ("+ is the system clipboard)  
`"0p` : last yanked register  
`//`: nohlsearch
`]q` / `[q`: quickfix next and prev (recommand mapping < and > to [ and ] in azerty)

# Surround (gs)

For mini.surround, keybindings from Lazyvim distribution. (avoid conflicting with Flash)

`di'` : delete inner quote  
`gsd'` : delete surround quote  
`gsr'"` : change surround quote to double quote  
`gsaiw'`: add surround quotes to inner word  

# Comment (gc / gb)

`gc` : comment (but need to be associated with text-object or motion)  
`gcc` : comment current line  
`gcG` : comment until end (or gggcG)  

`gb` for block comment (`gbc` ...)  

# Moving accuratly

`s` and / = flash (default mode)  
`f` / `F` / `t` / `T` (re press `f` or `F` or `t` or `T` to move between matches)  
doing an action remotely (`r`) for example `yr[label]iw` = (yank remotely [label] inner word) (`dr[label]d`) delete line remotely  
`S`: select using treesitter


## Text objects

`iw` / `ax`: word  

`i"` : inner double quote  
`it` : inner tag  

`%` : end of closing bracket  

`ix` / `ax` : html attribute (so useful)  
`aa` / `ia` : argument text object (target)  

`gn`: next match text object (search, then `cgn`, then repeat with dot)  

for text objects (handled by targets.vim), can use l (last = previous) or n (next) like: `cil`)  


## LSP

`grd` : go to def  
`K` : hover (KK move to the popup)  
`<leader>de` : diagnostic in window  (diagnostic extend)
`gra` : rename symbol  
`gnr`: references  
`]p` / `[p`: diagnostics


## Git
`<leader>hg` : Neogit  
`]c` / `[c` : next hunk / previous hunk  

## Telescope

`<leader>sf` : git files  
`<leader>sg` : search text (grep)  

## jumplist
`C-^` / `C-6` : last file visited  
`C-o`: previous element in jumplist  
`C-i`: next  
`:Telescope jumplist`  

## Search and replace
`:cdo s/dede/dede/g` : apply command on qf list (c do)  
`:cdo up` : save all file matching qf list (so good after cdo s/dede/dede/g)  

## Misc

`&`: for full match for regex, example, add 2 spaces at the end of line `s/.*/&  /`  
