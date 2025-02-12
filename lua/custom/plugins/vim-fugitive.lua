return {
  'tpope/vim-fugitive',
  cmd = 'Git',
  keys = {
    { '<leader>gg', ':Git<CR>', desc = '[G]it', silent = true },
    { '<leader>gf', ':Git fetch<CR>', desc = '[G]it [F]etch', silent = true },
    { '<leader>gl', ':Git pull<CR>', desc = '[G]it pul[L]', silent = true },
  },
}
