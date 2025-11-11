local M = { vi = {} }

M.vi.text = {
  n = 'NORMAL',
  no = 'NORMAL',
  i = 'INSERT',
  v = 'VISUAL',
  V = 'V-LINE',
  [''] = 'V-BLOCK',
  c = 'COMMAND',
  cv = 'COMMAND',
  ce = 'COMMAND',
  R = 'REPLACE',
  Rv = 'REPLACE',
  s = 'SELECT',
  S = 'SELECT',
  [''] = 'SELECT',
  t = 'TERMINAL',
}

M.vi.colors = {
  n = 'FlnViCyan',
  no = 'FlnViCyan',
  i = 'FlnStatus',
  v = 'FlnViMagenta',
  V = 'FlnViMagenta',
  [''] = 'FlnViMagenta',
  R = 'FlnViRed',
  Rv = 'FlnViRed',
  r = 'FlnViBlue',
  rm = 'FlnViBlue',
  s = 'FlnViMagenta',
  S = 'FlnViMagenta',
  [''] = 'FelnMagenta',
  c = 'FlnViYellow',
  ['!'] = 'FlnViBlue',
  t = 'FlnViBlue',
}

M.vi.sep = {
  n = 'FlnCyan',
  no = 'FlnCyan',
  i = 'FlnStatusBg',
  v = 'FlnMagenta',
  V = 'FlnMagenta',
  [''] = 'FlnMagenta',
  R = 'FlnRed',
  Rv = 'FlnRed',
  r = 'FlnBlue',
  rm = 'FlnBlue',
  s = 'FlnMagenta',
  S = 'FlnMagenta',
  [''] = 'FelnMagenta',
  c = 'FlnYellow',
  ['!'] = 'FlnBlue',
  t = 'FlnBlue',
}

M.icons = {
  locker = '', -- #f023
  page = '☰', -- 2630
  line_number = '', -- e0a1
  connected = '', -- f817
  dos = '', -- e70f
  unix = '', -- f17c
  mac = '', -- f179
  mathematical_L = '𝑳',
  vertical_bar = '┃',
  vertical_bar_thin = '│',
  left = '',
  right = '',
  block = '█',
  left_filled = '',
  right_filled = '',
  slant_left = '',
  slant_left_thin = '',
  slant_right = '',
  slant_right_thin = '',
  slant_left_2 = '',
  slant_left_2_thin = '',
  slant_right_2 = '',
  slant_right_2_thin = '',
  left_rounded = '',
  left_rounded_thin = '',
  right_rounded = '',
  right_rounded_thin = '',
  circle = '●',
}
local fmt = string.format
require('lsp_status').register_progress()

-- "┃", "█", "", "", "", "", "", "", "●"

local get_diag = function(str)
  local count = vim.lsp.diagnostic.get_count(0, str)
  return (count > 0) and ' ' .. count .. ' ' or ''
end

local function vi_mode_hl()
  return M.vi.colors[vim.fn.mode()] or 'FlnViBlack'
end

local function vi_sep_hl()
  return M.vi.sep[vim.fn.mode()] or 'FlnBlack'
end

