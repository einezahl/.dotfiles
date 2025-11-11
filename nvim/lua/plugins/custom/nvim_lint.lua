return {
  'mfussenegger/nvim-lint',

  config = function()
    require('lint').linters_by_ft = {
      python = { 'pylint' },
    }

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function()
        require('lint').try_lint()
      end,
    })

    -- Use venv Python if available
    local function get_python_path()
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
      end
      return 'python'
    end

    require('lint').linters.pylint.cmd = '/home/admd/dev/indents/slip_lines/slip_line_detection/.venv/bin/pylint'
  end,
}
