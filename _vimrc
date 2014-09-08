" ============================================================================
" Theuns Alberts .vimrc
" ============================================================================
" Based on .vimrc files from various sources:
" - https://github.com/mbrochh/vim-as-a-python-ide
" - http://nvie.com/posts/how-i-boosted-my-vim/
" - https://github.com/mitsuhiko/dotfiles
" - http://sontek.net/blog/detail/turning-vim-into-a-modern-python-ide
" ============================================================================

" This must be first, because it changes other options as side effect
set nocompatible

" Automatic reloading of .vimrc
autocmd! bufwritepost ~/.vimrc source %
" au BufWritePost .vimrc so ~/.vimrc

" Better copy & paste
" When you want to paste large blocks of code into vim, press F2 before you
" paste. At the bottom you should see ``-- INSERT (paste) --``.
set pastetoggle=<F2>

" Rebind <Leader> key
let mapleader = ","

" Auto change into the directory of the file of the buffer 
set autochdir

" Set terminal title to reflect name of current buffer
set title

" Bind nohl
" Removes highlight of your last search
" ``<C>`` stands for ``CTRL`` and therefore ``<C-n>`` stands for ``CTRL+n``
"" noremap <C-n> :nohl<cr>
"" vnoremap <C-n> :nohl<cr>
"" inoremap <C-n> :nohl<cr>


" Quicksave command
nnoremap <cr> <esc>:w<cr>

" Quick quit command
"" noremap <Leader>e :quit<cr>  " Quit current window
"" noremap <Leader>E :qa!<cr>   " Quit all windows


" bind Ctrl+<movement> keys to move around the windows, instead of using Ctrl+w + <movement>
" Every unnecessary keystroke that can be saved is good for your health :)
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-h> <C-w>h


" easier moving between tabs
"" map <Leader>n <esc>:tabprevious<cr>
"" map <Leader>m <esc>:tabnext<cr>
map <Leader>p <esc>:bp<cr>
map <Leader>n <esc>:bn<cr>

" Cursor jumps to next row when long lines are wrapped
nnoremap j gj
nnoremap k gk

" map sort function to a key
"" vnoremap <Leader>s :sort<cr>


" easier moving of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation


" Show whitespace
" MUST be inserted BEFORE the colorscheme command
"" autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"" au InsertLeave * match ExtraWhitespace /\s\+$/


" Color scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O wombat256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
set t_Co=256
color wombat256mod


" Enable syntax highlighting
" You need to reload this file for the change to apply
filetype off
filetype plugin indent on
syntax on


" Showing line numbers and length
set number  " show line numbers
set tw=79   " width of document (used by gd)
set wrap  " wrap long lines on load
if version >= 703
    set colorcolumn=80
endif
highlight ColorColumn ctermbg=233


" Remember more commands and search history
set history=500
set undolevels=500

" Don't beep
set visualbell
set noerrorbells


" Real programmers don't use TABs but spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab


" Make search case insensitive
set hlsearch
set incsearch
set ignorecase
set smartcase


" Disable stupid backup and swap files - they trigger too many events
" for file system watchers
set nobackup
set nowritebackup
set noswapfile

" Use Q for formatting the current paragraph (or selection)
vmap Q gq
nmap Q gqap


" Setup Pathogen to manage your plugins
" mkdir -p ~/.vim/autoload ~/.vim/bundle
" curl -so ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim
" Now you can install any plugin into a .vim/bundle/plugin-name/ folder
"" call pathogen#infect()


" ============================================================================
" Python IDE Setup
" ============================================================================


"" inoremap <silent><C-j> <C-R>=OmniPopup('j')<cr>
"" inoremap <silent><C-k> <C-R>=OmniPopup('k')<cr>


" Python folding
" mkdir -p ~/.vim/ftplugin
" wget -O ~/.vim/ftplugin/python_editing.vim http://www.vim.org/scripts/download_script.php?src_id=5492
"" set nofoldenable

" ==========================================================
" Vundle
" ==========================================================
" Configure Vundle
filetype off " Required by Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
" Let Vundle manage Vundle (required!)
Bundle 'gmarik/vundle'

" ==========================================================
" My Bundles
" ==========================================================
" Jedi Vim
Bundle 'davidhalter/jedi-vim'
autocmd FileType python setlocal completeopt-=preview "disable docstring popup
let g:jedi#usages_command = "<leader>z"
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
" Better navigating through omnicomplete option list
" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
set completeopt=longest,menuone
function! OmniPopup(action)
    if pumvisible()
        if a:action == 'j'
            return "\<C-N>"
        elseif a:action == 'k'
            return "\<C-P>"
        endif
    endif
    return a:action
endfunction

" Powerline
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
" Fix terminal timeout when pressing escape (i.e. getting rid of delay after ESC
" is pressed to leave insert mode in the terminal)
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

" Ctrl-P fuzzy file finder
Bundle 'kien/ctrlp.vim.git'
nnoremap <leader>f :CtrlP<cr>
nnoremap <leader>F :CtrlPCurWD<cr>
let g:ctrlp_max_height = 30
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" Code snippets
Bundle 'ervandew/snipmate.vim'

" Brackets
Bundle 'tpope/vim-surround'

" Insert completion
" Bundle 'ervandew/supertab'

" Mini buffers list
Bundle 'sontek/minibufexpl.vim'

" Ack search
Bundle 'mileszs/ack.vim'
set grepprg=ack " replace the default grep program with ack
nmap <leader>a <Esc>:Ack!

" Undo history
Bundle 'sjl/gundo.vim'

" List of tasks
" Bundle 'vim-scripts/TaskList.vim'

" Sidebar with tags of file
Bundle 'majutsushi/tagbar'
map <leader>t :TagbarToggle<cr>

" File navigation
Bundle 'vim-scripts/The-NERD-tree'
nnoremap <leader>n :NERDTreeToggle<cr>

" Vim and tmux together in harmony
Bundle 'christoomey/vim-tmux-navigator'

" Emmet like (HTML editing) support for vim
Bundle "mattn/emmet-vim"

" Hide matches on <leader>space
nnoremap <leader><space> :nohlsearch<cr>
set hidden " Hide buffers instead of closing them

" Ignore these files when completing
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.tar.gz " MacOSX/Linux
set wildignore+=*_build/*
set wildignore+=*/coverage/*
set wildignore+=*.o,*.obj,.git,*.pyc
set wildignore+=eggs/**
set wildignore+=*.egg-info/**
set wildignore+=*/pip-cache/**
