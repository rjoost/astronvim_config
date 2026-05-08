-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(_, opts)
    -- Configuration table of features provided by AstroLSP
    opts.features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    }
    -- customize lsp formatting options
    opts.formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {},
        ignore_filetypes = {
          "yaml",
          "yml",
          "yaml.ansible",
          "python",
        },
      },
      disabled = {
        "yamlls",
      },
      timeout_ms = 1000,
    }
    -- enable servers that you already have installed without mason
    opts.servers = {}
    -- customize language server configuration options passed to `lspconfig`
    -- NOTE: require("schemastore") is safe here because this function runs
    -- after plugins are loaded, not at spec-parse time.
    ---@diagnostic disable: missing-fields
    opts.config = {
      yamlls = {
        settings = {
          yaml = {
            format = { enable = false },
            schemas = require("schemastore").yaml.schemas(),
            schemaStore = { enable = false, url = "" },
          },
        },
      },
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },
      ansiblels = {
        settings = {
          ansible = {
            ansible = { path = "ansible" },
            executionEnvironment = { enabled = false },
            python = { interpreterPath = "python3" },
            validation = {
              enabled = true,
              lint = { enabled = true, path = "ansible-lint" },
            },
          },
        },
        filetypes = { "yaml.ansible" },
      },
    }
    -- customize how language servers are attached
    opts.handlers = {}
    -- Configure buffer local auto commands to add when attaching a language server
    opts.autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    }
    -- mappings to be set up on attaching of a language server
    opts.mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    }
    opts.on_attach = function(client, bufnr) end
    return opts
  end,
}
