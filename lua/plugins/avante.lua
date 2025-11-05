-- Avante for LazyVim + Blink.CMP (no Zen Mode)
return {
  -- 1) Core Avante
  {
    "yetone/avante.nvim",
    version = false, -- track latest
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { -- Render Markdown (also Avante buffers)
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante" },
        opts = { file_types = { "markdown", "Avante" } },
      },
      { -- Image paste support
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            -- macOS tip: requires `pngpaste` (see verify section)
            use_absolute_path = true,
          },
        },
      },
    },
    opts = {
      -- default provider; switch to "openai" if desired
      provider = "openai", -- default provider e.g. OpenAI
      providers = {
        openai = { model = "gpt-5" }, -- normal GPT-5
        ["openai:thinking"] = { __inherited_from = "openai", model = "gpt-5-thinking" }, -- GPT-5 Thinking
        claude = { model = "claude-sonnet-4-5" },
      },

      -- use LazyVim's defaults: fzf-lua selector, snacks input
      selector = { provider = "telescope" },
      input = { provider = "snacks" },

      behaviour = {
        auto_approve_tool_permissions = false, -- require confirmation
        auto_apply_diff_after_generation = false, -- review diffs first
        minimize_diff = true,
        -- optional: use a modal dialog instead of inline buttons
        -- confirmation_ui_style = "popup",
      },

      windows = {
        position = "right",
        wrap = true,
        width = 45,
      },
    },
  },

  -- 2) Blink.CMP integration: add Avante source (via blink-cmp-avante)
  {
    "saghen/blink.cmp",
    dependencies = { "Kaiser-Yang/blink-cmp-avante" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}

      -- register the Avante source
      opts.sources.providers.avante = {
        module = "blink-cmp-avante",
        name = "Avante",
      }

      -- prepend 'avante' to the default source list without clobbering user prefs
      local def = vim.deepcopy(opts.sources.default or {})
      local seen = false
      for _, s in ipairs(def) do
        if s == "avante" then
          seen = true
          break
        end
      end
      if not seen then
        table.insert(def, 1, "avante")
      end
      opts.sources.default = def

      return opts
    end,
  },
}
