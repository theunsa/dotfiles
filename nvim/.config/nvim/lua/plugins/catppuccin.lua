return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    priority = 1000,
    opts = function(_, opts)
      -- 1. Check for Ghostty's unique resource directory
      -- 2. Or check if the original terminal was Ghostty before tmux started
      local is_ghostty = os.getenv("GHOSTTY_RESOURCES_DIR") ~= nil or os.getenv("GHOSTTY_BIN_DIR") ~= nil

      -- Only enable transparency if it's Ghostty
      if is_ghostty then
        opts.transparent_background = true
      else
        opts.transparent_background = false
      end

      opts.integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      }

      return opts
    end,
  },
}
