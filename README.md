My personal dotfiles for linux home folder.

install
-------
Get the dotfiles with:

	git clone https://github.com/theunsa/dotfiles ~/dotfiles
 
To install:

	cd ~/dotfiles
	./install.sh

Note: Rake is required to setup command-t

vim
----
Followed the instructions at http://sontek.net/blog/detail/turning-vim-into-a-modern-python-ide with a few customisations and changes of my own including:
* Used CtrlP instead of command-t (no Rake dependency needed)
* Added submodule vcscommit 

Submodules were added as follows:
	git submodule add http://github.com/tpope/vim-fugitive.git vim/bundle/fugitive
	git submodule add https://github.com/msanders/snipmate.vim.git vim/bundle/snipmate
	git submodule add https://github.com/tpope/vim-surround.git vim/bundle/surround
	git submodule add https://github.com/tpope/vim-git.git vim/bundle/git
	git submodule add https://github.com/ervandew/supertab.git vim/bundle/supertab
	git submodule add https://github.com/sontek/minibufexpl.vim.git vim/bundle/minibufexpl
	git submodule add https://github.com/mitechie/pyflakes-pathogen.git vim/bundle/pyflakes-pathogen
	git submodule add https://github.com/mileszs/ack.vim.git vim/bundle/ack
	git submodule add https://github.com/sjl/gundo.vim.git vim/bundle/gundo
	git submodule add https://github.com/fs111/pydoc.vim.git vim/bundle/pydoc
	git submodule add https://github.com/vim-scripts/pep8.git vim/bundle/pep8
	git submodule add https://github.com/alfredodeza/pytest.vim.git vim/bundle/py.test
	git submodule add https://github.com/reinh/vim-makegreen vim/bundle/makegreen
	git submodule add https://github.com/vim-scripts/TaskList.vim.git vim/bundle/tasklist
	git submodule add https://github.com/vim-scripts/The-NERD-tree.git vim/bundle/nerdtree
	git submodule add https://github.com/sontek/rope-vim.git vim/bundle/ropevim
	git submodule add https://github.com/kien/ctrlp.vim.git vim/bundle/ctrlp.vim
	git submodule add https://github.com/vim-scripts/vcscommand.vim.git vim/bundle/vcscommand.vim
	git submodule init
	git submodule update
	git submodule foreach git submodule init
	git submodule foreach git submodule update
