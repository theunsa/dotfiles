return {
  {
    "coder/claudecode.nvim",
    opts = function(_, opts)
      opts.terminal_cmd = "~/.claude/local/claude"

      -- CUSTOMIZE THE UI: Make the Claude window wider or on the left
      opts.terminal = {
        split_side = "right",
        --split_width_percentage = 0.45, -- Use 45% of the screen
      }

      -- BEHAVIOR: Auto-focus the chat after sending code
      opts.focus_after_send = true

      return opts
    end,
  },
}
