require('luasnip.loaders.from_vscode').lazy_load()
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

