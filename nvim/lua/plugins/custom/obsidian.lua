return {
  'obsidian-nvim/obsidian.nvim', -- maintained community fork (epwalsh's repo is archived)
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    -- Use only the new ':Obsidian <sub>' commands. The default still registers
    -- the deprecated ':ObsidianXxx' aliases and prints a warning.
    legacy_commands = false,

    -- Name new notes after their title (e.g. 'random-init-vs-paper-weights.md')
    -- instead of the default Zettelkasten '<timestamp>-<random>' id. title_id
    -- slugifies the title, de-duplicates with '-2'/'-3', and only falls back to
    -- a zettel id when the title is empty. For Obsidian-app-style spaced names
    -- ('random init vs paper weights.md') return the title verbatim instead.
    -- Require lazily: obsidian.nvim loads on the markdown filetype, after this
    -- spec is evaluated, so the module isn't on the runtimepath at startup.
    note_id_func = function(title, path)
      return require('obsidian.builtin').title_id(title, path)
    end,

    workspaces = {
      {
        name = 'phd',
        path = '~/Documents/phd',
      },
      {
        name = 'no-vault',
        path = function()
          -- alternatively use the CWD:
          -- return assert(vim.fn.getcwd())
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
        disable_frontmatter = true,
        overrides = {
          notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
          new_notes_location = 'current_dir',
        },
      },
    },

    log_level = vim.log.levels.INFO,

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'calendar notes',
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = '%Y-%m/%Y-%m-%d',
      -- Optional, default tags to add to each new daily note created.
      default_tags = { 'daily-notes' },
    },

    -- Location of templates, e.g. for ':Obsidian template' and daily notes.
    templates = {
      folder = 'templates',
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    -- render-markdown.nvim is active and the fork auto-detects it and backs off
    -- its own rendering (see obsidian/workspace.lua). Disable explicitly anyway.
    ui = { enable = false },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)

    -- The fork dropped the 'mappings' option; keymaps are set the normal way.
    -- It already maps <CR> (smart action: follow link / toggle checkbox / fold),
    -- ]o and [o (link navigation), and 'gf' on vault notes. Add our note-local
    -- leader maps on the same note-enter event so they only apply in the vault.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ObsidianNoteEnter',
      callback = function(ev)
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, desc = desc })
        end
        map('<leader>og', '<cmd>Obsidian search<CR>', '[G]rep in Notes')
        map('<leader>oo', '<cmd>Obsidian quick_switch<CR>', '[O]pen QuickSwitch')
        map('<leader>ot', '<cmd>Obsidian toc<CR>', '[T]OC')
        map('<leader>od', '<cmd>Obsidian dailies<CR>', '[D]ailies')
        map('<leader>or', '<cmd>Obsidian rename<CR>', '[R]ename Note')
        map('<leader>of', '<cmd>Obsidian tags<CR>', '[F]ind by Tag')
        map('<leader>ow', '<cmd>Obsidian workspace<CR>', 'Select [W]orkspace')
        map('<leader>on', '<cmd>Obsidian new<CR>', '[N]ew Note')
        map('<leader>oi', '<cmd>Obsidian template<CR>', '[I]nsert Template')
        map('<leader>oN', '<cmd>Obsidian new_from_template<CR>', '[N]ew from Template')
        map('<leader>oz', '<cmd>ZenMode<CR>', '[Z]en Mode')
        map('<leader><leader>', '<cmd>Obsidian toggle_checkbox<CR>', 'Toggle Checkbox')
      end,
    })
  end,
}
