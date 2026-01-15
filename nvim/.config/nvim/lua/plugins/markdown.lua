-- Disable markdown linting entirely
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- This clears the linters assigned to markdown
      },
    },
  },
}
