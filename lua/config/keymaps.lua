-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Tab management settings
vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true, desc = "Open a new tab" })
vim.keymap.set("n", "tc", ":tabclose<CR>", { silent = true, desc = "Close current tab" })
vim.keymap.set("n", "tk", ":tabnext<CR>", { silent = true, desc = "Go to the next tab" })
vim.keymap.set("n", "tj", ":tabprev<CR>", { silent = true, desc = "Go to the previous tab" })

-- Save file settings
vim.keymap.set("n", "<Leader>w", ":w<CR>", { silent = true, desc = "Save the current file" })

-- Remove LazyVim's default <Leader><Leader> keymap
vim.keymap.del("n", "<Leader><Leader>")

-- Now set your custom keymap
vim.keymap.set(
  "n",
  "<Leader><Leader>",
  "<C-^>",
  { noremap = true, silent = true, desc = "Switch between the last two files" }
)

-- Find Files (root dir)
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>")

-- Git blame file
vim.keymap.set("n", "<Leader>gbf", ":Git blame<CR>", { silent = true, desc = "Save the current file" })
