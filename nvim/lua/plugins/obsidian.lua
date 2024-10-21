return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies https://github.com/epwalsh/obsidian.nvim?tab=readme-ov-file#plugin-dependencies
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
    "pomo.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "/Users/adrianofsantos/repos/github/Notes/Vaults/MyLife/",
      },
      {
        name = "amer3",
        path = "/Users/adrianofsantos/repos/github/Notes/Vaults/americanas sa/",
      },
    },

    -- see below for full list of options 👇
  },
}
