return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>a", nil, desc = "AI" },
      {
        "<leader>ax",
        function()
          Snacks.terminal.toggle({ "codex", "--yolo" }, {
            cwd = vim.fn.getcwd(),
            win = {
              position = "right",
            },
          })
        end,
        desc = "Codex YOLO",
      },
    },
  },
}
