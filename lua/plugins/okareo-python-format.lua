return {
  -- Use the correct Mason plugin repo
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ruff", "ruff-lsp", "black", "isort" })
    end,
  },

  -- LSP: keep ruff_lsp, disable its formatter so it can't reformat on save
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable pyright/basedpyright to avoid “extra” type errors
        pyright = { enabled = false },
        basedpyright = { enabled = false },

        ruff_lsp = {
          on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },

  -- Conform: use Poetry’s isort -> black so it matches pre-commit exactly
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local conform = require("conform")
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      conform.formatters.black = {
        command = "poetry",
        args = { "run", "black", "--quiet", "-" },
        stdin = true,
      }
      conform.formatters.isort = {
        command = "poetry",
        args = { "run", "isort", "--profile", "black", "-" },
        stdin = true,
      }

      opts.formatters_by_ft.python = { "isort", "black" }
      -- DO NOT set opts.format_on_save here; LazyVim shows that warning if you do.
    end,
  },

  -- nvim-lint: run mypy (and optionally flake8) via Poetry so editor mirrors pre-commit
  {
    "mfussenegger/nvim-lint",
    opts = function(_, _)
      local lint = require("lint")

      local mypy = lint.linters.mypy or {}
      mypy.cmd = "poetry"
      mypy.args = {
        "run",
        "mypy",
        "--hide-error-context",
        "--no-color-output",
        "--no-error-summary",
        "--show-absolute-path",
        "--show-column-numbers",
      }
      mypy.stdin = false
      mypy.stream = "stderr"
      mypy.ignore_exitcode = true
      lint.linters.mypy = mypy

      -- Optional: mirror flake8 too (you can remove "flake8" if it’s noisy)
      local flake8 = lint.linters.flake8 or {}
      flake8.cmd = "poetry"
      flake8.args = { "run", "flake8", "--format=%(path)s:%(row)d:%(col)d: %(code)s %(text)s" }
      flake8.stdin = false
      flake8.ignore_exitcode = true
      lint.linters.flake8 = flake8

      lint.linters_by_ft = lint.linters_by_ft or {}
      lint.linters_by_ft.python = { "mypy", "flake8" }

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        pattern = "*.py",
        callback = function()
          require("lint").try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
