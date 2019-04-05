
" make sure that shell uses interactive paths or external commands may not be
" found
set shell=/bin/bash\ -i
set vb
set clipboard=unnamed
filetype on
filetype indent on
filetype plugin on
set nocompatible

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'jgdavey/tslime.vim'
Plug 'SirVer/ultisnips'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'groenewege/vim-less'
Plug 'plasticboy/vim-markdown'
Plug 'tpope/vim-rails'
Plug 'thoughtbot/vim-rspec'
Plug 'vim-ruby/vim-ruby'
Plug 'honza/vim-snippets'

call plug#end()

set viminfo^=!
runtime! macros/matchit.vim

let mapleader = ","
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:clang_library_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
let g:jsx_ext_required = 0

"Ctrl-P options
let g:ctrlp_reuse_window = 'netrw'

"UltiSnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

map <silent> <m-p> :cp <cr>
map <silent> <m-n> :cn <cr>


let g:rails_default_file='config/database.yml'

colo vividchalk
syntax enable

set relativenumber number
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
autocmd FileType slim setlocal list
autocmd FileType slimbars setlocal list
autocmd BufNewFile,BufRead *.slimbars set filetype=slim
autocmd BufNewFile,BufRead *.drip set filetype=ruby

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


"if exists(":Tabularize")
  map <Leader>= :Tabularize /=<CR>
  map <Leader>: :Tabularize /:<CR>
  map <Leader>ho :Tabularize /=><CR>
  map <Leader>hn :Tabularize/\w:\zs/l0l1<CR>
"endif

nmap <Leader>b :CtrlPBuffer<CR>
nmap <Leader>v :source ~/.vimrc<CR>

" Ruby comment a paragraph
map <Leader>c [m0<c-v>%I#

function! RunAllSpecs()
  execute '!echo "Running full rspec suite" && rspec && fg'
endfunction

" Adds function for formatting the current .json file
" Usage: :call FormatJSON()
function! FormatJSON() 
  :%!python -m json.tool 
endfunction
  
nmap <Leader>t :CtrlP<CR>
map <Leader>S :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>r :call RunAllSpecs()<CR>
nmap <Leader>l :call RunLastSpec()<CR>

command! Qav q|AV
let g:rspec_command = 'call Send_to_Tmux("rspec {spec}\n")'
nmap <Leader>vt <Plug>SetTmuxVars

function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

" Uses git to get list of files for ctrl-p.  Much faster.
" let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'ag %s -l --nocolor -g ""']
let g:ctrlp_use_caching = 0

" Save current file as sudo
cmap w!! %!sudo tee > /dev/null %

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
"  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
