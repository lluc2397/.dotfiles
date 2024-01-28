local config = function()
    require("knowbase").setup({
        folder = "/home/lucas/Notes"
    })
end

local function is_directory(path)
    return vim.fn.isdirectory(path) == 1
end

local local_dir = "/home/lucas/Projects/knowbase/knowbase.nvim"

if is_directory(local_dir) then
    return {
        dir = local_dir,
        lazy = false,
        config = config,
    }
else
    return {
        "lucas-montes/knowbase",
        lazy = false,
        config = config,
    }
end
