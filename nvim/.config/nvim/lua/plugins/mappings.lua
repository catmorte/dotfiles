return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ["<Leader>om"] = { ":Gen<CR>", desc = "Menu" },
          ["<Leader>o"] = { desc = "Ollama" },
        },
        v = {
          ["<Leader>om"] = { ":Gen<CR>", desc = "Menu" },
          ["<Leader>or"] = { ":Gen Review_Code<CR>", desc = "Review" },
          ["<Leader>oe"] = { ":Gen Enhance_Code<CR>", desc = "Enhance code" },
          ["<Leader>og"] = { ":Gen Enhance_Grammar_Spelling<CR>", desc = "Enhance grammar" },
          ["<Leader>o"] = { desc = "Ollama" },
        },
      },
    },
  },
}
