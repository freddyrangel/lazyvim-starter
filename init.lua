-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Check if in a tmux session
if os.getenv("TMUX") then
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    command = "Tmuxline",
  })
end
