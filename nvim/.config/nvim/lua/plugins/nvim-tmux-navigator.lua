return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- lua/config/keymaps.lua owns navigation after LazyVim's defaults load.
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
