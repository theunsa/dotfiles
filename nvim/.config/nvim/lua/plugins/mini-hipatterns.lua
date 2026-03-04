return {
  {
    "nvim-mini/mini.hipatterns",
    opts = function(_, opts)
      opts = opts or {}
      opts.tailwind = vim.tbl_deep_extend("force", opts.tailwind or {}, {
        enabled = false,
      })
      return opts
    end,
  },
}
