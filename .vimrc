
set shell=/bin/bash\ -i
set vb
filetype on
filetype indent on
filetype plugin on
set nocompatible

let g:pathogen_disabled = []
"call add(g:pathogen_disabled, 'vim-spec')

execute pathogen#infect()
execute pathogen#helptags()

set viminfo^=!
runtime! macros/matchit.vim

let mapleader = ","
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:clang_library_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
let g:rspec_command = "ls"

"Ctrl-P options
let g:ctrlp_reuse_window = 'netrw'

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
set ruler

set showmatch
set mat=5
set novisualbell
set noerrorbells
set cursorline
set splitright  "open vertical splits on the right side

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
set foldnestmax=10
set nofoldenable
set foldlevel=2

" put useful info in status bar
set laststatus=2
set statusline=%F%m%r%h%w\ [%l,%c]\ [%L,%p%%]

" set up some custom colors
highlight StatusLineNC ctermbg=238 ctermfg=0
highlight StatusLine   ctermbg=240 ctermfg=12

" change status bar based on current mode
if version >= 700
  au InsertEnter * hi StatusLine ctermfg=235 ctermbg=2
  au InsertLeave * hi StatusLine ctermbg=240 ctermfg=12
endif


if exists(":Tabularize")
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>
  nmap <Leader>a> :Tabularize /=><CR>
endif

nmap <Leader>b :CtrlPBuffer<CR>
nmap <Leader>v :so ~/.vimrc<CR>

function! RunAllSpecs()
  execute '!echo "Running full rspec suite" && rspec && fg'
endfunction

map <Leader>r :call RunAllSpecs()<CR>
map <Leader>S :call RunCurrentSpecFile()<CR>
