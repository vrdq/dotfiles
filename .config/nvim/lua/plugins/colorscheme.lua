local palette = {
  bg = "#131313",
  bg_dark = "#0e0e0e",
  surface = "#1f1f1f",
  selection = "#323232",
  border = "#919191",
  fg = "#e2e2e2",
  muted = "#ababab",
  primary = "#ffffff",
  green = "#9acb7b",
  orange = "#e2a45f",
  blue = "#8aabc1",
  red = "#e06c75",
}

local statusline_theme = {
  normal = {
    a = { fg = palette.primary, bg = palette.surface, gui = "bold" },
    b = { fg = palette.fg, bg = palette.surface },
    c = { fg = palette.muted, bg = palette.bg_dark },
  },
  insert = { a = { fg = palette.primary, bg = palette.surface, gui = "bold" } },
  visual = { a = { fg = palette.primary, bg = palette.surface, gui = "bold" } },
  replace = { a = { fg = palette.primary, bg = palette.surface, gui = "bold" } },
  command = { a = { fg = palette.primary, bg = palette.surface, gui = "bold" } },
  inactive = {
    a = { fg = palette.muted, bg = palette.bg_dark },
    b = { fg = palette.muted, bg = palette.bg_dark },
    c = { fg = palette.muted, bg = palette.bg_dark },
  },
}

