return {
    "ThePrimeagen/harpoon",
    dependencies = {
		"nvim-lua/plenary.nvim",
	},
    lazy = false,
    branch = "harpoon2",
    config = function()
      local harpoon = require("harpoon")
      ---@diagnostic disable-next-line: missing-parameter
      harpoon:setup()
      local function map(lhs, rhs, opts)
        vim.keymap.set("n", lhs, rhs, opts or {})
      end
      map("<leader>a", function() harpoon:list():append() end)
      map("<leader>r", function() harpoon:list():remove() end)
      map("<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      map("<C-a>", function() harpoon:list():prev() end)
      map("<C-l>", function() harpoon:list():next() end)
      map("<C-cl>", function() harpoon:list():clear() end)
    end
  }

