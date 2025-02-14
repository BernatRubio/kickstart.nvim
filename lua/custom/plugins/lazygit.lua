return {
  'folke/snacks.nvim',
  lazy = false, -- ensure the plugin is loaded on startup
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
  },
}
