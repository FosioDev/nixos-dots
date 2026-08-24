-- Collection of various small independent plugins/modules

return {
    {
        'echasnovski/mini.nvim',
        config = function()
            -- Better Around/Inside textobjects
            --
            -- Examples:
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
            --  - ci'  - [C]hange [I]nside [']quote
            require('mini.ai').setup { n_lines = 500 }

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require('mini.surround').setup()

            -- Sessions
            require('mini.sessions').setup {
                -- Whether to read default session if Neovim opened without file arguments
                autoread = false,

                -- Whether to write currently read session before quitting Neovim
                autowrite = false,

                -- Whether to force possibly harmful actions (meaning depends on function)
                force = { read = false, write = true, delete = true },

                -- Hook functions for actions. Default `nil` means 'do nothing'.
                hooks = {
                    -- Before successful action
                    pre = { read = nil, write = nil, delete = nil },
                    -- After successful action
                    post = { read = nil, write = nil, delete = nil },
                },

                -- Whether to print session path after action
                verbose = { read = false, write = true, delete = true },
            }

            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            local statusline = require 'mini.statusline'
            -- set use_icons to true if you have a Nerd Font
            statusline.setup { use_icons = vim.g.have_nerd_font }

            -- You can configure sections in the statusline by overriding their
            -- default behavior. For example, here we set the section for
            -- cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return '%2l:%-2v'
            end

            -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim
        end,
    },
}
