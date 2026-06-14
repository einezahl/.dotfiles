return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  -- The 'master' branch is frozen and unsupported on Neovim 0.12+; 'main' is
  -- the maintained branch. It exposes a different API: no configs.setup, no
  -- highlight/indent modules — Neovim drives those via vim.treesitter.
  branch = 'main',
  lazy = false, -- nvim-treesitter main does not support lazy-loading
  build = ':TSUpdate',
  config = function()
    -- Parsers to install. 'markdown_inline' is required for fenced-code-block
    -- and inline-markup highlighting (and by render-markdown.nvim); the old
    -- 'master' config was missing it, which is what made code-fence injection
    -- parsing fail. Installs run asynchronously and no-op when already present.
    require('nvim-treesitter').install {
      'bash',
      'c',
      'c_sharp',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'vim',
      'vimdoc',
    }

    -- 'main' ships no highlight/indent modules. Start treesitter highlighting
    -- for any buffer whose filetype has an installed parser (pcall no-ops for
    -- the rest), mirroring the old 'highlight.enable = true'.
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        -- Treesitter indentation is experimental on 'main'; enabling it keeps
        -- the previous 'indent = { enable = true }' behaviour. Drop this line
        -- if a filetype indents oddly.
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
