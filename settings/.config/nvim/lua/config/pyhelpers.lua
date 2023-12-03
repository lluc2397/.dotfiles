function endsWith(str, suffix)
    return str:sub(- #suffix) == suffix
end

function isPythonExecutable(executablePath)
    local suffix = "bin/python"
    return endsWith(executablePath, suffix)
end

function getFromLocalVenv()
    local current_directory = vim.fn.getcwd()
    local venv_directory = current_directory .. '/venv'
    if vim.fn.isdirectory(venv_directory) == 1 then
        return venv_directory
    end
end

function trimString(input)
    local result = input:gsub("^%s*(.-)%s*$", "%1"):gsub("%s+", " ")
    return result
end

function getFromSystem()
    local handle = io.popen([[which python]])
    local all_content = handle:read("*a")
    handle:close()
    local result = trimString(all_content)
    if isPythonExecutable(result) then
        return result
    end
end

function setPythonVenv()
    if vim.fn.has('win32') == 1 then
        vim.g.python3_host_prog = 'C:/path/to/python3.exe'
    else
        local local_venv = getFromLocalVenv()
        local sys_python = getFromSystem()
        if sys_python ~= nil then
            print(sys_python)
            vim.g.python3_host_prog = sys_python
        elseif local_venv ~= nil then
            print(local_venv)
            vim.g.python3_host_prog = local_venv
        else
            print("Venv not found, defaulting to neo")
            vim.g.python3_host_prog = "/home/lucas/miniconda3/envs/neo/bin/python"
        end
    end
end

function GetFnOrClassPath()
    local cword = vim.fn.expand("<cword>")
    local abs_filepath = vim.api.nvim_buf_get_name(0)
    vim.fn.system('echo "' .. cword .. '" | xclip -selection clipboard')
end

vim.keymap.set("n", "<leader>gfp", "", { callback = GetFnOrClassPath })


setPythonVenv()
