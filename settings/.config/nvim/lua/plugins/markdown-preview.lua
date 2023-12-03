return {
    "lucas-montes/markdown-preview.nvim",
    lazy = true,
    keys = {
        {
			"<leader>md",
			":MarkdownPreview<CR>",
			desc = "Start visualization",
		  },
          {
			"<leader>mds",
			":MarkdownPreviewStop<CR>",
			desc = "Stop visualization",
		  },
    },
	run = function() vim.fn["mkdp#util#install"]() end,
}