return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>a", nil, desc = "AI" },
      {
        "<leader>ao",
        function()
          Snacks.terminal.toggle({ "opencode", "--model", "openrouter/moonshotai/kimi-k2.6" }, {
            cwd = vim.fn.getcwd(),
            env = {
              OPENCODE_PERMISSION = [[{"*":"allow"}]],
              OPENROUTER_API_KEY = vim.env.OPENROUTER_API_KEY,
            },
            win = {
              position = "right",
            },
          })
        end,
        desc = "OpenCode YOLO (Kimi K2.6)",
      },
    },
  },
}
