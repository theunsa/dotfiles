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

" bind Ctrl+<movement> keys to move around the windows, instead of using
" Ctrl+w + <movement>.
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

" Easier moving between buffers
map <Leader>p <esc>:bp<cr>
map <Leader>n <esc>:bn<cr>
map <Leader># <esc>:b#<cr>

" Cursor jumps to next row when long lines are wrapped
nnoremap j gj
nnoremap k gk

" Stupid shift key fixes
cmap W w
cmap WQ wq
cmap wQ wq
cmap Q q
cmap Tabe tabe

" Easier indentation of code blocks
" Try to go into visual mode (v), thenselect several lines of code here and
" then press ``>`` several times.
vnoremap < <gv
vnoremap > >gv

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
au InsertLeave * match ExtraWhitespace /\s\+$/

" Color scheme
" TODO: Add this to install script
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

" Always use spaces (NEVER use tabs)
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

" Python folding
" TODO: review this and add to install script if folding is useful
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

" " Powerline
" Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
" set laststatus=2 " Always display the statusline in all windows
" set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
" " Fix terminal timeout when pressing escape (i.e. getting rid of delay after ESC
" " is pressed to leave insert mode in the terminal)
" if ! has('gui_running')
"     set ttimeoutlen=10
"     augroup FastEscape
"         autocmd!
"         au InsertEnter * set timeoutlen=0
"         au InsertLeave * set timeoutlen=1000
"     augroup END
" endif

" Airline (testing out to replace Powerline ... no Python dep)
Plugin 'bling/vim-airline'
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
let g:airline_theme='wombat'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#exclude_preview = 1

" GitGutter - A Vim plugin which shows a git diff in the gutter (sign column) and
" stages/reverts hunks.
Plugin 'airblade/vim-gitgutter'

" Code completion
Plugin 'Valloric/YouCompleteMe'
let g:ycm_autoclose_preview_window_after_completion=1
nnoremap <leader>G :YcmCompleter GoTo<CR>
nnoremap <leader>g :YcmCompleter GoToDefinition<CR>
nnoremap <leader>d :YcmCompleter GoToDeclaration<CR>

" Ctrl-P fuzzy file finder
Plugin 'kien/ctrlp.vim.git'
let g:ctrlp_max_height = 30
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir = '~/.vim/ctrlp-cache'
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

" TComment for easy add and remove of comments
" Default shortcut is 'gc'
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

" " Mini buffers list
" Plugin 'fholgado/minibufexpl.vim'
" (Airline might replace this ... testing it out ... 9 Nov 2015)

" Ack search
Plugin 'mileszs/ack.vim'
set grepprg=ack " replace the default grep program with ack
nmap <leader>a <Esc>:Ack!

" Undo history
Plugin 'sjl/gundo.vim'

" List of tasks
" TODO: Review this
" Plugin 'vim-scripts/TaskList.vim'

" Sidebar with tags of file
Plugin 'majutsushi/tagbar'
noremap <F12> :TagbarToggle<CR>
inoremap <F12> <ESC> :TagbarToggle<CR>
" noremap <leader>t :TagbarToggle<cr>
" inoremap <leader>t :TagbarToggle<cr>
" let g:tagbar_map_togglesort=0

" File navigation
Plugin 'vim-scripts/The-NERD-tree'
nnoremap <leader>n :NERDTreeToggle<cr>

" Vim and tmux together in harmony
Plugin 'christoomey/vim-tmux-navigator'

" Emmet like (HTML editing) support for vim
Plugin 'mattn/emmet-vim'

" Formatting for js
Plugin 'pangloss/vim-javascript'

" JSHint
" TODO: review this
" (Needs jshint: npm install -g jshint)
Plugin 'walm/jshint.vim'

" Syntax checking
" Plugin 'scrooloose/syntastic.git'
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
"
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" TA: Syntastic is bit of an overkill for now while I'm mostly coding in Python

" Flake8 syntax checking
Plugin 'nvie/vim-flake8'

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


" TODO: Theme to look at later
" https://github.com/d11wtq/tomorrow-theme-vim
