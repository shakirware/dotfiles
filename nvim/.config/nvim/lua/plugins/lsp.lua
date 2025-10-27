-- lua/plugins/lsp.lua
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} }, -- LSP status
      'hrsh7th/cmp-nvim-lsp', -- completion capabilities
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(event)
          ---@diagnostic disable: missing-parameter, param-type-mismatch

          local map = function(keys, fn, desc, mode)
            vim.keymap.set(mode or 'n', keys, fn, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local tb = require 'telescope.builtin'
          map('gd', tb.lsp_definitions, 'Goto Definition')
          map('gr', tb.lsp_references, 'Goto References')
          map('gI', tb.lsp_implementations, 'Goto Implementation')
          map('<leader>D', tb.lsp_type_definitions, 'Type Definition')
          map('<leader>ds', tb.lsp_document_symbols, 'Document Symbols')
          map('<leader>ws', tb.lsp_dynamic_workspace_symbols, 'Workspace Symbols')
          map('<leader>rn', function()
            vim.lsp.buf.rename()
          end, 'Rename')
          map('<leader>ca', function()
            vim.lsp.buf.code_action()
          end, 'Code Action', { 'n', 'x' })
          map('gD', function()
            vim.lsp.buf.declaration()
          end, 'Goto Declaration')
          map('K', function()
            vim.lsp.buf.hover()
          end, 'Hover')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local bufnr = event.buf

          -- Document highlight on cursor hold
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local hl_group = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = bufnr,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = bufnr,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
              callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = hl_group, buffer = e.buf }
              end,
            })
          end

          -- Inlay hints: enable by default if supported, and keep a toggle
          if client and vim.lsp.inlay_hint and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            local ih = vim.lsp.inlay_hint

            -- Enable by default
            local ok = pcall(ih.enable, bufnr, true)
            if not ok then
              pcall(ih.enable, true, { bufnr = bufnr })
            end

            -- Toggle mapping
            map('<leader>th', function()
              local enabled = false
              if type(ih.is_enabled) == 'function' then
                local ok1, res1 = pcall(ih.is_enabled, bufnr)
                if ok1 then
                  enabled = res1
                else
                  local ok2, res2 = pcall(ih.is_enabled, { bufnr = bufnr })
                  if ok2 then
                    enabled = res2
                  end
                end
              end
              local ok2 = pcall(ih.enable, bufnr, not enabled)
              if not ok2 then
                pcall(ih.enable, not enabled, { bufnr = bufnr })
              end
            end, 'Toggle Inlay Hints')
          end

          ---@diagnostic enable: missing-parameter, param-type-mismatch
        end,
      })

      -- Capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- LSP server configs
      local servers = {
        ts_ls = {},
        pyright = {
          settings = { python = { analysis = { extraPaths = { 'src' } } } },
        },
        lua_ls = {
          settings = { Lua = { completion = { callSnippet = 'Replace' } } },
        },
        postgres_lsp = {
          filetypes = { 'sql', 'pgsql', 'plpgsql', 'psql' },
        },
      }

      -- Map LSP servers to their Mason package names
      local mason_pkg_for = {
        ts_ls = 'typescript-language-server',
        pyright = 'pyright',
        lua_ls = 'lua-language-server',
      }

      -- Extra tools
      local extra_tools = {
        'stylua',
        'postgrestools',
        'black',
        'isort',
        'prettier',
        'pgformatter',
      }
      local ensure_tools = vim.tbl_values(mason_pkg_for)
      vim.list_extend(ensure_tools, extra_tools)
      require('mason-tool-installer').setup {
        ensure_installed = ensure_tools,
      }

      local ensure_servers = vim.tbl_keys(mason_pkg_for)
      require('mason-lspconfig').setup {
        ensure_installed = ensure_servers,
        handlers = {
          function(name)
            local server = servers[name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[name].setup(server)
          end,
        },
      }

      require('lspconfig').postgres_lsp.setup(vim.tbl_deep_extend('force', {
        capabilities = capabilities,
      }, servers.postgres_lsp))
    end,
  },
}
