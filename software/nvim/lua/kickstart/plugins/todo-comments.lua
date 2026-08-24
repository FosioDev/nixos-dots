-- Highlight todo, notes, etc in comments
-- NOTE: adding a note
-- PERF: fully optimised
-- TODO: What else?
-- TEST:
-- HACK: hmmm, this looks a bit funky
-- WARNING: ????
-- WARN:
-- FIXME:
-- FIX: this needs fixing
-- BUG: test

return {
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            -- signs = false
        },
    },
}
