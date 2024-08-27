" ###############################
"
" VIM Plug
"
" ###############################

" Autoinstall vim-plug if it doesn't already exist

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" " Run PlugInstall if there are missing plugins
" autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"   \| PlugInstall --sync | source $MYVIMRC
" \| endif

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'chr4/nginx.vim'                   " Nginx syntax highlighting
Plug 'chr4/sslsecure.vim'
Plug 'fatih/vim-go'                     " Utils specific to editing Golang files
Plug 'godlygeek/tabular'                " Align test block based on a deliminator
Plug 'hashivim/vim-terraform'           " Autoformat anything
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'                 " Fuzzy Finder Search -> :Lines, :Buffers, etc
Plug 'lifepillar/vim-solarized8'        " Updated Solarized color scheme
Plug 'machakann/vim-highlightedyank'    " Briefly highlight yanked text
Plug 'mileszs/ack.vim'                  " Vim plugin for using Ack from within Vim
Plug 'neomake/neomake'                  " Neovim tools
Plug 'nvie/vim-flake8'                  " Python syntax checking
Plug 'plasticboy/vim-markdown'
Plug 'rust-lang/rust.vim'               " Rust specific highlighting, formatting, etc
Plug 'sebdah/vim-delve'                 " Vim Delve
Plug 'svermeulen/vim-yoink' 
Plug 'tommcdo/vim-exchange'             " Switch text in two spots
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-autoformat/vim-autoformat'    " Autoformat anything
Plug 'vim-syntastic/syntastic'          " Polyglot syntax checker
Plug 'vim-test/vim-test'                " Run tests in vim

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" ###############################
"
" VIM settings
"
" ###############################

" Use clipboard for all Yank/Put
"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
set clipboard^=unnamed
set clipboard^=unnamedplus

set number
set ignorecase  " Case insensitive search

" Live highlight sed replace changes
if exists('&inccommand')
  set inccommand=nosplit
endif

"default indent settings
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab
set autoindent
set autoread                " Automatically reread changed files without asking me
set maxmempattern=20000     " increase max memory for syntax highlighting

if has('persistent_undo')
  set undofile
  set undodir=~/.cache/vim
endif

" Set an autocommands group
augroup leviauto
    " Clear the group first
    autocmd!

    " dont wrap when editting Go files
    autocmd FileType go setlocal nowrap
    autocmd FileType c setlocal nowrap

    "jump to last cursor position when opening a file
    "dont do it when writing a commit log entry
    autocmd BufReadPost * call SetCursorPosition()

    "spell check when writing commit logs
    autocmd FileType svn,*commit* setlocal spell

    "Force Dockerfile syntax highlighting for files named Dockerfile.*
    " autocmd Filetype Dockerfile.* setlocal syntax=dockerfile
    autocmd BufNewFile,BufRead Dockerfile* set syntax=dockerfile

    " Yaml file handling
    autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab
    autocmd FileType yaml,yml setl indentkeys-=<:>

    " Terraform file handling
    " autocmd FileType tf setlocal ts=4 sts=4 sw=4 expandtab
    " autocmd FileType tf setl indentkeys-=<:>

    " Call flake8 when writing to a python file
    " autocmd BufWritePost *.py call Flake8()

    " Comment out lines in python files
    autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
    autocmd FileType python vnoremap <buffer> <localleader>c I#<esc>

    " Comment out lines in go files
    autocmd FileType go nnoremap <buffer> <localleader>c I//<esc>
    autocmd FileType go vnoremap <buffer> <localleader>c I//<esc>

augroup END

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a

" Unfold everything on load
set foldlevel=99

function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"Backup and swap, version control & undo
set nobackup
set noswapfile

let mapleader=','
let maplocalleader = "\\"

" Remove search highlight
" nnoremap <leader><space> :nohlsearch<CR>
function! s:clear_highlight()
  let @/ = ""
  call go#guru#ClearSameIds()
endfunction
nnoremap <silent> <leader><space> :<C-u>call <SID>clear_highlight()<CR>

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when moving up and down
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz

" ###############################
"
" Tabularize
"
" ###############################

" Use Tabularize to set shortcute `,aa` to align on pipes
nmap <Leader>aa :Tab /\|<CR>
vmap <Leader>aa :Tab /\|<CR>
" Use Tabularize to set shortcute `,as` to align feature file steps on
" the space after the keyword
nmap <Leader>as :Tab /^\W*[Given\|When\|Then\|And][a-zA-Z]*\zs\W/r0c0l0<CR>
vmap <Leader>as :Tab /^\W*[Given\|When\|Then\|And][a-zA-Z]*\zs\W/r0c0l0<CR>

