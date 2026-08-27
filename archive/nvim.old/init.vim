filetype plugin on

function! Cond(Cond, ...)
  let opts = get(a:000, 0, {})
  return a:Cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

call plug#begin('~/.config/nvim/plugged')

" motion / general text editing plugins
Plug 'tpope/vim-surround'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'wellle/targets.vim'
Plug 'Townk/vim-autoclose'
Plug 'easymotion/vim-easymotion', Cond(!exists('g:vscode'))
" use VSCode easymotion when in VSCode mode
Plug 'asvetliakov/vim-easymotion', Cond(exists('g:vscode'), { 'as': 'vsc-easymotion' })
Plug 'tpope/vim-commentary'

" Apperance plugins
Plug 'scrooloose/nerdTree'
Plug 'joshdick/onedark.vim'
Plug 'mhartington/oceanic-next'
Plug 'tomasiser/vim-code-dark'
Plug 'itchyny/lightline.vim'
Plug 'Luxed/ayu-vim'

" language specific plugins
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'posva/vim-vue'
Plug 'cakebaker/scss-syntax.vim'
Plug 'shmargum/vim-sass-colors'
Plug 'prettier/vim-prettier'
Plug 'jtratner/vim-flavored-markdown'
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'
Plug 'OrangeT/vim-csharp'

" git
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

"other
Plug 'github/copilot.vim'


call plug#end()

set wrap

" let the plugins to redraw (gitgutter...)
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

" fix endline
set fileformat=unix

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

"256 colors terminal
let &t_Co=256

set background=dark

syntax enable

let ayucolor="mirage"
" colorscheme ayu

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

"don't show line number
set nonumber

"enable mouse
"set mouse=a

"hightlight current line
set cursorline

"lines which surround the cursor
set scrolloff=3

"enable true color (24bpp) color for the terminal
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
if (has("termguicolors"))
  set termguicolors
endif

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set lcs+=space:·
set list

" indent

set autoindent
set copyindent "use previous indent

set shiftwidth=4 "for >
set tabstop=4 "for auto indent
set softtabstop=4 "for <BS>

"using multiples of shiftwidth"
set shiftround

set expandtab "using spaces

autocmd Filetype python setlocal ts=4 sw=4 sts=4

"indent tags
let g:html_indent_inctags = "html,body,head,tbody"


" Map

let mapleader = ","
let g:mapleader = ","

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

augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

let g:EasyMotion_smartcase = 1

nmap s <Plug>(easymotion-f2)
vmap s <Plug>(easymotion-f2)
nmap S <Plug>(easymotion-F2)
vmap S <Plug>(easymotion-F2)

nmap f <Plug>(easymotion-fl)
vmap f <Plug>(easymotion-fl)
nmap F <Plug>(easymotion-Fl)
vmap F <Plug>(easymotion-Fl)

nmap t <Plug>(easymotion-tl)
vmap t <Plug>(easymotion-tl)
nmap T <Plug>(easymotion-Tl)
vmap T <Plug>(easymotion-Tl)

let g:NERDSpaceDelims = 1
let NERDTreeShowBookmarks=1

autocmd User targets#mappings#user call targets#mappings#extend({
    \ 'a': {'argument': [{'o': '[{([]', 'c': '[])}]', 's': ','}]}
    \ })

let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

" }}}

" use AG instead of find (this respects the .gitignore) and it's fast :) :)
let $FZF_DEFAULT_COMMAND = 'ag -g ""'

au BufNewFile,BufRead,BufReadPost *.jsx set filetype=javascript.jsx
au BufNewFile,BufRead,BufReadPost *.tsx set filetype=typescript.tsx

set signcolumn=yes

" Don't show insert in the bottom bar since it's already display by vim
" lightline
set noshowmode

set ffs=unix,dos

nnoremap j gj
nnoremap k gk

set ff=unix
