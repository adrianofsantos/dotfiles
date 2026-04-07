return {
  -- Show hidden (dotfiles) and gitignored files in snacks picker and explorer
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}

      -- find files (<leader>ff): show dotfiles and gitignored files
      opts.picker.sources.files = vim.tbl_deep_extend("force", opts.picker.sources.files or {}, {
        hidden = true,  -- include dotfiles
        ignored = true, -- include files listed in .gitignore
      })

      -- file explorer (<leader>e): show dotfiles and gitignored files
      opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
        hidden = true,
        ignored = true,
      })

      return opts
    end,
  },
}
