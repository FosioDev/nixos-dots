-- Neo-tree is a Neovim plugin to browse the file system
-- Не умеет работать со сессиями
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
            'MunifTanjim/nui.nvim',
            { -- Optional image support in preview window: See `# Preview Mode` for more information
                '3rd/image.nvim',
                build = false, -- so that it doesn't build the rock
                opts = {
                    backend = 'ueberzug', -- or "kitty"
                    processor = 'magick_cli', -- or "magick_rock"
                },
            },
        },
        lazy = false, -- neo-tree will lazily load itself
        keys = {
            { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
        },
        ---@module "neo-tree"
        ---@type neotree.Config?
        opts = {
            close_if_last_window = true,
            filesystem = {
                window = {
                    mappings = {
                        ['\\'] = 'close_window',
                    },
                },
                filtered_items = {
                    visible = true, -- Show hidden files
                    -- hide_dotfiles = false,
                    -- hide_gitignored = true,
                },
            },
        },
    },
}
