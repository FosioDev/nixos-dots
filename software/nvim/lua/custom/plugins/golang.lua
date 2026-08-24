-- Feature-Rich Go Plugin for Neovim

return {
    {
        'ray-x/go.nvim',
        dependencies = { -- optional packages
            'ray-x/guihua.lua',
            'neovim/nvim-lspconfig',
            'nvim-treesitter/nvim-treesitter',
        },
        config = function()
            require('go').setup {
                tag_options = '', -- sets options sent to gomodifytags, i.e., json=omitempty
            }
            vim.keymap.set({ 'n' }, '<leader>gta', ':GoAddTag<CR>', { desc = '[G]o [T]ag [A]dd' })
            vim.keymap.set({ 'n' }, '<leader>gtr', ':GoRmTag<CR>', { desc = '[G]o [T]ag [R]emove' })
            vim.keymap.set({ 'n' }, '<leader>gs', ':GoFillStruct<CR>', { desc = '[G]o fill [S]truct' })
            vim.keymap.set({ 'n' }, '<leader>gc', ':GoFillSwitch<CR>', { desc = '[G]o fill Switch [C]ase' })
            -- Go Fix Plurals - change func foo(b int, a int, r int) -> func foo(b, a, r int)
            vim.keymap.set({ 'n' }, '<leader>gp', ':GoFixPlurals<CR>', { desc = '[G]o fix [P]lurals' })
            vim.keymap.set({ 'n' }, '<leader>ge', ':GoIfErr<CR>', { desc = '[G]o if [E]rr' })
            vim.keymap.set({ 'n' }, '<leader>gi', ':GoImports<CR>', { desc = '[G]o [I]mports' })
        end,
        event = { 'CmdlineEnter' },
        ft = { 'go', 'gomod' },
        -- build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
}