local function ui_chrome_highlights()
  local highlights = {
    BlinkCmpDocBorder = { fg = palette.primary, bg = palette.surface },
    BlinkCmpMenuBorder = { fg = palette.primary, bg = palette.surface },
    BlinkCmpScrollBarGutter = { bg = "#2a2a2a" },
    BlinkCmpScrollBarThumb = { bg = palette.border },
    BlinkCmpSignatureHelpActiveParameter = { fg = palette.primary, bg = palette.selection, bold = true },
    BlinkCmpSignatureHelpBorder = { fg = palette.primary, bg = palette.surface },
    BlinkCmpGhostText = { fg = palette.muted },
    BlinkCmpLabelMatch = { fg = palette.primary, bold = true },
    BufferLineBackground = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineBuffer = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineBufferSelected = { fg = palette.primary, bg = palette.selection, bold = true },
    BufferLineBufferVisible = { fg = palette.fg, bg = palette.surface },
    BufferLineCloseButton = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineCloseButtonSelected = { fg = palette.primary, bg = palette.selection },
    BufferLineCloseButtonVisible = { fg = palette.muted, bg = palette.surface },
    BufferLineDuplicate = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineDuplicateSelected = { fg = palette.muted, bg = palette.selection },
    BufferLineDuplicateVisible = { fg = palette.muted, bg = palette.surface },
    BufferLineFill = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineGroupLabel = { fg = palette.primary, bg = palette.selection, bold = true },
    BufferLineGroupSeparator = { fg = palette.border, bg = palette.bg_dark },
    BufferLineIndicatorSelected = { fg = palette.primary },
    BufferLineIndicatorVisible = { fg = palette.border },
    BufferLineNumbers = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineNumbersSelected = { fg = palette.primary, bg = palette.selection, bold = true },
    BufferLineNumbersVisible = { fg = palette.muted, bg = palette.surface },
    BufferLineOffsetSeparator = { fg = palette.border, bg = palette.bg_dark },
    BufferLinePick = { fg = palette.primary, bg = palette.bg_dark, bold = true },
    BufferLinePickSelected = { fg = palette.primary, bg = palette.selection, bold = true },
    BufferLinePickVisible = { fg = palette.primary, bg = palette.surface, bold = true },
    BufferLineSeparator = { fg = palette.bg_dark, bg = palette.bg_dark },
    BufferLineSeparatorSelected = { fg = palette.bg_dark, bg = palette.selection },
    BufferLineSeparatorVisible = { fg = palette.bg_dark, bg = palette.surface },
    BufferLineTab = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineTabClose = { fg = palette.muted, bg = palette.bg_dark },
    BufferLineTabSelected = { fg = palette.primary, bg = palette.selection, bold = true },
    BufferLineTabSeparator = { fg = palette.bg_dark, bg = palette.bg_dark },
    BufferLineTabSeparatorSelected = { fg = palette.bg_dark, bg = palette.selection },
    BufferLineTruncMarker = { fg = palette.muted, bg = palette.bg_dark },
    FloatBorder = { fg = palette.primary, bg = palette.surface },
    FloatTitle = { fg = palette.primary, bg = palette.surface, bold = true },
    LazyButton = { fg = palette.fg, bg = palette.surface },
    LazyButtonActive = { fg = palette.primary, bg = palette.selection, bold = true },
    LazyH1 = { fg = palette.primary, bg = palette.selection, bold = true },
    LazyH2 = { fg = palette.primary, bold = true },
    LazyProgressDone = { fg = palette.primary },
    LazyProgressTodo = { fg = palette.muted },
    LazySpecial = { fg = palette.primary },
    LspInfoBorder = { fg = palette.primary, bg = palette.surface },
    MasonHeader = { fg = palette.bg, bg = palette.primary, bold = true },
    MasonHighlight = { fg = palette.primary },
    MasonHighlightBlock = { fg = palette.bg, bg = palette.primary },
    MasonHighlightBlockBold = { fg = palette.bg, bg = palette.primary, bold = true },
    MasonMuted = { fg = palette.muted },
    MasonMutedBlock = { fg = palette.muted, bg = palette.surface },
    MiniIconsAzure = { fg = palette.fg },
    MiniIconsBlue = { fg = palette.fg },
    MiniIconsCyan = { fg = palette.fg },
    MiniIconsGreen = { fg = palette.fg },
    MiniIconsGrey = { fg = palette.muted },
    MiniIconsOrange = { fg = palette.fg },
    MiniIconsPurple = { fg = palette.fg },
    MiniIconsRed = { fg = palette.fg },
    MiniIconsYellow = { fg = palette.fg },
    NoiceCmdlineIcon = { fg = palette.primary },
    NoiceCmdlineIconCalculator = { fg = palette.primary },
    NoiceCmdlineIconCmdline = { fg = palette.primary },
    NoiceCmdlineIconFilter = { fg = palette.primary },
    NoiceCmdlineIconHelp = { fg = palette.primary },
    NoiceCmdlineIconIncRename = { fg = palette.primary },
    NoiceCmdlineIconInput = { fg = palette.primary },
    NoiceCmdlineIconLua = { fg = palette.primary },
    NoiceCmdlineIconSearch = { fg = palette.primary },
    NoiceCmdlinePopupBorder = { fg = palette.primary },
    NoiceCmdlinePopupBorderCalculator = { fg = palette.primary },
    NoiceCmdlinePopupBorderCmdline = { fg = palette.primary },
    NoiceCmdlinePopupBorderFilter = { fg = palette.primary },
    NoiceCmdlinePopupBorderHelp = { fg = palette.primary },
    NoiceCmdlinePopupBorderIncRename = { fg = palette.primary },
    NoiceCmdlinePopupBorderInput = { fg = palette.primary },
    NoiceCmdlinePopupBorderLua = { fg = palette.primary },
    NoiceCmdlinePopupBorderSearch = { fg = palette.primary },
    NoiceCmdlinePopupTitle = { fg = palette.primary, bold = true },
    NoiceCmdlinePopupTitleInput = { fg = palette.primary, bold = true },
    NoiceCmdlinePopupTitleLua = { fg = palette.primary, bold = true },
    PmenuSel = { fg = palette.primary, bg = palette.selection, bold = true },
    PmenuThumb = { bg = palette.border },
    SnacksDashboardBorder = { fg = palette.primary },
    SnacksDashboardHeader = { fg = palette.primary, bold = true },
    SnacksDashboardKey = { fg = palette.primary, bold = true },
    SnacksDashboardSpecial = { fg = palette.primary },
    SnacksDashboardTitle = { fg = palette.primary, bold = true },
    SnacksFooterDesc = { fg = palette.fg, bg = palette.surface },
    SnacksFooterKey = { fg = palette.primary, bg = palette.selection, bold = true },
    SnacksGhDiffHeader = { fg = palette.primary, bg = palette.surface },
    SnacksGhLabel = { fg = palette.primary },
    SnacksIndent = { fg = "#474747" },
    SnacksIndentScope = { fg = palette.border },
    SnacksInputBorder = { fg = palette.primary },
    SnacksInputIcon = { fg = palette.primary },
    SnacksInputTitle = { fg = palette.primary, bold = true },
    SnacksNotifierBorderDebug = { fg = palette.border },
    SnacksNotifierBorderError = { fg = palette.border },
    SnacksNotifierBorderInfo = { fg = palette.border },
    SnacksNotifierBorderTrace = { fg = palette.border },
    SnacksNotifierBorderWarn = { fg = palette.border },
    SnacksPickerBoxTitle = { fg = palette.primary, bold = true },
    SnacksPickerAuEvent = { fg = palette.fg },
    SnacksPickerAuGroup = { fg = palette.muted },
    SnacksPickerAuPattern = { fg = palette.muted },
    SnacksPickerBufNr = { fg = palette.muted },
    SnacksPickerBufType = { fg = palette.muted },
    SnacksPickerCmd = { fg = palette.fg },
    SnacksPickerCmdBuiltin = { fg = palette.primary, bold = true },
    SnacksPickerCode = { fg = palette.fg, bg = palette.selection },
    SnacksPickerComment = { fg = palette.muted },
    SnacksPickerDelim = { fg = palette.border },
    SnacksPickerDesc = { fg = palette.muted },
    SnacksPickerFileType = { fg = palette.muted },
    SnacksPickerIdx = { fg = palette.muted },
    SnacksPickerInputBorder = { fg = palette.primary, bg = palette.surface },
    SnacksPickerInputSearch = { fg = palette.primary },
    SnacksPickerInputTitle = { fg = palette.primary, bg = palette.surface, bold = true },
    SnacksPickerKeymapLhs = { fg = palette.fg },
    SnacksPickerKeymapMode = { fg = palette.muted },
    SnacksPickerKeymapNowait = { fg = palette.muted },
    SnacksPickerLabel = { fg = palette.fg },
    SnacksPickerLink = { fg = palette.muted },
    SnacksPickerManPage = { fg = palette.fg },
    SnacksPickerManSection = { fg = palette.muted },
    SnacksPickerMatch = { fg = palette.primary, bold = true },
    SnacksPickerPickWinCurrent = { fg = palette.bg, bg = palette.primary, bold = true },
    SnacksPickerPrompt = { fg = palette.primary },
    SnacksPickerRegister = { fg = palette.fg },
    SnacksPickerRow = { fg = palette.muted },
    SnacksPickerRule = { fg = palette.border },
    SnacksPickerSelected = { fg = palette.primary, bg = palette.selection, bold = true },
    SnacksPickerSpecial = { fg = palette.primary },
    SnacksPickerSpinner = { fg = palette.primary },
    SnacksPickerTime = { fg = palette.muted },
    SnacksPickerToggle = { fg = palette.primary, bg = palette.selection },
    SnacksPickerUndoCurrent = { fg = palette.primary, bold = true },
    SnacksPickerUndoSaved = { fg = palette.muted },
    SnacksProfilerBadgeInfo = { fg = palette.primary, bg = palette.surface },
    SnacksProfilerBadgeTrace = { fg = palette.muted, bg = palette.surface },
    SnacksProfilerIconInfo = { fg = palette.primary, bg = palette.selection },
    SnacksProfilerIconTrace = { fg = palette.muted, bg = palette.selection },
    SnacksZenIcon = { fg = palette.primary },
    TroubleCount = { fg = palette.primary, bg = palette.selection },
    TroubleCode = { fg = palette.muted },
    TroubleFsSource = { fg = palette.muted },
    TroubleFzfSource = { fg = palette.muted },
    TroubleLspSource = { fg = palette.muted },
    TroubleProfilerSource = { fg = palette.muted },
    TroubleQfSource = { fg = palette.muted },
    TroubleSnacksSource = { fg = palette.muted },
    TroubleSource = { fg = palette.muted },
    TroubleTelescopeSource = { fg = palette.muted },
    WhichKey = { fg = palette.primary, bold = true },
    WhichKeyDesc = { fg = palette.fg },
    WhichKeyGroup = { fg = palette.primary },
    WhichKeyNormal = { fg = palette.fg, bg = palette.bg_dark },
    WhichKeySeparator = { fg = palette.border },
    WhichKeyValue = { fg = palette.muted },
  }

  for index = 1, 8 do
    highlights["SnacksIndent" .. index] = { fg = index == 1 and palette.border or "#474747" }
  end
  return highlights
