return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Obsidian",
      },
    },
    picker = {
      name = "fzf-lua",
    },
    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
    },
    completion = {
      nvim_cmp = false, -- using blink.cmp
      min_chars = 2,
    },
    -- Let render-markdown.nvim handle UI
    ui = { enable = false },
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's note" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
  },
}
