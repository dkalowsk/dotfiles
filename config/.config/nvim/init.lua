require "user.launch"
require "user.options"
require "user.keymaps"
spec "user.colorscheme"
spec "user.devicons"
spec "user.gitsigns"
spec "user.guard"
-- schemastore and mason need to be before lspconfig so we can get the right schemea
spec "user.schemastore"
spec "user.treesitter"
spec "user.mason"
spec "user.osc52"
spec "user.lspconfig"
-- cmp must come after lspconfig it seems
spec "user.cmp"
spec "user.lualine"
spec "user.neogit"
spec "user.telescope"
spec "user.trouble"
spec "user.undotree"
spec "user.whichkey"
spec "user.gutentags"
require "user.lazy"
