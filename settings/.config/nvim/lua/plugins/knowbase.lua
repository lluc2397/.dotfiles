local config = function()
    require("knowbase").setup({
        folder = "/home/lucas/Notes"
    })
end

return {
    dir = "/home/lucas/Projects/knowbase/knowbase.nvim",
    lazy = true,
    config = config,
}