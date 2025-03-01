return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- configure lazygit if needed; empty table uses default settings
    lazygit = {
      -- your lazygit configuration goes here
    },
  },
  keys = {
    {
      '<leader>g',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazy[G]it',
    },
    {
      '<leader>l',
      function()
        Snacks.terminal 'lazydocker'
      end,
      desc = '[L]azyDocker',
    },
  },
}
