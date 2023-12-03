return {
	"nvim-telescope/telescope.nvim",
	  dependencies = {
		'nvim-lua/plenary.nvim',
		{
		  "debugloop/telescope-undo.nvim",
		  keys = { { "<leader>U", "<cmd>Telescope undo<cr>" } },
		  config = function()
			require("telescope").load_extension("undo")
		  end,
		},
	  },
	  keys = {
		{
			"<leader>fs",
			function()
			  require("telescope.builtin").grep_string({
				cwd = require("lazy.core.config").options.root,
				search = vim.fn.input("Grep > "),
			  })
			end,
			desc = "Find Git File",
		  },
		{
			"<C-p>",
			function()
			  require("telescope.builtin").git_files({
				cwd = require("lazy.core.config").options.root,
			  })
			end,
			desc = "Find Git File",
		  },

		{
		  "<leader>ff",
		  function()
			require("telescope.builtin").find_files({
			  cwd = require("lazy.core.config").options.root,
			})
		  end,
		  desc = "Find Plugin File",
		},
		{
		  "<leader>fg",
		  function()
			local files = {} ---@type table<string, string>
			for _, plugin in pairs(require("lazy.core.config").plugins) do
			  repeat
				if plugin._.module then
				  local info = vim.loader.find(plugin._.module)[1]
				  if info then
					files[info.modpath] = info.modpath
				  end
				end
				plugin = plugin._.super
			  until not plugin
			end
			require("telescope.builtin").live_grep({
			  default_text = "/",
			  search_dirs = vim.tbl_values(files),
			})
		  end,
		  desc = "Find Lazy Plugin Spec",
		},
	  },
	  lazy = false,
	  opts = {
		defaults = {
		  layout_strategy = "horizontal",
		  layout_config = {
			horizontal = {
			  prompt_position = "top",
			  preview_width = 0.5,
			},
			width = 0.8,
			height = 0.8,
			preview_cutoff = 120,
		  },
		  sorting_strategy = "ascending",
		  winblend = 0,
		},
	  },
  }