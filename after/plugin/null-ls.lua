local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
null_ls.setup({
    sources = {
        formatting.prettier,
        null_ls.builtins.completion.spell,
    },
})
