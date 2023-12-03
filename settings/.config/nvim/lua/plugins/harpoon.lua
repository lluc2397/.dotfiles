return {
    "theprimeagen/harpoon",
    lazy = true,
    keys = {
        {
			"<C-e>",
			function() require("harpoon.ui").toggle_quick_menu() end,
			desc = "Toggle menu",
		  },
          {
			"<C-l>",
			function() require("harpoon.ui").nav_prev() end,
			desc = "Go to prev",
		  },
          {
			"<C-a>",
			function() require("harpoon.ui").nav_next() end,
			desc = "Go to next",
		  },

        {
			"<leader>a",
			function() require("harpoon.mark").add_file() end,
			desc = "Add File",
		  },
          {
			"<leader>r",
			function() require("harpoon.mark").rm_file() end,
			desc = "Remove File",
		  },
          {
			"<leader>a",
			function() require("harpoon.mark").clear_all() end,
			desc = "Clear all",
		  },
    }
}