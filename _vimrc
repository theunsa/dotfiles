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

" bind Ctrl+<movement> keys to move around the windows, instead of using Ctrl+w + <movement>
" Every unnecessary keystroke that can be saved is good for your health :)
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

" Open new split panes to right and bottom, which feels more natural than Vim’s
" default
set splitbelow
set splitright

" Making it so ; works like : for commands. Saves typing and
" eliminates :W style typos due to lazy holding shift.
nnoremap ; :

" Quicksave command
nnoremap <cr> <esc>:w<cr>

" Quick quit command
"" noremap <Leader>e :quit<cr>  " Quit current window
"" noremap <Leader>E :qa!<cr>   " Quit all windows

" easier moving between tabs
"" map <Leader>n <esc>:tabprevious<cr>
"" map <Leader>m <esc>:tabnext<cr>
map <Leader>p <esc>:bp<cr>
map <Leader>n <esc>:bn<cr>

" Cursor jumps to next row when long lines are wrapped
nnoremap j gj
nnoremap k gk

" Stupid shift key fixes
cmap W w                        
cmap WQ wq
cmap wQ wq
cmap Q q
cmap Tabe tabe

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
syntax on


" Showing line numbers and length
set number  " show line numbers
set tw=79   " width of document (used by gd)
set wrap  " wrap long lines on load
set colorcolumn=80
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

" Enable mouse scrolling
set mouse=a


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
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Let Vundle manage Vundle (required!)
Plugin 'gmarik/Vundle.vim'

" ==========================================================
" My Vundle Plugins
" ==========================================================
" Jedi Vim
"Plugin 'davidhalter/jedi-vim'
"autocmd FileType python setlocal completeopt-=preview "disable docstring popup
"let g:jedi#usages_command = "<leader>z"
"let g:jedi#popup_on_dot = 0
"let g:jedi#popup_select_first = 0
"" Better navigating through omnicomplete option list
"" See http://stackoverflow.com/questions/2170023/how-to-map-keys-for-popup-menu-in-vim
"set completeopt=longest,menuone
"function! OmniPopup(action)
"    if pumvisible()
"        if a:action == 'j'
"            return "\<C-N>"
"        elseif a:action == 'k'
"            return "\<C-P>"
"        endif
"    endif
"    return a:action
"endfunction

" Powerline
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
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
Plugin 'kien/ctrlp.vim.git'
" TA: These are overriding easymotion (try to do without them for a while)
" nnoremap <leader>f :CtrlP<cr>
" nnoremap <leader>F :CtrlPCurWD<cr>
let g:ctrlp_max_height = 30
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" Git tools
Plugin 'tpope/vim-fugitive'

" Easy motion
Plugin 'Lokaltog/vim-easymotion'
map <Leader> <Plug>(easymotion-prefix)

"TComment
Plugin 'tomtom/tcomment_vim'

" Code snippets
" Track the engine.
Plugin 'SirVer/ultisnips'
" Snippets are separated from the engine.
Plugin 'honza/vim-snippets'
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" Let :UltiSnipsEdit split the window.
let g:UltiSnipsEditSplit="vertical"
"set runtimepath+=~/.vim/bundle/vim-snippets/UltiSnips


" Brackets
Plugin 'tpope/vim-surround'

" Insert completion
Plugin 'ervandew/supertab'

" Mini buffers list
Plugin 'sontek/minibufexpl.vim'

" Ack search
Plugin 'mileszs/ack.vim'
set grepprg=ack " replace the default grep program with ack
nmap <leader>a <Esc>:Ack!

" Undo history
Plugin 'sjl/gundo.vim'

" List of tasks
" Plugin 'vim-scripts/TaskList.vim'

" Sidebar with tags of file
Plugin 'majutsushi/tagbar'
map <leader>t :TagbarToggle<cr>

" File navigation
Plugin 'vim-scripts/The-NERD-tree'
nnoremap <leader>n :NERDTreeToggle<cr>

" Vim and tmux together in harmony
Plugin 'christoomey/vim-tmux-navigator'

" Code completion
Plugin 'Valloric/YouCompleteMe'

" Emmet like (HTML editing) support for vim
Plugin 'mattn/emmet-vim'

" Formatting for js
Plugin 'pangloss/vim-javascript'

" JSHint
" (Needs jshint: npm install -g jshint)
Plugin 'walm/jshint.vim'

" Python-mode for python development
"TA-Temp disable:Plugin 'klen/python-mode'
"set nofoldenable

" ==========================================================
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" ==========================================================


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


" TA:Theme to look at later
" https://github.com/d11wtq/tomorrow-theme-vim
