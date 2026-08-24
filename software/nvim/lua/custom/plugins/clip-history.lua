-- Adding history for nvim clipboard

return {
    {
        'AckslD/nvim-neoclip.lua',
        dependencies = {
            { 'nvim-telescope/telescope.nvim' },
        },
        config = function()
            require('neoclip').setup()
            vim.keymap.set('n', '<leader>sc', ':Telescope neoclip<CR>', { desc = '[S]earch [C]lip history' })
        end,
    },
}
