return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    vim.o.autoread = true
    local opencode = require("opencode")

    -- CAPITAL A FOR AGENT
    -- Toggle TUI: <leader>AA
    vim.keymap.set({ "n", "t" }, "<leader>Ac", function()
      opencode.toggle()
    end, { desc = "OpenCode: Toggle Agent" })

    -- Ask: <leader>Aa
    vim.keymap.set({ "n", "x" }, "<leader>Aa", function()
      opencode.ask("@this: ", { submit = true })
    end, { desc = "OpenCode: Ask Agent" })

    -- Actions: <leader>Ax
    vim.keymap.set({ "n", "x" }, "<leader>Ax", function()
      opencode.select()
    end, { desc = "OpenCode: Agent Actions" })

    -- Inline Context (standard "go" doesn't use leader, so it's safe)
    vim.keymap.set({ "n", "x" }, "go", function()
      return opencode.operator("@this ")
    end, { expr = true, desc = "Add range to OpenCode" })
  end,
}
