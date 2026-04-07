return {
  {
    "arcticicestudio/nord-vim",
    lazy = false,
    name = "nord",
    priority = 1000,
    config = function()
      local nord = {
        polar_night_0 = "#2e3440",
        polar_night_1 = "#3b4252",
        polar_night_2 = "#434c5e",
        polar_night_3 = "#4c566a",
        snow_storm_0 = "#d8dee9",
        frost_1 = "#88c0d0",
        frost_2 = "#81a1c1",
      }

      local function apply_cooler_links()
        local cooler_links = {
          ["@string.special"] = "String",
          ["@string.special.symbol"] = "String",
          ["@lsp.type.enumMember.typescript"] = "String",
          ["@lsp.type.enumMember.vue"] = "String",
          ["@property"] = "Identifier",
          ["@lsp.type.property.typescript"] = "Identifier",
          ["@lsp.type.property.vue"] = "Identifier",
        }

        for group, link in pairs(cooler_links) do
          vim.api.nvim_set_hl(0, group, { link = link })
        end
      end

      local function apply_ui_backgrounds()
        local solid_groups = {
          "NormalFloat",
          "NormalSB",
          "NeoTreeNormal",
          "NeoTreeNormalNC",
          "SnacksNormal",
          "SnacksNormalNC",
          "SnacksPicker",
          "SnacksPickerInput",
          "SnacksInputNormal",
          "SnacksDashboardNormal",
        }

        for _, group in ipairs(solid_groups) do
          vim.api.nvim_set_hl(0, group, { bg = nord.polar_night_0 })
        end

        vim.api.nvim_set_hl(0, "FloatBorder", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "SnacksInputBorder", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "SnacksWinSeparator", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = nord.polar_night_2, bg = nord.polar_night_0 })
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = nord.frost_2, bg = nord.polar_night_1, italic = false })
        vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = nord.polar_night_2 })
        vim.api.nvim_set_hl(0, "SnacksPickerPreviewCursorLine", { bg = nord.polar_night_2 })
        vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = nord.frost_2 })
        vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = nord.frost_2 })
        vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = nord.polar_night_3 })
        vim.api.nvim_set_hl(0, "SnacksPickerRow", { fg = nord.frost_1 })
        vim.api.nvim_set_hl(0, "SnacksPickerCol", { fg = nord.frost_1 })
        vim.api.nvim_set_hl(0, "SnacksPickerMatch", { fg = nord.frost_1, bold = true })
        vim.api.nvim_set_hl(0, "SnacksPickerInputSearch", { fg = nord.snow_storm_0, bold = true })
        vim.api.nvim_set_hl(0, "SnacksPickerSearch", { fg = nord.snow_storm_0, bg = nord.polar_night_2, bold = true })
        vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = nord.frost_1, bold = true })
      end

      local function apply_terminal_palette()
        vim.g.terminal_color_0 = nord.polar_night_1
        vim.g.terminal_color_1 = "#bf616a"
        vim.g.terminal_color_2 = "#a3be8c"
        vim.g.terminal_color_3 = "#ebcb8b"
        vim.g.terminal_color_4 = nord.frost_2
        vim.g.terminal_color_5 = "#b48ead"
        vim.g.terminal_color_6 = nord.frost_1
        vim.g.terminal_color_7 = nord.snow_storm_0
        vim.g.terminal_color_8 = nord.polar_night_3
        vim.g.terminal_color_9 = "#bf616a"
        vim.g.terminal_color_10 = "#a3be8c"
        vim.g.terminal_color_11 = "#ebcb8b"
        vim.g.terminal_color_12 = nord.frost_2
        vim.g.terminal_color_13 = "#b48ead"
        vim.g.terminal_color_14 = nord.frost_1
        vim.g.terminal_color_15 = "#eceff4"
      end

      vim.g.nord_italic = true
      vim.g.nord_italic_comments = false
      vim.g.nord_underline = true
      vim.g.nord_bold = true
      vim.g.nord_uniform_status_lines = true

      apply_terminal_palette()
      vim.cmd.colorscheme("nord")
      apply_cooler_links()
      apply_ui_backgrounds()
      vim.schedule(apply_cooler_links)
      vim.schedule(apply_ui_backgrounds)
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "nord",
        callback = function()
          apply_cooler_links()
          apply_ui_backgrounds()
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
