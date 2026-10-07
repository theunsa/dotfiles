-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Keep these here: mappings installed by an eager plugin's config are later
-- overwritten by LazyVim's default Ctrl-H/J/K/L window mappings.
local directions = {
  ["<C-h>"] = { window = "h", herdr = "left" },
  ["<C-j>"] = { window = "j", herdr = "down" },
  ["<C-k>"] = { window = "k", herdr = "up" },
  ["<C-l>"] = { window = "l", herdr = "right" },
}

local function focus_herdr(direction)
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
  end
end

for key, direction in pairs(directions) do
  local function navigate()
    local previous_window = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. direction.window)

    if vim.api.nvim_get_current_win() == previous_window then
      focus_herdr(direction)
    end
  end

  -- Traverse editor splits first, then cross into Herdr at the edge.
  -- Lua callbacks preserve the current editor mode when running navigation.
  vim.keymap.set({ "n", "i", "x", "s", "o", "t", "c" }, key, navigate, {
    silent = true,
    noremap = true,
    desc = "Navigate " .. direction.herdr .. " (Neovim/Herdr)",
  })
end
