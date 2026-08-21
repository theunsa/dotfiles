return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- Dispatch these mappings to tmux or Herdr instead of letting the tmux
    -- plugin claim them unconditionally.
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    local directions = {
      ["<C-h>"] = { window = "h", herdr = "left", tmux = "Left" },
      ["<C-j>"] = { window = "j", herdr = "down", tmux = "Down" },
      ["<C-k>"] = { window = "k", herdr = "up", tmux = "Up" },
      ["<C-l>"] = { window = "l", herdr = "right", tmux = "Right" },
    }

    for key, direction in pairs(directions) do
      vim.keymap.set("n", key, function()
        local previous_window = vim.api.nvim_get_current_win()
        vim.cmd("wincmd " .. direction.window)

        if vim.api.nvim_get_current_win() ~= previous_window then
          return
        end

        if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
          local herdr = vim.env.HERDR_BIN_PATH or "herdr"
          vim.fn.system({
            herdr,
            "pane",
            "focus",
            "--direction",
            direction.herdr,
            "--pane",
            vim.env.HERDR_PANE_ID,
          })
        elseif vim.env.TMUX and vim.env.TMUX ~= "" then
          vim.cmd("TmuxNavigate" .. direction.tmux)
        end
      end, { silent = true, noremap = true, desc = "Navigate " .. direction.herdr .. " (Neovim/multiplexer)" })
    end

    vim.keymap.set("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", {
      silent = true,
      desc = "Navigate to previous tmux pane",
    })
  end,
}
