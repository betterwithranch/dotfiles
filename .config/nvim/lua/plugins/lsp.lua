return {
  -- add pyright to lspconfig
  ---@class PluginLspOpts
  {
    "neovim/nvim-lspconfig",
    ---@type lspconfig.options
    opts = {
      autoformat = false,
      servers = {
        ruby_lsp = {
          mason = false,
          cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
        },
      },
    },
  },
}
