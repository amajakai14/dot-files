local lsp = require("lsp-zero")
local nvim_lsp = require('lspconfig')



lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
	'prismals',
	'pylsp',
	'pyright',
})

-- Fix Undefined global 'vim'
lsp.configure('lua-language-server', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

require('sonarlint').setup({
   server = {
      cmd = {
         'sonarlint-language-server',
         -- Ensure that sonarlint-language-server uses stdio channel
         '-stdio',
         '-analyzers',
         -- paths to the analyzers you need, using those for python and java in this example
         vim.fn.expand("/Users/means/.local/share/sonarlint-analyzers/sonarjs.jar"),
         vim.fn.expand("/Users/means/.local/share/sonarlint-analyzers/sonarpython.jar"),
         vim.fn.expand("/Users/means/.local//share/sonarlint-analyzers/sonarcfamily.jar"),
         vim.fn.expand("/Users/means/.local//share/sonarlint-analyzers/sonarjava.jar"),
      },
      -- All settings are optional
      settings = {
         -- The default for sonarlint is {}, this is just an example
         sonarlint = {
            rules = {
               ['typescript:S101'] = { level = 'on', parameters = { format = '^[A-Z][a-zA-Z0-9]*$' } },
               ['typescript:S103'] = { level = 'on', parameters = { maximumLineLength = 180 } },
               ['typescript:S106'] = { level = 'on' },
               ['typescript:S107'] = { level = 'on', parameters = { maximumFunctionParameters = 7 } }
            }
         }
      }
   },
   filetypes = {
      -- Tested and working
      'python',
      'cpp',
			'typescript',
			'java',
   }
})

local on_attach = function(client, bufnr)
  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Format", { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.formatting_seq_sync() end
    })
  end
end

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" }
}

lsp.configure('tsserver', {
	settings = {
		init_options = {
			preferences = {
				importModuleSpecifierPreference = 'relative'
			}
		}
	}
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[e", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end
end)


lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

