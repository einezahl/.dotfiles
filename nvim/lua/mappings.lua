require "nvchad.mappings"

-- add yours here
local default_opts = {noremap = true, silent = true}
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map('n', '<C-a>', ':lua require("harpoon.mark").add_file()<CR>', default_opts)
map('n', '<leader>L', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', default_opts)
map('n', '<leader>j', ':lua require("harpoon.ui").nav_file(1)<CR>', default_opts)
map('n', '<leader>k', ':lua require("harpoon.ui").nav_file(2)<CR>', default_opts)
map('n', '<leader>l', ':lua require("harpoon.ui").nav_file(3)<CR>', default_opts)
map('n', '<leader>;', ':lua require("harpoon.ui").nav_file(4)<CR>', default_opts)


map("n", "<leader>u", "UndotreeToggle<CR>", default_opts)

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<Leader>nf", ":lua require('neogen').generate()<CR>", opts)
