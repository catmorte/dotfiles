return {
  updater = {
    channel = "stable",
  },
  polish = function()
    vim.cmd "colorscheme dracula"
    -- vim.cmd("colorscheme gruvbox-flat")
    -- vim.g.gruvbox_flat_style = "hard"
    vim.cmd "set guicursor=i:ver1"
    vim.cmd "set guicursor+=a:blinkon1"
  end,

  highlights = {
    -- set highlights for all themes
    -- use a function override to let us use lua to retrieve colors from highlight group
    -- there is no default table so we don't need to put a parameter for this function
    init = function()
      local get_hlgroup = require("astronvim.utils").get_hlgroup
      -- get highlights from highlight groups
      -- local normal = get_hlgroup "Normal"
      -- local fg, bg = normal.fg, normal.bg
      -- local bg_alt = get_hlgroup("Visual").bg
      -- local green = get_hlgroup("String").fg
      -- local red = get_hlgroup("Error").fg
      -- return a table of highlights for telescope based on colors gotten from highlight groups
      return {
        -- TelescopeBorder = { fg = bg_alt, bg = bg },
        -- TelescopeNormal = { bg = bg },
        -- TelescopePreviewBorder = { fg = bg, bg = bg },
        -- TelescopePreviewNormal = { bg = bg },
        -- TelescopePreviewTitle = { fg = bg, bg = green },
        -- TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
        -- TelescopePromptNormal = { fg = fg, bg = bg_alt },
        -- TelescopePromptPrefix = { fg = red, bg = bg_alt },
        -- TelescopePromptTitle = { fg = bg, bg = red },
        -- TelescopeResultsBorder = { fg = bg, bg = bg },
        -- TelescopeResultsNormal = { bg = bg },
        -- TelescopeResultsTitle = { fg = bg, bg = bg },
      }
    end,
  },
  dap = {
    adapters = {
      delve = {
        type = "server",
        port = "${port}",
        executable = {
          command = "dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      },
    },
    configurations = {
      go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug test", 
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        {
          type = "delve",
          name = "Debug test (go.mod)",
          request = "launch",
          mode = "test",
          program = "./${relativeFileDirname}",
        },
      },
    },
  },
  lsp = {
    servers = {
      "dartls",
      "clangd",
    },
    setup_handlers = {
      -- add custom handler
      dartls = function(_, opts) require("flutter-tools").setup { lsp = opts } end,
    },
    config = {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
        cmd = {
          "clangd",
          "--background-index",
          "-j=3",
          "--pretty",
        },
        filetypes = { "c", "cpp" },
      },
      dartls = {
        color = {
          enabled = true,
        },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
        },
      },
    },
  },
  plugins = {
    {
      "p00f/clangd_extensions.nvim", -- install lsp plugin
      init = function()
        -- load clangd extensions when clangd attaches
        local augroup = vim.api.nvim_create_augroup("clangd_extensions", { clear = true })
        vim.api.nvim_create_autocmd("LspAttach", {
          group = augroup,
          desc = "Load clangd_extensions with clangd",
          callback = function(args)
            if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
              require "clangd_extensions"
              -- add more clangd setup here as needed such as loading autocmds
              vim.api.nvim_del_augroup_by_id(augroup) -- delete auto command since it only needs to happen once
            end
          end,
        })
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      opts = function(_, opts)
        local actions = require "telescope.actions"
        opts.defaults.file_ignore_patterns = { "node_modules" }
        opts.defaults.mappings.n["<Esc>"] = actions.close
      end,
    },
    "Mofiqul/dracula.nvim",
     "projekt0n/github-nvim-theme",
    "Mofiqul/dracula.nvim",
    "akinsho/flutter-tools.nvim",
    "AstroNvim/astrocommunity",
    "rebelot/kanagawa.nvim",
    {
      "eddyekofo94/gruvbox-flat.nvim",
      priority = 1000,
      enabled = true,
      config = function() vim.cmd [[colorscheme gruvbox-flat]] end,
    },
    { import = "astrocommunity.colorscheme.nightfox-nvim", enabled = true },
    { import = "astrocommunity.colorscheme.kanagawa-nvim", enabled = true },
    { import = "astrocommunity.colorscheme.rose-pine" },
    { import = "astrocommunity.colorscheme.catppuccin" },
    {
      "catppuccin/nvim",
      as = "catppuccin",
      config = function()
        require("catppuccin").setup {
          -- transparent_background = true,
          dim_inactive = {
            enabled = false,
          },
        }
      end,
    },
    { import = "astrocommunity.completion.copilot-lua" },
    { 
      "copilot.lua",
      opts = {
        suggestion = {
          keymap = {
            accept = "<C-l>",
            accept_word = false,
            accept_line = false,
            next = "<C-.>",
            prev = "<C-,>",
            dismiss = "<C/>",
          },
        },
      },
    },
  },
}
