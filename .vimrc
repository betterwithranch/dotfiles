
" make sure that shell uses interactive paths or external commands may not be
" found
set shell=/bin/bash\ -i
set vb
set clipboard=unnamed
filetype on
filetype indent on
filetype plugin on
set nocompatible

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" vim-plug
call plug#begin()

Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'godlygeek/tabular'
Plug 'jgdavey/tslime.vim'
" Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-vividchalk'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'amadeus/vim-jsx'
Plug 'groenewege/vim-less'
Plug 'plasticboy/vim-markdown'
Plug 'tpope/vim-rails'
Plug 'thoughtbot/vim-rspec'
Plug 'vim-ruby/vim-ruby'
Plug 'honza/vim-snippets'
Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'lmeijvogel/vim-yaml-helper'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'vim-test/vim-test'
Plug 'eliba2/vim-node-inspect'
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', { 'branch': 'coq' }
Plug 'ms-jpq/coq.artifacts', { 'branch': 'artifacts' }
" Plug 'ms-jpq/cog.thirdparty', { 'branch', '3p' }
let g:coc_global_extensions = ['coc-tsserver', 'coc-solargraph']

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'deoplete-plugins/deoplete-go', { 'do': 'make'}
"let g:deoplete#enable_at_startup = 0

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

map <silent> <m-p> :cp <cr>
map <silent> <m-n> :cn <cr>

let g:rails_default_file='config/database.yml'

" ale configuration
let g:airline#extensions#ale#enabled = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_ruby_rubocop_executable = 'bundle'
" Needs neovim 0.6+. Add check to exclude when not available
" Currently disabled because the git commit prompt uses vim, not neovim
" let g:ale_use_neovim_diagnostics_api = 1
" You can disable this option too
" if you don't want linters to run on opening a file
let g:ale_lint_on_enter = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_linters = {
\  'ruby': ['rubocop'],
\  'typescript': ['eslint'],
\  'python': ['flake8'],
\}
let g:ale_fixers = {
\ 'javascript': ['prettier'],
\ 'typescript': ['prettier'],
\  }
let g:ale_fix_on_save = 1
highlight clear ALEWarning
highlight clear ALEError
let g:ale_sign_info = "⚠️"
let g:ale_sign_warning = "⚠️"
let g:ale_sign_style_warning = "⚠️"
let g:ale_sign_error = "❗️"
let g:ale_sign_style_error = "❗️"
let g:ale_python_auto_pipenv = 1
let g:ale_python_pyright_auto_pipenv = 1
highlight ALEErrorSign ctermfg=red
highlight ALEWarningSign ctermfg=yellow

" add shortcuts for navigating ale issues
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

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
" set novisualbell
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

let g:ruby_indent_assignment_style='variable'
let g:ruby_indent_hanging_elements=0

"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold


augroup myfiletypes
    autocmd!
    autocmd FileType ruby,eruby set ai sw=2 sts=2 et
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType python set ts=4 sts=4 sw=4 expandtab
augroup END

autocmd FileType python let g:python_indent = {}
autocmd FileType python let g:pyindent_open_paren = 'shiftwidth()'
autocmd FileType python let g:python_indent.continue = 'shiftwidth()'
autocmd FileType python let g:python_indent.closed_paren_align_last_line = v:false

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

nmap <Leader>b :CtrlPMRU<CR>
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
command! -nargs=+ Aapp Ack <args> --ignore-dir api_interactions
"command Aapp -nargs=+ :Ack --ignore api_interactions <args>
let g:rspec_command = 'w | call Send_to_Tmux("bundle exec rspec {spec}\n")'
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
" let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'ag %s -l --nocolor -g ""']
let g:ctrlp_use_caching = 0

" Save current file as sudo
cmap w!! %!sudo tee > /dev/null %

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  let g:ackprg = 'ag --nogroup --nocolor'

  cnoreabbrev Ag Ack

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
 let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'ag %s -l --nocolor -g ""']
"  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

let g:go_fmt_command = "goimports"
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

autocmd! CursorMoved *.yml YamlDisplayFullPath

let test#strategy = "tslime"
