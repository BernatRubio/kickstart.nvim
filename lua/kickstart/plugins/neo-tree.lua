-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  lazy = false, -- Load the plugin at startup
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  opts = {
    filesystem = {
      -- Automatically watch for file changes using libuv
      use_libuv_file_watcher = true,
      -- Automatically follow the current file
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)
    vim.cmd 'Neotree show right' -- Open Neo-tree on startup

    -- Toggle focus between Neo-tree and the last accessed window with <C-n>
    vim.keymap.set('n', '<C-n>', function()
      if vim.bo.filetype == 'neo-tree' then
        vim.cmd 'wincmd p'
      else
        vim.cmd 'Neotree focus'
      end
    end, { silent = true, desc = 'Toggle focus between Neo-tree and last window' })

    -- Map <leader>n to toggle Neo-tree without focusing it.
    -- When Neo-tree is opened, this mapping immediately returns focus
    -- to the window that was active before toggling.
    vim.keymap.set('n', '<leader>n', function()
      local cur_win = vim.api.nvim_get_current_win()
      vim.cmd 'Neotree toggle'
      -- Defer to let Neo-tree toggle finish, then check if the current
      -- buffer is Neo-tree. If it is, switch back to the previously active window.
      vim.schedule(function()
        if vim.bo[vim.api.nvim_get_current_buf()].filetype == 'neo-tree' then
          vim.api.nvim_set_current_win(cur_win)
        end
      end)
    end, { silent = true, desc = 'Toggle [N]eo-tree' })

    -- Auto-close Neo-tree when it's the only window left
    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        local wins = vim.api.nvim_list_wins()
        if #wins == 1 then
          local buf = vim.api.nvim_win_get_buf(wins[1])
          if vim.bo[buf].filetype == 'neo-tree' then
            vim.cmd 'quit'
          end
        end
      end,
    })
  end,
}
