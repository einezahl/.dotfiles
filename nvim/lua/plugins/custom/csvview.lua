return {
  'hat0uma/csvview.nvim',
  ft = { 'csv', 'tsv' },
  cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  opts = {
    parser = { comments = { '#', '//' } },
    view = { display_mode = 'border' },
  },
  keys = {
    { '<leader>tc', '<cmd>CsvViewToggle<cr>', desc = '[T]oggle [C]SV view' },
  },
}
