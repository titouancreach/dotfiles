" vim:fdm=marker

filetype off

" Plugins -------------------------------------------- {{{
"


call plug#begin('~/.config/nvim/plugged')

Plug 'https://github.com/kien/ctrlp.vim'
Plug 'bling/vim-airline'
Plug 'scrooloose/nerdTree'
Plug 'tpope/vim-fugitive'
Plug 'jtratner/vim-flavored-markdown'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'rking/ag.vim'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'editorconfig/editorconfig-vim'
Plug 'chriskempson/base16-vim'
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'ervandew/supertab'
Plug 'w0rp/ale'
Plug 'posva/vim-vue'
Plug 'cakebaker/scss-syntax.vim'
Plug 'shmargum/vim-sass-colors'

call plug#end()

" }}}

" Miscellaneous -------------------------------------- {{{

set nowrap

"read outgoing modifictions
set autoread

"change dir if a file is opened
set autochdir

"ignore case when searching
set ignorecase

"highlight search
set hlsearch


"no indent when pasting text
set pastetoggle=<F2>

"press w!! to write in sudo
cmap w!! w !sudo tee % >/dev/null

set hidden "hide buffer instead of close it

set selection=exclusive

" Backspace problems in Windows
set backspace=2
set backspace=indent,eol,start

autocmd BufWrite *.py :%s/\s\+$//ge
autocmd BufWrite *.c :%s/\s\+$//ge
autocmd BufWrite *.cpp :%s/\s\+$//ge
autocmd BufWrite *.pas :%s/\s\+$//ge

"save cursor position for a future opening
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

set nobackup
set nowb
set noswapfile

" }}}

" Appearance ----------------------------------------- {{{

set background=dark

syntax enable

"colorscheme base16-gruvbox-dark-pale
colorscheme base16-materia

"disable sound
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"show cursor position
set ruler

"show match bracklet
set showmatch

"show the cmd
set showcmd

"256 colors terminal
let &t_Co=256

"show line number
"set number

"enable mouse
set mouse=a

"hightlight current line
set cursorline

"lines which surround the cursor
set scrolloff=3

"airline
set laststatus=2 "enabled vim airline
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
"let g:airline_theme='oceanicnext'

"enable true color (24bpp) color for the terminal
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
if (has("termguicolors"))
  set termguicolors
endif

" }}}

" Indent --------------------------------------------- {{{

set autoindent
set copyindent "use previous indent
set shiftwidth=2 "for >
set tabstop=2 "for auto indent
set softtabstop=2 "for <BS>
set shiftround "using multiples of shiftwidth"
set expandtab "using spaces

autocmd Filetype python setlocal ts=4 sw=4 sts=4

"read settings from the file i.e. /* vim: tw=60 */
set modeline

"indent tags
let g:html_indent_inctags = "html,body,head,tbody"

" }}}

" Map ------------------------------------------------ {{{

let mapleader = ","
let g:mapleader = ","

"insert filename of the file when write \fn
inoremap \fn <C-R>=expand("%:t")<CR>
"insert the date of today with \today
inoremap \today <C-R>=strftime("%d/%m/%y")<CR>

"save as root with w!!
cnoremap w!! w !sudo tee > /dev/null %

"refresh configuration
nmap <leader>s :source ~/.config/nvim/init.vim<CR>

"Change split keymap
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"completion with ctrl-space (like eclipse)
inoremap <Nul> <C-n>
inoremap <C-space> <C-n>

"fast saving
nmap <leader>w :w!<CR>
nmap <leader>q :wqa!<CR>

"// stop current search
map // :nohlsearch<CR>

"should be here by default
nnoremap Y y$ 

"ctrl-p for file, ctrl-b for buffers (can clash with tmux conf)
nmap <C-b> :CtrlPBuffer<CR>

" }}}

" Markdown ------------------------------------------- {{{

augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" }}}

" Plugin configuration ------------------------------- {{{

"use ag instead of grep in ctrlp (much faster)
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif


let g:deoplete#enable_at_startup = 1

let g:ale_linters = {
\   'javascript': ['eslint'],
\}

" }}}


