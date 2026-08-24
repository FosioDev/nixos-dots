-- Screenshot the video and copy it to the clipboard
-- https://github.com/ObserverOfTime/mpv-scripts/blob/master/clipshot.lua

---@author ObserverOfTime
---@license 0BSD

---@class ClipshotOptions
---@field name string
---@field type string
local o = {
    name = 'mpv-screenshot.jpeg',
    type = '' -- defaults to jpeg
}
require('mp.options').read_options(o, 'clipshot')

local file, cmd

file = '/tmp/'..o.name
if os.getenv('XDG_SESSION_TYPE') == 'wayland' then
    -- Does not paste from the clipboard to discord. I hate you discord
    cmd = {'sh', '-c', ('wl-copy < %q'):format(file)}
else
    local type = o.type ~= '' and o.type or 'image/jpeg'
    cmd = {'xclip', '-sel', 'c', '-t', type, '-i', file}
end


---@param arg string
---@return fun()
local function clipshot(arg)
    return function()
        mp.commandv('screenshot-to-file', file, arg)
        mp.command_native_async({'run', unpack(cmd)}, function(suc, _, err)
            mp.osd_message(suc and 'Copied screenshot to clipboard' or err, 1)
        end)
    end
end

mp.add_key_binding('c',     'clipshot-subs',   clipshot('subtitles'))
mp.add_key_binding('C',     'clipshot-video',  clipshot('video'))
mp.add_key_binding('Alt+c', 'clipshot-window', clipshot('window'))