-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.dart" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.templ" },
  { import = "astrocommunity.pack.angular" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.xml" },
  { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.python" },

  { import = "astrocommunity.colorscheme.catppuccin" },

  { import = "astrocommunity.recipes.telescope-lsp-mappings" },

  { import = "astrocommunity.search.nvim-hlslens" },

  { import = "astrocommunity.docker.lazydocker" },

  { import = "astrocommunity.editing-support.bigfile-nvim" },
  { import = "astrocommunity.editing-support.mini-splitjoin" },
  { import = "astrocommunity.editing-support.mini-operators" },
  { import = "astrocommunity.editing-support.nvim-context-vt" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  { import = "astrocommunity.editing-support.stickybuf-nvim" },
  { import = "astrocommunity.editing-support.telescope-undo-nvim" },

  { import = "astrocommunity.file-explorer.oil-nvim" },

  { import = "astrocommunity.git.blame-nvim" },
  { import = "astrocommunity.git.openingh-nvim" },

  { import = "astrocommunity.markdown-and-latex.glow-nvim" },

  { import = "astrocommunity.note-taking.global-note-nvim" },

  { import = "astrocommunity.programming-language-support.rest-nvim" },

  { import = "astrocommunity.split-and-window.minimap-vim" },

  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.test.nvim-coverage" },

  { import = "astrocommunity.utility.noice-nvim" },

  { import = "astrocommunity.pack.full-dadbod" },

  { import = "astrocommunity.completion.tabby-nvim" },

  { import = "astrocommunity.motion.mini-surround" },
}
