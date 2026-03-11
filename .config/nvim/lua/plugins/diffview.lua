return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      -- PR-style compare: base...head (merge-base)
      { "<leader>gD", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: origin/main...HEAD" },
      -- Simple open (index vs working tree)
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: File History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
      { "<leader>gD", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: main...HEAD (PR view)" },
    },
  },
}
