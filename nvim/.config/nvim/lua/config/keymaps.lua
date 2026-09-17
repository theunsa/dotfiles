-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Keep these here: mappings installed by an eager plugin's config are later
-- overwritten by LazyVim's default Ctrl-H/J/K/L window mappings.
local directions = {
  ["<C-h>"] = { window = "h", herdr = "left", tmux = "Left" },
  ["<C-j>"] = { window = "j", herdr = "down", tmux = "Down" },
  ["<C-k>"] = { window = "k", herdr = "up", tmux = "Up" },
  ["<C-l>"] = { window = "l", herdr = "right", tmux = "Right" },
}

local function focus_multiplexer(direction)
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
end

for key, direction in pairs(directions) do
  local function navigate()
    local previous_window = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. direction.window)

    if vim.api.nvim_get_current_win() == previous_window then
      focus_multiplexer(direction)
    end
  end

  -- Traverse editor splits first, then cross into Herdr/tmux at the edge.
  -- Lua callbacks preserve the current editor mode when running navigation.
  vim.keymap.set({ "n", "i", "x", "s", "o", "t", "c" }, key, navigate, {
    silent = true,
    noremap = true,
    desc = "Navigate " .. direction.herdr .. " (Neovim/multiplexer)",
  })
end

vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", {
  silent = true,
  desc = "Navigate to previous tmux pane",
})
