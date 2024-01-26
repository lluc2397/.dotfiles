local function endsWith(str, suffix)
    return str:sub(- #suffix) == suffix
end

local function isPythonExecutable(executablePath)
    local suffix = "bin/python"
    return endsWith(executablePath, suffix)
end

local function getFromLocalVenv()
    local current_directory = vim.fn.getcwd()
    local venv_directory = current_directory .. '/venv'
    if vim.fn.isdirectory(venv_directory) == 1 then
        return venv_directory
    end
end

local function trimString(input)
    local result = input:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", " ")
    return result
end

local function getFromSystem()
    local handle = io.popen([[which python]])
    if handle == nil then
        return nil
    end
    local all_content = handle:read("*a")
    handle:close()
    local result = trimString(all_content)
    if isPythonExecutable(result) then
        return result
    end
end

local function setPythonVenv()
    if vim.fn.has('win32') == 1 then
        vim.g.python3_host_prog = 'C:/path/to/python3.exe'
    else
        local local_venv = getFromLocalVenv()
        local sys_python = getFromSystem()
        if sys_python ~= nil then
            vim.g.python3_host_prog = sys_python
        elseif local_venv ~= nil then
            -- make this setting optional maybe I want to use the neo
            -- config anyways 'cause ruff isn't installed or smt
            vim.g.python3_host_prog = local_venv
        else
            vim.g.python3_host_prog = "/home/lucas/miniconda3/envs/neo/bin/python"
        end
    end
end

function GetFnOrClassPath()
    local cword = vim.fn.expand("<cword>")
    local abs_filepath = vim.api.nvim_buf_get_name(0)
    print(abs_filepath)
    vim.fn.system('echo "' .. cword .. '" | xclip -selection clipboard')
end

vim.keymap.set("n", "<leader>cgf", "", { callback = GetFnOrClassPath })


setPythonVenv()
