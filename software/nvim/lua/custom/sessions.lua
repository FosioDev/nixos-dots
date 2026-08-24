-- Add auto-sessions to mini.sessions plugin
-- Session names are generated dynamically based on the project directory and Git branch (if available)
-- Auto-save session on exit will only work if there is an active session in the project,
-- which can be set up, for example, via a custom key binding
-- When starting `nvim` with no arguments, will try to save session on exit
-- Whet starting `nvim .` (or another directory), will try to save session on exit
-- When starting `nvim some_file.txt` (or multiple files), won't do anything

-- Generate session name per project and per git branch for mini.sessions
local function get_git_branch()
    local branch = vim.fn.systemlist('git branch --show-current')[1] or ''
    return (vim.v.shell_error == 0 and branch ~= '') and branch or nil
end

local function session_name()
    local cwd = vim.fn.getcwd() -- current working directory
    local branch = get_git_branch()
    local name = cwd

    local sha = vim.fn.sha256(name)

    if branch then
        sha = sha .. '-' .. branch
        sha = vim.fn.sha256(sha) -- fix shit branch name
    end

    return sha
end

-- Auto save session per project and per git branch on exit
local function should_save_session()
    -- argc() returns the number of command line arguments
    local argc = vim.fn.argc()

    -- Case 1: nvim with no arguments
    if argc == 0 then
        return true
    end

    -- Case 2: nvim . (argument is a directory)
    if argc == 1 then
        local first_arg = vim.fn.argv(0) -- Get the first argument
        return vim.fn.isdirectory(first_arg) == 1
    end

    return false
end

local function session_exist()
    local session_dir = vim.fn.stdpath 'data' .. '/session/'
    local session_path = session_dir .. session_name()
    return vim.fn.filereadable(session_path) == 1
end

local function save_session()
    if not should_save_session() then
        return -- Do not save if there were files in the arguments
    end

    local name = session_name()
    require('mini.sessions').write(name)
    print('💾 Session Saved: ' .. name)
end

vim.api.nvim_create_autocmd('VimLeavePre', {
    desc = 'Auto save session on exit if session exists',
    callback = function()
        if not session_exist() then
            return -- Do not autosave session if there is no session in the project
        end

        save_session()
    end,
})

-- Session restore
local function restore_session()
    if not should_save_session() then
        return
    end
    if not session_exist() then
        return -- Do not restore session if there is no session in the project
    end

    local name = session_name()
    require('mini.sessions').read(name)
    print('💾 Session Restored: ' .. name)
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy', -- Lazy.nvim event
    desc = 'Auto restore session after plugin load',
    callback = function()
        -- Adding a small delay for stability
        vim.defer_fn(function()
            restore_session()
        end, 50)
    end,
    nested = true,
})

-- vim.keymap.set('n', '<Space><BS>', function()
--     restore_session()
-- end, { desc = 'Restore session' })

-- Session delete
vim.keymap.set('n', '<Space>Sd', function()
    local name = session_name()
    require('mini.sessions').delete(name)
    print('💾 Session Deleted: ' .. name)
end, { desc = '[S]ession [D]elete' })

-- Session create
vim.keymap.set('n', '<Space>Sc', function()
    save_session()
end, { desc = '[S]ession [C]reate' })
