" vim:fdm=marker

filetype plugin on

" Plugins -------------------------------------------- {{{
"


call plug#begin('~/.config/nvim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'scrooloose/nerdTree'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'tpope/vim-fugitive'
Plug 'jtratner/vim-flavored-markdown'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'w0rp/ale'
Plug 'posva/vim-vue'
Plug 'cakebaker/scss-syntax.vim'
Plug 'shmargum/vim-sass-colors'
Plug 'prettier/vim-prettier'
Plug 'scrooloose/nerdcommenter'

Plug 'jnurmine/Zenburn'
Plug 'joshdick/onedark.vim'
Plug 'dracula/vim'
Plug 'mhartington/oceanic-next'
Plug 'tomasiser/vim-code-dark'

Plug 'michaeljsmith/vim-indent-object'

Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'

Plug 'airblade/vim-gitgutter'
"Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

Plug 'kyuhi/vim-emoji-complete' " 😄

Plug 'elmcast/elm-vim'


Plug 'leafgarland/typescript-vim'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'ayu-theme/ayu-vim'

Plug 'markonm/traces.vim'

" more text objects (argument is "a")
Plug 'wellle/targets.vim' 


Plug 'Townk/vim-autoclose'

" Should be loaded at the end
" Use patched nerd font (thanks me later for this link: https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/LiberationMono/complete/Literation%20Mono%20Nerd%20Font%20Complete%20Mono.ttf)
Plug 'ryanoasis/vim-devicons'

call plug#end()

" }}}

" Miscellaneous -------------------------------------- {{{
set wrap


" let the plugins to redraw (ale, gitgutter...)
set updatetime=100

"read outgoing modifictions
set autoread

"change dir if a file is opened
" set autochdir

"ignore case when searching
set ignorecase

set lazyredraw

"no highlight search
"set hlsearch
set nohlsearch


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

set undofile
set undodir=~/.vim/undodir

" }}}

" Appearance ----------------------------------------- {{{

set background=dark

syntax enable

colorscheme OceanicNext



"disable sound
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"show cursor position
set ruler

"show matching brackets
set showmatch

"show the cmd
set showcmd

"256 colors terminal
let &t_Co=256

"don't show line number
set nonumber

"enable mouse
set mouse=a

"hightlight current line
set cursorline

"lines which surround the cursor
set scrolloff=3

"airline
set laststatus=2 "enabled vim airline
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
let g:airline_theme='oceanicnext'

"enable true color (24bpp) color for the terminal
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
if (has("termguicolors"))
  set termguicolors
endif

" }}}

" Indent --------------------------------------------- {{{

set autoindent
set copyindent "use previous indent

" At Klaxoon, we use 4, but I'm too lazy to have 2 vimrc dependings if I'm at
" home or not :'(
 set shiftwidth=4 "for >
 set tabstop=4 "for auto indent
 set softtabstop=4 "for <BS>

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

" Change window in the terminal as usual
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-w> <C-\><C-n><C-w>l

noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$


" for unimpaired
nmap < [
nmap > ]
omap < [
omap > ]
xmap < [
xmap > ]

" Go to normal mode when typing jj (works in the neovim terminal mode)
imap jj <Esc>
tnoremap jj <C-\><C-n>


" move line up and down in visual mode
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Close all buffer exepted the current one (clean buffers)
nnoremap <leader><leader>c :bd\|e#<CR>


"insert filename of the file when write \fn

inoremap \fn <C-R>=expand("%:t")<CR>
"insert the date of today with \today

inoremap \today <C-R>=strftime("%d/%m/%y")<CR>

" Add the issue number if contained in the branch
inoremap \issue <C-R>=system('git rev-parse --abbrev-ref HEAD \| grep -Eo "[0-9]+" \| tr -d "\n"')<CR>

"save as root with w!!
cnoremap w!! w !sudo tee > /dev/null %

"refresh configuration
nmap <leader>s :source ~/.config/nvim/init.vim<CR>

"Change split keymap
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

"// stop current search
map // :nohlsearch<CR>

"should be here by default
nnoremap Y y$ 

nmap <leader>n :NERDTreeFind<CR>
nmap <leader>m :NERDTreeToggle<CR>

" fuzzy finding
nnoremap <C-p> :GFiles<cr>
nnoremap <C-b> :Buffers<cr>
nnoremap <C-g> :History<cr>


" }}}

" Markdown ------------------------------------------- {{{

augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" }}}

" Plugin configuration ------------------------------- {{{
"

" Add a space after comments // 
let g:NERDSpaceDelims = 1
let NERDTreeShowBookmarks=1

autocmd User targets#mappings#user call targets#mappings#extend({
    \ 'a': {'argument': [{'o': '[{([]', 'c': '[])}]', 's': ','}]}
    \ })


" Enable airline for the tabs
let g:airline#extensions#tabline#enabled = 1

" Enable error in the status line (like vscode)
let g:airline#extensions#ale#enabled = 1


" Linter / Fixer (javascript)
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint']
\}

let g:ale_fixers = {
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint']
\}

" put the errors in the quickfix list 
let g:ale_set_quickfix = 1

let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_lint_on_enter = 0

let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1


let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

" }}}

au BufNewFile,BufRead,BufReadPost *.jsx set syntax=javascript.jsx
