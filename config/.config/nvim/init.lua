require "user.launch"
require "user.options"
require "user.keymaps"
spec "user.colorscheme"
spec "user.lspconfig"
-- cmp must come after lspconfig it seems
spec "user.cmp"
spec "user.lualine"
spec "user.neogit"
spec "user.telescope"
spec "user.whichkey"
require "user.lazy"
