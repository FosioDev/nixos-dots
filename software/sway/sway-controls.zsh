#!/usr/bin/env zsh

set -euo pipefail

control="$1"
value="$2"

get_audio_info() {
    local dev="@DEFAULT_AUDIO_SINK@"
    [[ $1 == 'mic' ]] && dev="@DEFAULT_AUDIO_SOURCE@"

    local raw=$(wpctl get-volume $dev)
    local parts=($=raw)

    integer -g vol=$(( parts[2] * 100 ))
    is_muted=1
    [[ $raw == *'[MUTED]'* ]] && is_muted=2

    return 0
}

# notify <tag> <title> [progress] [body]
notify() {
    notify-send -t 2000 -h "string:x-canonical-private-synchronous:$1" \
                ${3:+-h} ${3:+int:value:$3} \
                "$2" ${4:+"$4"}
}

case $control in
    volume)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$value"
        get_audio_info sink
        notify volume "  Volume $vol%" $vol
        ;;

    brightness)
        brightnessctl set "$value"
        val=${${(s:,:)$(brightnessctl -m)}[4]%\%}
        notify brightness "  Brightness $val%" $val
        ;;

    mute)
        dev="@DEFAULT_AUDIO_SINK@"
        icons=('  Unmuted' '  Muted')

        if [[ $value == 'mic' ]]; then
            dev="@DEFAULT_AUDIO_SOURCE@"
            icons=('  Mic Unmuted' '  Mic Muted')
        fi

        wpctl set-mute $dev toggle
        get_audio_info $value

        notify $value "${icons[is_muted]} ($vol%)" $vol
        ;;

    media)
        playerctl "$value" 2>/dev/null || {
            notify media "  No player active"
            exit 0
        }
        sleep 0.05

        case $value in
            play-pause) [[ $(playerctl status 2>/dev/null) == 'Playing' ]] && title='  Playing' || title='  Paused' ;;
            next)       title='  Next Track' ;;
            previous)   title='  Previous Track' ;;
            stop)       title='  Stopped' ;;
        esac

        body=$(playerctl metadata --format $'{{title}}\n{{artist}}' 2>/dev/null || true)
        notify media "$title" "" "$body"
        ;;
esac