" ###############################
"
" Solarized8
"
" ###############################

if !empty(glob('~/.vim/plugged/vim-solarized8'))
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set background=dark
    colorscheme solarized8
endif

" ###############################
"
" Exchange
"
" ###############################

" nmap <Leader>cx <Plug>(Exchange)
" vmap <leader>cx <Plug>(Exchange)

" ###############################
"
" Ack
"
" ###############################

" :Ack will jump to the first entry
" :Ack! will not jump
" This treats :Ack like :Ack!
cnoreabbrev Ack Ack!
" Enable this if you want a quick shortcut to Ack with ,a
" nnoremap <Leader>a :Ack!<Space>

" ###############################
"
" Syntastic
"
" ###############################

if !empty(glob('~/.vim/plugged/syntastic'))
    set statusline+=col:\ %c
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:syntastic_python_checkers = []
endif

" ###############################
"
" vim-go
"
" ###############################

let g:go_fmt_command = "goimports"

" ###############################
"
" vim-terraform
"
" ###############################

let g:terraform_align = 1
let g:terraform_fmt_on_save = 1

" ###############################
"
" rust.vim
"
" ###############################

let g:rustfmt_autosave = 1

" ###############################
"
" vim-yoink
"
" ###############################
nmap p <plug>(YoinkPaste_p)
nmap P <plug>(YoinkPaste_P)

nmap <c-n> <plug>(YoinkPostPasteSwapBack)
nmap <c-p> <plug>(YoinkPostPasteSwapForward)

nmap [y <plug>(YoinkRotateBack)
nmap ]y <plug>(YoinkRotateForward)

let g:yoinkMaxItems = 10
let g:yoinkAutoFormatPaste = 0
let g:yoinkIncludeDeleteOperations = 1

" ###############################
"
" Python
"
" ###############################
let g:loaded_python_provider = 0
let g:python3_host_prog="/home/levi/.pyenv/versions/py3nvim/bin/python"

" ###############################
"
" Ruby
"
" ###############################

" Disable ruby support
let g:loaded_ruby_provider = 0

" ###############################
"
" Javascript
"
" ###############################

" Disable ruby support
let g:loaded_node_provider = 0

" ###############################
"
" vim-test
"
" ###############################

let test#strategy = "neovim"
let g:test#neovim#start_normal = 1 " Prevents test results window from closing on key press
let g:test#go#runner = 'richgo'
" let g:test#go#runner = 'ginkgo'
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>
nmap <silent> <leader>l :TestLast<CR>
nmap <silent> <leader>g :TestVisit<CR>

" Automatically run tests when a file is closed
" augroup test
"   autocmd!
"   autocmd BufWrite * if test#exists() |
"     \   TestFile |
"     \ endif
" augroup END

" https://github.com/vim-test/vim-test#go
" vim-delve related
" nmap <silent> t<C-n> :TestNearest<CR>
" function! DebugNearest()
"   let g:test#go#runner = 'delve'
"   TestNearest
"   unlet g:test#go#runner
" endfunction
" nmap <silent> t<C-d> :call DebugNearest()<CR>

" """"""""""""""""""""""""""""
"
" Learn VIMscript the hard way
"
" """""""""""""""""""""""""""
" echo ">^.^<"

nnoremap <leader>- ddp
nnoremap <leader>_ ddkP
" inoremap <c-u> <esc>viwUi
" nnoremap <c-u> viwU
nnoremap <leader>ev :vsplit ~/.vimrc<cr>
nnoremap <leader>sv :source ~/.vimrc<cr>

iabbrev trail trial
iabbrev @@ levi.noecker@toyotaconnected.com

" 'Strong' h and l, moving to beginning/end of a line
nnoremap H 0
vnoremap H 0
nnoremap L $
vnoremap L g_

"Surround highlighted text with ' or "
vnoremap <leader>" <esc>`>a"<esc>`<i"<esc>
vnoremap <leader>' <esc>`>a'<esc>`<i'<esc>

" Exit insert mode if jk is pressed
inoremap jk <esc>
inoremap jj <esc>

" Remappings to force me to learn these new mappings
inoremap <esc> <nop>
nnoremap 0 <nop>
vnoremap 0 <nop>
nnoremap $ <nop>
vnoremap $ <nop>

" create a go doc comment based on the word under the cursor
function! s:create_go_doc_comment()
  norm "zyiw
  execute ":put! z"
  execute ":norm I// \<Esc>$"
endfunction
nnoremap <leader>ui :<C-u>call <SID>create_go_doc_comment()<CR>
