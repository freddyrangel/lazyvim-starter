return {
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup({
        -- List of file types to enable the plugin on
        "css",
        "javascript",
        "html",
        "lua",
        "typescript",
        -- Add more file types as needed
      }, {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- Disable parsing of color names like "Blue" or "Red"
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true, -- Enable rgb() and rgba() functions
        hsl_fn = true, -- Enable hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- You can add more options here if needed
      })
    end,
  },
}
