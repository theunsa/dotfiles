return {
  enabled = false,
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      http = {
        zen = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "zen",
            formatted_name = "OpenCode Zen",
            env = {
              url = "https://api.opencode.ai",
              api_key = "OPENCODE_API_KEY",
              chat_url = "/v1/chat/completions",
              models_endpoint = "", -- Disable model fetching
            },
            schema = {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                default = "opencode/minimax-m2.1",
                choices = {
                  "opencode/minimax-m2.1",
                  "opencode/gemini-3-flash",
                  "opencode/grok-code-fast-1",
                  "opencode/glm-4.7",
                },
                desc = "The model to use for chat completions",
              },
            },
            handlers = {
              -- Override get_models to return static list (disable API fetching)
              get_models = function()
                return {
                  "opencode/minimax-m2.1",
                  "opencode/gemini-3-flash",
                  "opencode/grok-code-fast-1",
                  "opencode/glm-4.7",
                }
              end,
            },
          })
        end,
      },
    },
    interactions = {
      chat = { adapter = "zen" },
      inline = { adapter = "zen" },
      cmd = { adapter = "zen" },
    },
    display = {
      chat = {
        show_settings = true,
        render_headers = false,
      },
    },
  },
  keys = {
    { "<leader>Ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat" },
    { "<leader>Ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion Inline" },
    { "<leader>Aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
  },
}
