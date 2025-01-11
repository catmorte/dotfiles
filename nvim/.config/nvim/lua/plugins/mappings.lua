return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>om"] = { ":Gen<CR>", desc = "Menu" },
          ["<Leader>o"] = { desc = "Ollama" },

          ["<Leader>x"] = { desc = "Misc" },
          ["<Leader>xp"] = { ":call setreg('+', expand('%:p'))<cr>", desc = "PWD" },
          ["<Leader>xc"] = { ":!chmod +x %<cr>", desc = "Make executable" },
          ["<Leader>xD"] = { ":.!base64 -d<cr>", desc = "base64 Decode" },
          ["<Leader>xE"] = { ":.!base64 <cr>", desc = "base64 Encode" },
          ["<Leader>xJ"] = { ":.!jq .<cr>", desc = "JQ Format file" },
          ["<Leader>xl"] = { ":execute 'split | terminal' getline('.')<CR>", desc = "Exec line to split pane" },
          ["<Leader>fA"] = {
            ':lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>',
            desc = "Find text (args)",
          },
          ["<Leader>xs"] = {
            '<cmd>lua require("plugins.switch_case").switch_case()<CR>',
            desc = "Snake case to camel case",
          },
          ["<Leader>xn"] = { ":OpenNotes<CR>", desc = "Notes: open" },
          ["<Leader>xa"] = { ":CreateNote<CR>", desc = "Notes: new note" },
        },
        v = {
          ["<Leader>om"] = { ":Gen<CR>", desc = "Menu" },
          ["<Leader>or"] = { ":Gen Review_Code<CR>", desc = "Review" },
          ["<Leader>oe"] = { ":Gen Enhance_Code<CR>", desc = "Enhance code" },
          ["<Leader>og"] = { ":Gen Enhance_Grammar_Spelling<CR>", desc = "Enhance grammar" },
          ["<Leader>o"] = { desc = "Ollama" },
          ["<Leader>x"] = { desc = "Misc" },
          ["<Leader>xx"] = { ":'<,'>!bash -e<cr>", desc = "Exec selected" },
          ["<Leader>xD"] = { ":'<,'>!base64 -d<cr>", desc = "base64 Decode" },
          ["<Leader>xE"] = { ":'<,'>!base64 <cr>", desc = "base64 Encode" },
          ["<Leader>xJ"] = { ":'<,'>!jq .<cr>", desc = "JQ Format selected" },
        },
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          -- this mapping will only be set in buffers with an LSP attached
          K = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover symbol details",
          },
          ["<Leader>xt"] = { ":GoTestAdd<CR>", desc = "Add go test" },
        },
      },
    },
  },
}
