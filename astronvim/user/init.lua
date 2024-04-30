local prefix = "<leader>r"
local utils = require "astronvim.utils"

return {
  polish = function()
    -- vim.g.dracula_colorterm = 0
    -- vim.cmd "colorscheme github_light_default"
    -- vim.cmd "colorscheme nordic"
    -- vim.cmd "colorscheme gruvbox-flat"
    vim.cmd "colorscheme dracula"

    vim.filetype.add {
      extension = {
        templ = "templ",
      },
    }
    vim.g.gruvbox_flat_style = "hard"
    -- vim.opt.mouse = ""
    -- vim.cmd("highlight Normal ctermbg=NONE guibg=NONE")
    vim.cmd "set guicursor=i:ver1"
    vim.cmd "set guicursor+=a:blinkon1"
    vim.api.nvim_create_user_command("ToggleBlame", function(args) require("blame").toggle "*" end, { nargs = "*" })
  end,

  heirline = {
    -- define the separators between each section
    separators = {
      -- left = { "", " " }, -- separator for the left side of the statusline
      -- left = { "", " " }, -- separator for the left side of the statusline
      -- right = { " █", "" }, -- separator for the right side of the statusline
      -- right = { " ", "" }, -- separator for the right side of the statusline
      -- tab = { "", "" },
    },
    -- add new colors that can be used by heirline
    colors = function(hl)
      local get_hlgroup = require("astronvim.utils").get_hlgroup
      -- use helper function to get highlight group properties
      local comment_fg = get_hlgroup("Comment").fg
      hl.git_branch_fg = comment_fg
      hl.git_added = comment_fg
      hl.git_changed = comment_fg
      hl.git_removed = comment_fg
      hl.blank_bg = get_hlgroup("Folded").fg
      hl.file_info_bg = get_hlgroup("Visual").bg
      hl.nav_icon_bg = get_hlgroup("String").fg
      hl.nav_fg = hl.nav_icon_bg
      hl.folder_icon_bg = get_hlgroup("Error").fg
      return hl
    end,
    attributes = {
      mode = { bold = true },
    },
    icon_highlights = {
      file_icon = {
        statusline = false,
      },
    },
  },
  icons = {
    VimIcon = "",
    ScrollText = "",
    GitBranch = "",
    GitAdd = "",
    GitChange = "",
    GitDelete = "",
  },

  mappings = {
    -- first key is the mode
    n = {
      ["<leader>gt"] = {
        "<cmd>ToggleBlame<cr>",
        desc = "Toggle blame",
      },

      ["<Leader>um"] = { "<cmd>MinimapToggle<cr>", desc = "Toggle minimap" },
      ["<leader>gf"] = {
        "<cmd>OpenInGHFileLines<cr>",
        desc = "Open GH on Line",
      },
      ["<leader>gF"] = {
        "<cmd>OpenInGHFile<cr>",
        desc = "Open GH File",
      },
      ["<leader>gR"] = {
        "<cmd>OpenInGHRepo<cr>",
        desc = "Open GH Repo",
      },

      ["<leader>j"] = {
        desc = "JQ",
      },
      ["<leader>jl"] = {
        "<cmd>JqxList<cr>",
        desc = "JQ list",
      },
      ["<leader>jq"] = {
        "<cmd>JqxQuery<cr>",
        desc = "JQ query",
      },
      ["<leader>tr"] = {
        "<cmd>OverseerRunCmd<cr>",
        desc = "Overseer run cmd",
      },
      ["<leader>to"] = {
        "<cmd>OverseerToggle<cr>",
        desc = "Overseer toggle",
      },
    },
  },
  updater = {
    channel = "stable",
  },
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
          name = "Debug test", -- configuration for debugging test files
          request = "launch",
          mode = "test",
          program = "${file}",
        },
        -- works with go.mod packages and sub packages
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
      "templ",
    },
    setup_handlers = {
      -- add custom handler
      dartls = function(_, opts) require("flutter-tools").setup { lsp = opts } end,
    },
    config = {
      -- hover = {
      --   enabled = false,
      -- },
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
        -- any changes you want to make to the LSP setup, for example
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
    { "typos-lsp" },
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
    -- { "dracula/vim", lazy = false },
    { "Mofiqul/dracula.nvim", lazy = false },
    { "projekt0n/github-nvim-theme", lazy = false, opts = { transparent = false } },
    -- { "Mofiqul/dracula.nvim", lazy = false },
    "akinsho/flutter-tools.nvim", -- add lsp plugin
    "AstroNvim/astrocommunity",
    "FabijanZulj/blame.nvim",
    { "almo7aya/openingh.nvim", cmd = { "OpenInGHRepo", "OpenInGHFile", "OpenInGHFileLines" } },
    "rebelot/kanagawa.nvim",
    {
      "eddyekofo94/gruvbox-flat.nvim",
      priority = 1000,
      lazy = false,
      enabled = true,
      config = function() vim.cmd [[colorscheme gruvbox-flat]] end,
    },

    { import = "astrocommunity.colorscheme.nightfox-nvim", lazy = false, enabled = true },
    { import = "astrocommunity.colorscheme.kanagawa-nvim", lazy = false, enabled = true },
    { import = "astrocommunity.colorscheme.rose-pine", lazy = false },

    { import = "astrocommunity.colorscheme.catppuccin", lazy = false },
    {
      "catppuccin/nvim",
      lazy = false,
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
    {
      "elixir-tools/elixir-tools.nvim",
      version = "*",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
        local elixir = require "elixir"
        local elixirls = require "elixir.elixirls"

        elixir.setup {
          nextls = { enable = true },
          credo = {},
          elixirls = {
            enable = true,
            settings = elixirls.settings {
              dialyzerEnabled = false,
              enableTestLenses = false,
            },
            on_attach = function(client, bufnr)
              vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
              vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
              vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
            end,
          },
        }
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
    },

    { import = "astrocommunity.completion.copilot-lua" },
    { -- further customize the options set by the community
      "copilot.lua",
      opts = {
        filetypes = {
          lua = true,
          javascript = true,
          typescript = true,
          golang = true,
          go = true,
          cpp = true,
          sh = true,
          py = true,
          python = true,
          makefile = true,
          ["*"] = false,
        },
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
    {
      "lukas-reineke/headlines.nvim",
      opts = function()
        local opts = {}
        for _, ft in ipairs { "markdown", "norg", "rmd", "org" } do
          opts[ft] = {
            headline_highlights = {},
          }
          for i = 1, 6 do
            local hl = "Headline" .. i
            vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
            table.insert(opts[ft].headline_highlights, hl)
          end
        end
        return opts
      end,
      ft = { "markdown", "norg", "rmd", "org" },
      config = function(_, opts)
        -- PERF: schedule to prevent headlines slowing down opening a file
        vim.schedule(function()
          require("headlines").setup(opts)
          require("headlines").refresh()
        end)
      end,
    },
    {
      "levouh/tint.nvim",
      event = "User AstroFile",
      opts = {
        highlight_ignore_patterns = { "WinSeparator", "neo-tree", "Status.*" },
        tint = -45, -- Darken colors, use a positive value to brighten
        saturation = 0.8, -- Saturation to preserve
      },
    },
    {
      "antonk52/bad-practices.nvim",
      opts = {},
    },
    {
      "aserowy/tmux.nvim",
      config = function() return require("tmux").setup() end,
    },
    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require "astronvim.utils.status"
        opts.statusline = { -- statusline
          hl = { fg = "fg", bg = "bg" },
          status.component.mode { mode_text = { padding = { left = 1, right = 1 } } }, -- add the mode text
          status.component.foldcolumn(),
          status.component.numbercolumn(),
          status.component.signcolumn(),
          status.component.git_branch(),
          status.component.file_info { filetype = {}, filename = false, file_modified = false },
          status.component.git_diff(),
          status.component.diagnostics(),
          status.component.fill(),
          status.component.cmd_info(),
          status.component.fill(),
          status.component.lsp(),
          status.component.treesitter(),
          status.component.nav(),
          -- remove the 2nd mode indicator on the right
        }

        -- opts.statuscolumn = {
        --   init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        --   status.component.foldcolumn(),
        --   status.component.numbercolumn(),
        --   status.component.signcolumn(),
        -- }

        -- return the final configuration table
        return opts
      end,
    },
    {
      "gennaro-tedesco/nvim-jqx",
      cmd = {
        "JqxQuery",
        "JqxList",
      },
      ft = { "json", "yaml" },
    },
    {
      "rest-nvim/rest.nvim",
      ft = { "http", "json" },
      cmd = {
        "RestNvim",
        "RestNvimPreview",
        "RestNvimLast",
      },
      dependencies = { "nvim-lua/plenary.nvim" },

      keys = {
        { prefix, desc = "RestNvim" },
        { prefix .. "r", "<Plug>RestNvim", desc = "Run request" },
      },
      opts = {},
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "http", "json" })
        end
      end,
    },
    {
      "stevearc/overseer.nvim",
      cmd = {
        "OverseerOpen",
        "OverseerClose",
        "OverseerToggle",
        "OverseerSaveBundle",
        "OverseerLoadBundle",
        "OverseerDeleteBundle",
        "OverseerRunCmd",
        "OverseerRun",
        "OverseerInfo",
        "OverseerBuild",
        "OverseerQuickAction",
        "OverseerTaskAction ",
        "OverseerClearCache",
      },
      opts = {},
    },
    {
      "catppuccin/nvim",
      optional = true,
      lazy = false,
      opts = { integrations = { overseer = true } },
    },
    {
      "kevinhwang91/nvim-hlslens",
      opts = {},
      event = "BufRead",
      init = function() vim.on_key(nil, vim.api.nvim_get_namespaces()["auto_hlsearch"]) end,
    },
    {
      "wfxr/minimap.vim",
      cmd = { "Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight" },
      dependencies = {
        {
          "AstroNvim/astrocore",
          opts = {
            mappings = {
              n = {
                ["<Leader>um"] = { "<Cmd>MinimapToggle<CR>", desc = "Toggle minimap" },
              },
            },
            options = {
              g = {
                minimap_width = 10,
                minimap_auto_start = 1,
                minimap_auto_start_win_enter = 1,
                minimap_block_filetypes = {
                  "fugitive",
                  "nerdtree",
                  "tagbar",
                  "fzf",
                  "qf",
                  "netrw",
                  "NvimTree",
                  "lazy",
                  "mason",
                  "prompt",
                  "TelescopePrompt",
                  "noice",
                  "notify",
                  "neo-tree",
                },
                minimap_highlight_search = 1,
                minimap_git_colors = 1,
              },
            },
          },
        },
      },
    },

    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require "astronvim.utils.status"
        opts.statusline = {
          -- default highlight for the entire statusline
          hl = { fg = "fg", bg = "bg" },
          -- each element following is a component in astronvim.utils.status module

          -- add the vim mode component
          status.component.mode {
            -- enable mode text with padding as well as an icon before it
            mode_text = { icon = { kind = "VimIcon", padding = { right = 1, left = 1 } } },
            -- surround the component with a separators
            surround = {
              -- it's a left element, so use the left separator
              separator = "left",
              -- set the color of the surrounding based on the current mode using astronvim.utils.status module
              color = function() return { main = status.hl.mode_bg(), right = "blank_bg" } end,
            },
          },
          -- we want an empty space here so we can use the component builder to make a new section with just an empty string
          status.component.builder {
            { provider = "" },
            -- define the surrounding separator and colors to be used inside of the component
            -- and the color to the right of the separated out section
            surround = { separator = "left", color = { main = "blank_bg", right = "file_info_bg" } },
          },
          -- add a section for the currently opened file information
          status.component.file_info {
            -- enable the file_icon and disable the highlighting based on filetype
            file_icon = { padding = { left = 0 } },
            filename = { fallback = "Empty" },
            -- add padding
            padding = { right = 1 },
            -- define the section separator
            surround = { separator = "left", condition = false },
          },
          -- add a component for the current git branch if it exists and use no separator for the sections
          status.component.git_branch { surround = { separator = "none" } },
          -- add a component for the current git diff if it exists and use no separator for the sections
          status.component.git_diff { padding = { left = 1 }, surround = { separator = "none" } },
          -- fill the rest of the statusline
          -- the elements after this will appear in the middle of the statusline
          status.component.fill(),
          -- add a component to display if the LSP is loading, disable showing running client names, and use no separator
          status.component.lsp { lsp_client_names = false, surround = { separator = "none", color = "bg" } },
          -- fill the rest of the statusline
          -- the elements after this will appear on the right of the statusline
          status.component.fill(),
          -- add a component for the current diagnostics if it exists and use the right separator for the section
          status.component.diagnostics { surround = { separator = "right" } },
          -- add a component to display LSP clients, disable showing LSP progress, and use the right separator
          status.component.lsp { lsp_progress = false, surround = { separator = "right" } },
          -- NvChad has some nice icons to go along with information, so we can create a parent component to do this
          -- all of the children of this table will be treated together as a single component
          {
            -- define a simple component where the provider is just a folder icon
            status.component.builder {
              -- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
              { provider = require("astronvim.utils").get_icon "FolderClosed" },
              -- add padding after icon
              padding = { right = 1 },
              -- set the foreground color to be used for the icon
              hl = { fg = "bg" },
              -- use the right separator and define the background color
              surround = { separator = "right", color = "folder_icon_bg" },
            },
            -- add a file information component and only show the current working directory name
            status.component.file_info {
              -- we only want filename to be used and we can change the fname
              -- function to get the current working directory name
              filename = { fname = function(nr) return vim.fn.getcwd(nr) end, padding = { left = 1 } },
              -- disable all other elements of the file_info component
              file_icon = false,
              file_modified = false,
              file_read_only = false,
              -- use no separator for this part but define a background color
              surround = { separator = "none", color = "file_info_bg", condition = false },
            },
          },
          -- the final component of the NvChad statusline is the navigation section
          -- this is very similar to the previous current working directory section with the icon
          { -- make nav section with icon border
            -- define a custom component with just a file icon
            status.component.builder {
              { provider = require("astronvim.utils").get_icon "ScrollText" },
              -- add padding after icon
              padding = { right = 1 },
              -- set the icon foreground
              hl = { fg = "bg" },
              -- use the right separator and define the background color
              -- as well as the color to the left of the separator
              surround = { separator = "right", color = { main = "nav_icon_bg", left = "file_info_bg" } },
            },
            -- add a navigation component and just display the percentage of progress in the file
            status.component.nav {
              -- add some padding for the percentage provider
              percentage = { padding = { right = 1 } },
              -- disable all other providers
              ruler = false,
              scrollbar = false,
              -- use no separator and define the background color
              surround = { separator = "none", color = "file_info_bg" },
            },
          },
        }

        -- return the final options table
        return opts
      end,
    },

    { -- override nvim-cmp plugin
      "hrsh7th/nvim-cmp",
      keys = { ":", "/", "?" }, -- lazy load cmp on more keys along with insert mode
      dependencies = {
        "hrsh7th/cmp-cmdline", -- add cmp-cmdline as dependency of cmp
      },
      config = function(plugin, opts)
        local cmp = require "cmp"
        -- run cmp setup
        cmp.setup(opts)

        -- configure `cmp-cmdline` as described in their repo: https://github.com/hrsh7th/cmp-cmdline#setup
        cmp.setup.cmdline("/", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        })
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            {
              name = "cmdline",
              option = {
                ignore_cmds = { "Man", "!" },
              },
            },
          }),
        })
      end,
    },

    {
      "AlexvZyl/nordic.nvim",
      lazy = false,
      priority = 1000,
      config = function() require("nordic").load() end,
    },
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      opts = {
        -- add any options here
        lsp = {
          hover = {
            enabled = false,
          },
          signature = {
            enabled = false,
          },
        },
      },
      dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
        "rcarriga/nvim-notify",
      },
    },
  },
}
