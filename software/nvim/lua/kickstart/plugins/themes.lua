-- You can easily change to a different colorscheme.
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.

-- Cмена тем тут сделана уёбищно
-- Чтоб сменить стандартную тему, надо раскомментировать vim.cmd.colorscheme под именем темы
-- и закомментировать это же у прошлой темы

-- В lazy.nvim параметр priority определяет порядок загрузки плагинов.
-- Чем выше значение priority, тем раньше загружается плагин.
-- Это особенно важно для тем, поскольку они часто требуют загрузки до других плагинов,
-- чтобы корректно применить стили.

-- https://dotfyle.com/neovim/colorscheme/top

-- Убедитесь, что Sonokai установлен через lazy.nvim или другой менеджер
local variants = { 'default', 'atlantis', 'andromeda', 'shusia', 'maia', 'espresso' }

-- Создаем псевдонимы для каждой темы
for _, variant in ipairs(variants) do
    local alias = 'sonokai-' .. variant
    vim.api.nvim_create_user_command('Colorscheme' .. variant, function()
        vim.g.sonokai_style = variant
        vim.cmd 'colorscheme sonokai'
    end, {})

    -- Регистрируем в Neovim как отдельный colorscheme
    vim.api.nvim_set_hl(0, alias, {})
    vim.cmd(string.format("autocmd ColorSchemePre %s let g:sonokai_style = '%s' | colorscheme sonokai", alias, variant))
end

return {
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        init = function()
            -- 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-day', 'tokyonight-night'
            -- vim.cmd.colorscheme 'tokyonight-night'
            vim.cmd.hi 'Comment gui=none' -- Убрать курсив у коммента в коде
        end,
    },
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        priority = 1000,
        init = function()
            -- 'rose-pine-moon', 'rose-pine-main', 'rose-pine-dawn'
            -- vim.cmd.colorscheme 'rose-pine-dawn'
        end,
    },

    ----------------------------------------------------------
    -- Гандоны не дают выбрать тему нормально               --
    -- Приходится конфиг переписывать ради выбора расцветок --
    ----------------------------------------------------------
    {
        'ellisonleao/gruvbox.nvim',
        priority = 1000,
        config = true,
        -- opts = ...
        init = function()
            local colors = require('gruvbox').palette
            colors.neutral_aqua = '#8bba7f'
            colors.bright_red = '#f2594b'
            colors.bright_green = '#a4ab43'
            -- Default options:
            require('gruvbox').setup {
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true, -- underline errors
                underline = true, -- underline links
                bold = false, -- bold keywords
                italic = {
                    strings = true,
                    emphasis = true, -- курсив выделения
                    comments = true,
                    operators = false,
                    folds = true, -- курсив для сворачиваемых блоков кода
                },
                strikethrough = true, -- зачёркиваниe удалённых или устаревших элементов
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = '', -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {
                    LspReferenceText = { -- ссылки на элементы под курсором
                        bg = '#504945',
                    },
                    LspReferenceWrite = {
                        bg = '#504945',
                    },
                    LspReferenceRead = {
                        bg = '#504945',
                    },
                    String = {
                        fg = colors.neutral_aqua,
                    },
                    ['@keyword.import.go'] = {
                        fg = colors.bright_red,
                    },
                },
                dim_inactive = false,
                transparent_mode = false,
            }
            vim.cmd.colorscheme 'gruvbox'
        end,
    },
    {
        'sainnhe/gruvbox-material',
        priority = 1000,
        init = function()
            -- 'hard', 'medium', 'soft'
            vim.g.gruvbox_material_background = 'medium'
            -- 'material', 'mix', 'original'
            vim.g.gruvbox_material_foreground = 'mix'
            -- 'grey', 'colored', 'highlighted'
            vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
            vim.g.gruvbox_material_diagnostic_line_highlight = 1
            vim.g.gruvbox_material_diagnostic_text_highlight = 1

            -- vim.g.gruvbox_material_inlay_hints_background = 'dimmed'
            -- vim.g.gruvbox_material_better_performance = 1
            -- vim.g.gruvbox_material_spell_foreground = 'colored'
            -- vim.g.gruvbox_material_enable_bold = 1
            -- vim.g.gruvbox_material_enable_italic = true
            -- vim.cmd.colorscheme 'gruvbox-material'
        end,
    },
}
