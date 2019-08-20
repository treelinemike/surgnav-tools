set nocompatible
filetype off                  " required

" HOW TO GET AUTOSAVE WORKING:
" first install VUNDLE in home directory: C:\users\f002r5k
" will create .vim folder containing a folder called bundle
" then put this .vimrc in home directory
" finally start vim and run :PluginInstall
"
" See also:
" https://github.com/vim-scripts/vim-auto-save

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin '907th/vim-auto-save'



" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

syntax on
colorscheme desert
:inoremap <F5> <C-R>=strftime("%c>> ")<CR>
:nmap <F5> i<F5>
":nmap <c-s> :w<CR>
":imap <c-s> <Esc>:w<CR>a


let g:auto_save_events = ["InsertLeave", "TextChanged","TextChangedI"]
let g:auto_save = 1  " enable AutoSave on Vim startup