local c = {
  vimode = {
    provider = function()
      return string.format(' %s ', M.vi.text[vim.fn.mode()])
    end,
    hl = vi_mode_hl,
    right_sep = { str = ' ', hl = vi_sep_hl },
  },
  gitbranch = {
    provider = 'git_branch',
    icon = ' ',
    hl = 'FlnGitBranch',
    right_sep = { str = '  ', hl = 'FlnGitBranch' },
    enabled = function()
      return vim.b.gitsigns_status_dict ~= nil
    end,
  },
  file_type = {
    provider = function()
      return fmt(' %s ', vim.bo.filetype:upper())
    end,
    hl = 'FlnAlt',
  },
  fileinfo = {
    provider = { name = 'file_info', opts = { type = 'relative' } },
    hl = 'FlnAlt',
    left_sep = { str = ' ', hl = 'FlnAltSep' },
    right_sep = { str = '', hl = 'FlnAltSep' },
  },
  file_enc = {
    provider = function()
      local os = M.icons[vim.bo.fileformat] or ''
      return fmt(' %s %s ', os, vim.bo.fileencoding)
    end,
    hl = 'StatusLine',
    left_sep = { str = M.icons.left_filled, hl = 'FlnAltSep' },
  },
  cur_position = {
    provider = function()
      -- TODO: What about 4+ diget line numbers?
      return fmt(' %3d:%-2d ', unpack(vim.api.nvim_win_get_cursor(0)))
    end,
    hl = vi_mode_hl,
    left_sep = { str = M.icons.left_filled, hl = vi_sep_hl },
  },
  cur_percent = {
    provider = function()
      return ' ' .. require('feline.providers.cursor').line_percentage() .. '  '
    end,
    hl = vi_mode_hl,
    left_sep = { str = M.icons.left, hl = vi_mode_hl },
  },
  default = { -- needed to pass the parent StatusLine hl group to right hand side
    provider = '',
    hl = 'StatusLine',
  },
  lsp_status = {
    provider = function()
      return require('lsp-status').status()
    end,
    hl = 'FlnStatus',
    left_sep = { str = '', hl = 'FlnStatusBg', always_visible = true },
    right_sep = { str = '', hl = 'FlnErrorStatus', always_visible = true },
  },
  lsp_error = {
    provider = function()
      return get_diag 'Error'
    end,
    hl = 'FlnError',
    right_sep = { str = '', hl = 'FlnWarnError', always_visible = true },
  },
  lsp_warn = {
    provider = function()
      return get_diag 'Warning'
    end,
    hl = 'FlnWarn',
    right_sep = { str = '', hl = 'FlnInfoWarn', always_visible = true },
  },
  lsp_info = {
    provider = function()
      return get_diag 'Information'
    end,
    hl = 'FlnInfo',
    right_sep = { str = '', hl = 'FlnHintInfo', always_visible = true },
  },
  lsp_hint = {
    provider = function()
      return get_diag 'Hint'
    end,
    hl = 'FlnHint',
    right_sep = { str = '', hl = 'FlnBgHint', always_visible = true },
  },

  in_fileinfo = {
    provider = 'file_info',
    hl = 'StatusLine',
  },
  in_position = {
    provider = 'position',
    hl = 'StatusLine',
  },
}

local active = {
  { -- left
    c.vimode,
    c.gitbranch,
    c.fileinfo,
    c.default, -- must be last
  },
  { -- right
    c.lsp_status,
    c.lsp_error,
    c.lsp_warn,
    c.lsp_info,
    c.lsp_hint,
    c.file_type,
    c.file_enc,
    c.cur_position,
    c.cur_percent,
  },
}

local inactive = {
  { c.in_fileinfo }, -- left
  { c.in_position }, -- right
}

-- -- Define autocmd that generates the highlight groups from the new colorscheme
-- -- Then reset the highlights for feline
-- edn.aug.FelineColorschemeReload = {
--   {
--     { "SessionLoadPost", "ColorScheme" },
--     function()
--       require("eden.modules.ui.feline.colors").gen_highlights()
--       -- This does not look like it is required. If this is called I see the ^^^^^^ that
--       -- seperates the two sides of the bar. Since the entire config uses highlight groups
--       -- all that is required is to redefine them.
--       -- require("feline").reset_highlights()
--     end,
--   },
-- }
return {
  'feline-nvim/feline.nvim',

  config = function()
    require('feline').setup {
      components = { active = active, inactive = inactive },
      highlight_reset_triggers = {},
      force_inactive = {
        filetypes = {
          'NvimTree',
          'packer',
          'dap-repl',
          'dapui_scopes',
          'dapui_stacks',
          'dapui_watches',
          'dapui_repl',
          'LspTrouble',
          'qf',
          'help',
        },
        buftypes = { 'terminal' },
        bufnames = {},
      },
      disable = {
        filetypes = {
          'dashboard',
          'startify',
        },
      },
    }
  end,
}