end

local function apply_ui_chrome()
  for group, highlight in pairs(ui_chrome_highlights()) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      on_colors = function(colors)
        colors.bg = palette.bg
        colors.bg_dark = palette.bg_dark
        colors.bg_float = palette.surface
        colors.bg_highlight = palette.selection
        colors.bg_popup = palette.surface
        colors.bg_search = palette.selection
        colors.bg_sidebar = palette.bg_dark
        colors.bg_statusline = palette.bg_dark
        colors.border = palette.border
        colors.fg = palette.fg
        colors.fg_dark = palette.muted
        colors.fg_gutter = "#595959"
        colors.green = palette.green
        colors.orange = palette.orange
        colors.blue = palette.blue
        colors.red = palette.red
      end,
      on_highlights = function(highlights)
        highlights.Normal = { fg = palette.fg, bg = "NONE" }
        highlights.NormalNC = { fg = palette.fg, bg = "NONE" }
        highlights.SignColumn = { bg = "NONE" }
        highlights.FoldColumn = { bg = "NONE" }
        highlights.EndOfBuffer = { fg = palette.bg, bg = "NONE" }
        highlights.NeoTreeNormal = { fg = palette.fg, bg = "NONE" }
        highlights.NeoTreeNormalNC = { fg = palette.fg, bg = "NONE" }
        highlights.SnacksDashboardNormal = { fg = palette.fg, bg = "NONE" }
        highlights.SnacksDashboardHeader = { fg = palette.primary, bold = true }
        highlights.SnacksDashboardTitle = { fg = palette.primary, bold = true }
        highlights.SnacksDashboardKey = { fg = palette.primary, bold = true }
        highlights.SnacksDashboardIcon = { fg = palette.muted }
        highlights.SnacksDashboardDesc = { fg = palette.fg }
        highlights.SnacksDashboardDir = { fg = palette.muted }
        highlights.SnacksDashboardFile = { fg = palette.fg }
        highlights.SnacksDashboardFooter = { fg = palette.muted }
        highlights.SnacksDashboardSpecial = { fg = palette.primary }
        highlights.SnacksDashboardBorder = { fg = palette.primary }
        highlights.FloatBorder = { fg = palette.primary, bg = palette.surface }
        highlights.FloatTitle = { fg = palette.primary, bg = palette.surface, bold = true }
        highlights.SnacksPickerBoxTitle = { fg = palette.primary, bold = true }
        highlights.SnacksPickerInputBorder = { fg = palette.primary, bg = palette.surface }
        highlights.SnacksPickerInputTitle = { fg = palette.primary, bg = palette.surface, bold = true }
        highlights.SnacksPickerSelected = { fg = palette.primary, bg = palette.selection, bold = true }
        highlights.CursorLine = { bg = "#1f1f1f" }
        highlights.ColorColumn = { bg = palette.surface }
        highlights.Conceal = { fg = palette.muted }
        highlights.CurSearch = { fg = palette.bg, bg = palette.primary, bold = true }
        highlights.Directory = { fg = palette.fg }
        highlights.Folded = { fg = palette.muted, bg = "#2a2a2a" }
        highlights.IncSearch = { fg = palette.bg, bg = palette.primary, bold = true }
        highlights.LineNr = { fg = "#595959" }
        highlights.CursorLineNr = { fg = palette.primary, bold = true }
        highlights.MatchParen = { fg = palette.primary, bg = palette.selection, bold = true }
        highlights.MoreMsg = { fg = palette.fg }
        highlights.NonText = { fg = "#595959" }
        highlights.NormalFloat = { fg = palette.fg, bg = palette.surface }
        highlights.Pmenu = { fg = palette.fg, bg = palette.surface }
        highlights.PmenuExtra = { fg = palette.fg, bg = palette.surface }
        highlights.PmenuKind = { fg = palette.fg, bg = palette.surface }
        highlights.PmenuMatch = { fg = palette.primary, bg = palette.surface, bold = true }
        highlights.PmenuMatchSel = { fg = palette.primary, bg = palette.selection, bold = true }
        highlights.Question = { fg = palette.fg }
        highlights.QuickFixLine = { fg = palette.primary, bg = palette.selection }
        highlights.Search = { fg = palette.primary, bg = palette.selection }
        highlights.SpecialKey = { fg = "#595959" }
        highlights.TabLine = { fg = palette.muted, bg = palette.bg_dark }
        highlights.TabLineFill = { bg = palette.bg_dark }
        highlights.TabLineSel = { fg = palette.primary, bg = palette.selection, bold = true }
        highlights.Title = { fg = palette.primary, bold = true }
        highlights.Visual = { bg = palette.selection }
        highlights.WildMenu = { fg = palette.primary, bg = palette.selection }
        highlights.WinSeparator = { fg = palette.border }
        highlights.StatusLine = { fg = palette.muted, bg = palette.bg_dark }
        highlights.StatusLineNC = { fg = "#595959", bg = palette.bg_dark }

        for group, highlight in pairs(ui_chrome_highlights()) do
          highlights[group] = highlight
        end

        for level = 1, 6 do
          highlights["RenderMarkdownH" .. level .. "Bg"] = { bg = "NONE" }
          highlights["@markup.heading." .. level .. ".markdown"] = {
            fg = level == 1 and palette.orange or palette.green,
            bg = "NONE",
            bold = true,
          }
        end
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("SystemThemePluginChrome", { clear = true }),
        callback = function()
          vim.schedule(apply_ui_chrome)
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = "SystemThemePluginChrome",
        pattern = "VeryLazy",
        callback = apply_ui_chrome,
      })
      vim.api.nvim_create_autocmd("User", {
        group = "SystemThemePluginChrome",
        pattern = "LazyLoad",
        callback = function()
          vim.schedule(apply_ui_chrome)
        end,
      })
    end,
    opts = { colorscheme = "tokyonight-night" },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = statusline_theme
      opts.options.component_separators = ""
      opts.options.section_separators = ""
    end,
  },
}
