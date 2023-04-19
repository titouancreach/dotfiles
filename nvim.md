# How I use vim and mnemonics (because it helps me writing things down)

# Basic

Ctrl U / Ctrl D : Page Up / Page Down  
\} / \{ : Move to the next blank like (paragraph)  
i / a / o / O : insert, append, insert next line, insert previous line  
p / P : past after / Past above  
/ / ? : search and N or n to go backward / forward  
\* / # Search word under cursor forward / backward  
qq : recording macro on q  
q : stop recording macro   
@q : play the q macro  
ctrl o / ctrl i : jump list (back next)  
gd : go to def  
gf : go to file  
gx: go to url  
0 go beggining in line  
^ go to first non blank char in line  
$ eol  
gg : beggining of a file  
G : eof  
. : repeat  
= : indent  
gU : uppercase  
gu : lowercase  
past clipboard : "+p ("+ is the system clipboard)

# Surround

di' : delete inner quote  
ds' : delete surround quote  
cs' " : change surround quote to double quote  

viwS' : select inner word and surround with quote  

# Comment

gc : comment (but need to be associated with text-object or motion)
gcc : comment current line
gcG : comment until end (or gggcG)

# Moving accuratly

s : Pounce  
S : Pounce with the last search (/ register) as the input  

F : Hop backward 1 char (to (included boundaries))  
f : Hop forward 1 char  
T : Hop backward 1 char (until (excluded boundaries))  
t : Hop forward 1 char  

## Text objects

iw / ax: word  

i" : inner double quote  
it : inner tag  

iS : inner subword (camelcase)  
% : end of closing bracket  

ix / ax : html attribute (so useful)  
aa / ia : Argument text object (target)  

im / am : member (chaining) ex .Map().Bind().Bind() (so dim very userful)  

gn: next match text object (search, then cgn, then repeat with dot)  

For text object (handed by targets.vim), can use l (last = previous) or n (next) like: cil)




