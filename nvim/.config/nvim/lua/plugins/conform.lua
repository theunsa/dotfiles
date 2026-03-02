return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      vue = { "oxfmt" },
      javascript = { "oxfmt" },
      typescript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      json = { "oxfmt" },
      jsonc = { "oxfmt" },
      html = { "oxfmt" },
      css = { "oxfmt" },
      scss = { "oxfmt" },
      less = { "oxfmt" },
      yaml = { "oxfmt" },
      markdown = { "oxfmt" },
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
  },
}
