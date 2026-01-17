return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      auto_save_enabled = true,
      auto_restore_enabled = true,
      suppressed_dirs = { "~/", "~/Downloads", "/" },
    })
  end,
}
