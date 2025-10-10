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

vim.keymap.set("n", "<leader>gr", function()
  local pick_lines = {}
  local total_lines = vim.fn.line("$")

  -- Gather all line numbers starting with 'pick'
  for lnum = 1, total_lines do
    local line = vim.fn.getline(lnum)
    if vim.startswith(line, "pick ") then
      table.insert(pick_lines, lnum)
    end
  end

  if #pick_lines == 0 then
    print("No 'pick' lines found.")
    return
  end

  -- Skip the first pick, replace others
  for i = 2, #pick_lines do
    local lnum = pick_lines[i]
    local line = vim.fn.getline(lnum)
    vim.fn.setline(lnum, line:gsub("^pick", "squash"))
  end

  print("Squashed all but the first 'pick'")
end, { desc = "Squash all but first pick" })

-- Copy full file path to clipboard (macOS)
vim.keymap.set("n", "<leader>cp", function()
  local filepath = vim.fn.expand("%:p")
  vim.fn.setreg("+", filepath) -- copy to the system clipboard
  vim.fn.system("pbcopy", filepath)
  print("Copied full path: " .. filepath)
end, { desc = "Copy full file path to clipboard" })

----------------------------------------------------------------------
-- Copy current file as a fenced Markdown snippet:
-- <path>
-- ```<ext-or-filetype>
-- <contents>
-- ```
--
-- :CopyAsMarkdown [full|relative]
--   full     -> absolute path (default)
--   relative -> path relative to git root if available, else CWD
----------------------------------------------------------------------

do
  local function escape_for_pattern(s)
    return s and s:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1") or s
  end

  local function detect_fence()
    -- Prefer file extension; fall back to filetype
    local ext = vim.fn.expand("%:e")
    if ext ~= "" then
      return ext
    end
    local ft = vim.bo.filetype or ""
    return ft
  end

  local function rel_to_git_root(abs_path)
    -- Try git root; fall back to cwd-relative buffer path
    local has_git = vim.fn.executable("git") == 1
    if has_git then
      local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if root and root ~= "" then
        local esc = escape_for_pattern(root .. "/")
        return abs_path:gsub("^" .. esc, "")
      end
    end
    -- If not a git repo, use path relative to current working directory
    return vim.fn.expand("%") -- buffer path relative to CWD
  end

  local function system_clipboard(text)
    -- Always set the + register; try platform clipboards
    vim.fn.setreg("+", text)
    if vim.fn.executable("pbcopy") == 1 then
      vim.fn.system("pbcopy", text)
    elseif vim.fn.executable("xclip") == 1 then
      vim.fn.system("xclip -selection clipboard", text)
    elseif vim.fn.executable("xsel") == 1 then
      vim.fn.system("xsel --clipboard --input", text)
    end
  end

  local function copy_as_markdown(path_style)
    path_style = path_style or "full"

    local abs_path = vim.fn.expand("%:p")
    if abs_path == "" then
      abs_path = "[No Name]"
    end

    local path_line = abs_path
    if path_style == "relative" then
      path_line = rel_to_git_root(abs_path)
    end

    local fence = detect_fence()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local body = table.concat(lines, "\n")

    local snippet = path_line .. "\n```" .. fence .. "\n" .. body .. "\n```\n"

    system_clipboard(snippet)
    print("Copied Markdown snippet for: " .. path_line)
  end

  -- User command: :CopyAsMarkdown [full|relative]
  vim.api.nvim_create_user_command("CopyAsMarkdown", function(opts)
    local arg = opts.args
    if arg ~= "full" and arg ~= "relative" and arg ~= "" then
      print("Usage: :CopyAsMarkdown [full|relative]")
      return
    end
    copy_as_markdown(arg == "" and "full" or arg)
  end, {
    nargs = "?",
    complete = function()
      return { "full", "relative" }
    end,
  })

  -- Keybinds:
  -- Relative (your requested default) on <leader>cm
  vim.keymap.set("n", "<leader>bn", function()
    vim.cmd("CopyAsMarkdown relative")
  end, { desc = "Copy file as fenced Markdown (relative path)" })

  -- Optional: Full path on <leader>cM
  vim.keymap.set("n", "<leader>bm", function()
    vim.cmd("CopyAsMarkdown full")
  end, { desc = "Copy file as fenced Markdown (full path)" })
end
