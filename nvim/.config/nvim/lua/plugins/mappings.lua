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
          ["<Leader>xp"] = { ":r !pwd<cr>", desc = "PWD" },
          ["<Leader>xc"] = { ":!chmod +x <cr>", desc = "Make executable" },
          ["<Leader>xD"] = { ":.!base64 -d<cr>", desc = "base64 Decode" },
          ["<Leader>xE"] = { ":.!base64 <cr>", desc = "base64 Encode" },
          ["<Leader>xJ"] = { ":.!jq .<cr>", desc = "JQ Format file" },
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
}
