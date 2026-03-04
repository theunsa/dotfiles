return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>A", nil, desc = "AI/Codex" },
      {
        "<leader>Ac",
        function()
          Snacks.terminal.toggle({ "codex" }, {
            cwd = vim.fn.getcwd(),
            win = {
              position = "right",
            },
          })
        end,
        desc = "Toggle Codex",
      },
      {
        "<leader>Ay",
        function()
          Snacks.terminal.toggle({ "codex", "--yolo" }, {
            cwd = vim.fn.getcwd(),
            win = {
              position = "right",
            },
          })
        end,
        desc = "Toggle Codex Yolo",
      },
    },
  },
}
