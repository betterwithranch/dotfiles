
set vb
filetype on
filetype indent on
filetype plugin on
set nocompatible

set viminfo^=!
runtime! macros/matchit.vim

let mapleader = ","
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1

map <silent> <m-p> :cp <cr>
map <silent> <m-n> :cn <cr>

let g:rails_default_file='config/database.yml'

colo vividchalk
syntax enable

set nu
set nowrap

set ts=2
set bs=2
set shiftwidth=2
set cindent
set autoindent
set smarttab
set expandtab

set showmatch
set mat=5
set novisualbell
set noerrorbells

"ruby
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold


augroup myfiletypes
    autocmd!
    autocmd FileType ruby,eruby,yaml set ai sw=2 sts=2 et
augroup END

set foldmethod=indent
set foldnestmasx=10
set nofoldenable
set foldlevel=2
