require "user.launch"
require "user.options"
require "user.keymaps"
spec "user.colorscheme"
-- schemastore needs to be before lspconfig so we can get the right schemea
spec "user.schemastore"
spec "user.lspconfig"
-- cmp must come after lspconfig it seems
spec "user.cmp"
spec "user.lualine"
spec "user.neogit"
spec "user.telescope"
spec "user.whichkey"
require "user.lazy"
