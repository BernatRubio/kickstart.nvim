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
      hijack_netrw_behavior = 'open_current',
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

    -- Keep track of the last non–Neo-tree window
    local last_non_neotree_win = nil

    -- Keep track if neotree is opened
    local is_neotree_opened = false

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
      callback = function()
        vim.schedule(function()
          -- We wrap this code in vim.schedule to delay execution until after startup initialization.
          -- This ensures that buffer details (like name and filetype) are properly populated, preventing issues where these values might be empty during early autocommand events.
          local buf = vim.api.nvim_get_current_buf()
          local bufname = vim.api.nvim_buf_get_name(buf)
          local filetype = vim.bo.filetype

          if not is_neotree_opened and bufname ~= '' and filetype ~= 'neo-tree' then
            vim.cmd 'Neotree show right'
            is_neotree_opened = true
          end
        end)
      end,
    })

    -- Initialize last_non_neotree_win on startup
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= 'neo-tree' then
          last_non_neotree_win = win
        end
      end,
    })

    -- Update the last non–Neo-tree window when entering a buffer
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        local cur_win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(cur_win)
        if vim.bo[buf].filetype ~= 'neo-tree' then
          last_non_neotree_win = cur_win
        end
      end,
    })

    -- <C-n> mapping that uses our updated last_non_neotree_win.
    vim.keymap.set('n', '<C-n>', function()
      local cur_win = vim.api.nvim_get_current_win()
      local cur_buf = vim.api.nvim_win_get_buf(cur_win)
      if vim.bo[cur_buf].filetype == 'neo-tree' then
        if last_non_neotree_win and vim.api.nvim_win_is_valid(last_non_neotree_win) then
          vim.api.nvim_set_current_win(last_non_neotree_win)
        else
          vim.cmd 'wincmd p'
        end
      else
        last_non_neotree_win = cur_win
        vim.cmd 'Neotree focus right'
      end
    end, { silent = true, desc = 'Toggle focus between Neo-tree and last non-Neo-tree window' })

    -- Map <leader>n to toggle Neo-tree without focusing it.
    -- When Neo-tree is opened, this mapping immediately returns focus
    -- to the window that was active before toggling.
    vim.keymap.set('n', '<leader>n', function()
      local cur_win = vim.api.nvim_get_current_win()
      vim.cmd 'Neotree toggle right'
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
