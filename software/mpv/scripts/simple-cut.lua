-- Simple cut script for mpv. Only for local files.

local start_time = nil
local end_time = nil
local format_start_time = nil
local format_end_time = nil

-- Function to format the timecode into a readable format (hh:mm:ss.ms)
local function format_time(seconds)
    local ms = math.floor((seconds - math.floor(seconds)) * 1000)
    local secs = math.floor(seconds)
    local mins = math.floor(secs / 60)
    secs = secs % 60
    local hours = math.floor(mins / 60)
    mins = mins % 60
    if hours > 0 then
        return string.format("%02d:%02d:%02d.%03d", hours, mins, secs, ms)
    else
        return string.format("%02d:%02d.%03d", mins, secs, ms)
    end
end

-- Function to create the clip using ffmpeg
local function create_clip(action)
    if start_time and end_time then
        if end_time <= start_time then
            mp.osd_message("End time must be greater than start time.", 2)
            return
        end

        local input_file = mp.get_property("path")
        local args = {}
        local output_file = input_file:gsub("%.%w+$", "") ..
            string.format(" - %s - %s", format_start_time, format_end_time)

        if action == "mp4" then
            local extension = ".mp4"
            args = {
                "ffmpeg",
                "-nostdin", "-y",
                "-loglevel", "error",
                "-i", input_file,
                "-ss", tostring(start_time),
                "-to", tostring(end_time),
                "-vf", "scale=-1:720",
                "-pix_fmt", "yuv420p",
                "-crf", "26",
                "-preset", "superfast",
                output_file .. extension
            }
        elseif action == "copy" then -- Sometimes it sucks.
            local extension = mp.get_property("filename"):match("^.+(%..+)$") or ".mp4"
            args = {
                "ffmpeg",
                "-nostdin", "-y",
                "-loglevel", "error",
                "-i", input_file,
                "-ss", tostring(start_time),
                "-to", tostring(end_time),
                "-c", "copy",
                "-map", "0",
                "-dn",
                "-avoid_negative_ts", "make_zero",
                output_file .. extension
            }
        else
            mp.osd_message("Unsupported action: " .. action, 2)
            return
        end

        mp.osd_message("Creating clip from " .. format_start_time .. " to " .. format_end_time, 2)

        mp.command_native_async({
            name = "subprocess",
            args = args,
            playback_only = false,                                        -- Проигрывание может быть приостановлено во время выполнения команды ffmpeg
        }, function() mp.osd_message("Clip created successfully", 2) end) -- Обратный вызов, который будет вызван после завершения команды ffmpeg
    else
        mp.osd_message("Start time or end time is not set.", 2)
    end
end

-- Function to handle key bindings
local function handle_key_binding(key)
    if key == "g" then
        start_time = mp.get_property_number("time-pos")
        format_start_time = format_time(start_time)
        mp.osd_message("Start time set to: " .. format_start_time, 2)
    elseif key == "G" then
        start_time = 0
        format_start_time = format_time(start_time)
        mp.osd_message("Start time set to the beginning of the video", 2)
    elseif key == "h" then
        end_time = mp.get_property_number("time-pos")
        format_end_time = format_time(end_time)
        mp.osd_message("End time set to: " .. format_end_time, 2)
    elseif key == "H" then
        end_time = mp.get_property_number("duration")
        format_end_time = format_time(end_time)
        mp.osd_message("End time set to the end of the video", 2)
    elseif key == "alt+r" then
        create_clip("copy")
    elseif key == "ctrl+r" then
        create_clip("mp4")
    end
end

-- Binding the keys
mp.add_forced_key_binding("g", "set_start_time", function() handle_key_binding("g") end)
mp.add_forced_key_binding("G", "set_start_time_beginning", function() handle_key_binding("G") end)
mp.add_forced_key_binding("h", "set_end_time", function() handle_key_binding("h") end)
mp.add_forced_key_binding("H", "set_end_time_end", function() handle_key_binding("H") end)
mp.add_forced_key_binding("ctrl+r", "create_mp4_clip", function() handle_key_binding("ctrl+r") end)
mp.add_forced_key_binding("alt+r", "create_clip", function() handle_key_binding("alt+r") end)
