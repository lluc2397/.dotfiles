local opts = {
    ensure_installed = {
        "bashls",
        "tsserver",
        "lua_ls",
        "rust_analyzer",
        "ruff_lsp",
        "volar",
        "pyright",
        "bufls",
    },

    automatic_installation = true,
}

local config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
        opts.buffer = bufnr

        local function buf_set_option(...)
            vim.api.nvim_buf_set_option(bufnr, ...)
        end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gd", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gD", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
    local configs = require 'lspconfig.configs'

    configs.testingls = {
        default_config = {
            cmd = { "/home/lucas/Projects/knowbase/testing-ls/target/debug/testing-ls" },
            filetypes = { 'lua', "md" },
            root_dir = lspconfig.util.root_pattern("/home/lucas/Projects/knowbase/testing-ls/Cargo.toml"),
        },
    }
    lspconfig.testingls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
    lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })

    lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })

    lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })

    lspconfig.bufls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })

    lspconfig.volar.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })

    lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            pyright = {
                disableOrganizeImports = false,
                analysis = {
                    useLibraryCodeForTypes = true,
                    autoSearchPaths = true,
                    diagnosticMode = "workspace",
                    autoImportCompletions = true,
                },
            },
        },
    })

    lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            ['rust-analyzer'] = {
                diagnostics = {
                    enable = false,
                },
                inlayHints = {
                    enable = true,
                    showParameterNames = true,
                    parameterHintsPrefix = "<- ",
                    otherHintsPrefix = "=> ",
                }
            }
        }
    })

    lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { -- custom settings for lua
            Lua = {
                -- make the language server recognize "vim" global
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    -- make language server aware of runtime files
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.stdpath("config") .. "/lua"] = true,
                    },
                },
            },
        },
    })
end

return {
    "williamboman/mason-lspconfig.nvim",
    opts = opts,
    --event = "BufReadPre",
    lazy = false,
    config = config,
    dependencies = {
        "williamboman/mason.nvim",
        'neovim/nvim-lspconfig',    -- Collection of configurations for built-in LSP client
        'hrsh7th/nvim-cmp',         -- Autocompletion plugin
        'hrsh7th/cmp-nvim-lsp',     -- LSP source for nvim-cmp
        'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
    },
}
