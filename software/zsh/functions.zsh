#---------------------------------------------------------------------
#--- Universal Archive: ua <format> <files ...>
#--- Examples: ua zip ./  |  ua tar.gz folder/  |  ua 7z file1 file2
#---------------------------------------------------------------------
ua() {
    if (( $# < 2 )); then
        echo "Usage: ua <format> <files ...> (e.g. ua zip ./, ua tar.gz file1 folder2)" >&2
        return 1
    fi

    local format="$1"
    shift
    local -a targets=("$@")

    local ext cmd
    case "${format:l}" in
        zip)              ext=".zip";     cmd="zip" ;;
        7z)               ext=".7z";      cmd="7z" ;;
        tar)              ext=".tar";     cmd="tar" ;;
        tar.gz|tgz|gz)    ext=".tar.gz";  cmd="tar" ;;
        tar.bz2|tbz2|bz2) ext=".tar.bz2"; cmd="tar" ;;
        tar.xz|txz|xz)    ext=".tar.xz";  cmd="tar" ;;
        tar.zst|tzst|zst) ext=".tar.zst"; cmd="tar" ;;
        *)  echo "ua: unsupported archive format '$format'" >&2
            return 1 ;;
    esac

    case "$cmd" in
        zip) (( $+commands[zip] )) || { echo "ua: 'zip' is not installed" >&2; return 1; } ;;
        7z)  (( $+commands[7z] ))  || { echo "ua: '7z' is not installed" >&2; return 1; } ;;
        tar) (( $+commands[tar] )) || { echo "ua: 'tar' is not installed" >&2; return 1; } ;;
    esac

    local base_name
    if (( ${#targets} == 1 )); then
        local single="${targets[1]%/}" # отрезаем слэш на конце (./ -> .)
        if [[ -z "$single" || "$single" == "." ]]; then
            base_name="${PWD:t}"
        elif [[ -d "$single" ]]; then
            base_name="${single:t}"
        elif [[ -f "$single" ]]; then
            base_name="${single:t:r}"
        else
            base_name="${single:t}"
        fi
    else
        base_name="${PWD:t}"
    fi
    [[ -z "$base_name" ]] && base_name="archive"

    # Защита от перезаписи существующих архивов (file.zip -> file_1.zip)
    local archive="${base_name}${ext}"
    local count=1
    while [[ -e "$archive" ]]; do
        archive="${base_name}_${count}${ext}"
        (( count++ ))
    done

    echo "Archiving to '$archive'..."

    local exit_code=0
    case "$cmd" in
        tar) tar -caf "$archive" "${targets[@]}" || exit_code=$? ;;
        zip) zip -r -q "$archive" "${targets[@]}" || exit_code=$? ;;
        7z)  7z a "$archive" "${targets[@]}" > /dev/null || exit_code=$? ;;
    esac

    if (( exit_code == 0 )); then
        echo "Successfully created '$archive'"
    else
        echo "ua: failed to create '$archive' (error code: $exit_code)" >&2
        # Удаляем битый/недописанный файл архива
        [[ -f "$archive" ]] && rm -f "$archive"
        return $exit_code
    fi
}

# Tab-completion for supported formats
_ua() {
    local -a formats=(
        'zip:ZIP archive'
        'tar:Uncompressed TAR'
        'tar.gz:Gzip compressed TAR'
        'tar.bz2:Bzip2 compressed TAR'
        'tar.xz:XZ compressed TAR'
        'tar.zst:Zstandard compressed TAR'
        '7z:7-Zip archive'
    )
    _arguments \
        '1:format:(($formats))' \
        '*:file:_files'
}
(( $+functions[compdef] )) && compdef _ua ua


#---------------------------------------------------------------------
#--- Extract archives (safely into a dedicated directory)
#---------------------------------------------------------------------
alias x=extract
extract() {
    if (( $# == 0 )); then
        echo "Usage: extract <archive ...> (e.g. extract file1.rar file2.rar *.zip)" >&2
        return 1
    fi

    local global_exit=0

    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "extract: '$file' is not a valid file" >&2
            global_exit=1
            continue
        fi

        case "${file:l}" in
            *.tar|*.tar.*|*.tgz|*.tbz|*.tbz2|*.txz|*.tzst) local cmd="tar" ;;
            *.zip)                                         local cmd="zip" ;;
            *.7z)                                          local cmd="7z" ;;
            *.rar)                                         local cmd="rar" ;;
            *.gz)                                          local cmd="gz" ;;
            *.bz2)                                         local cmd="bz2" ;;
            *.xz)                                          local cmd="xz" ;;
            *.zst)                                         local cmd="zst" ;;
            *)  echo "extract: unsupported archive format for '$file'" >&2
                global_exit=1
                continue ;;
        esac

        local full_path="${file:A}"

        local base_dir="${file:t:r}"
        [[ "$base_dir" == *.tar ]] && base_dir="${base_dir:r}"

        # Collision protection: append _1, _2 ... if directory already exists
        local dir="$base_dir"
        local count=1
        while [[ -e "$dir" ]]; do
            dir="${base_dir}_${count}"
            (( count++ ))
        done

        mkdir -p "$dir" || { global_exit=1; continue; }
        echo "Extracting '$file' -> '$dir/'..."

        local exit_code=0
        case "$cmd" in
            tar) tar -xf "$full_path" -C "$dir" || exit_code=$? ;;
            zip) unzip -q "$full_path" -d "$dir" || exit_code=$? ;;
            7z)  7z x -y "$full_path" -o"$dir" > /dev/null || exit_code=$? ;;
            rar) unrar x -inul "$full_path" "$dir/" || exit_code=$? ;;
            gz)  gzip -dc "$full_path" > "$dir/${file:t:r}" || exit_code=$? ;;
            bz2) bzip2 -dc "$full_path" > "$dir/${file:t:r}" || exit_code=$? ;;
            xz)  xz -dc "$full_path" > "$dir/${file:t:r}" || exit_code=$? ;;
            zst) zstd -dc -q "$full_path" > "$dir/${file:t:r}" || exit_code=$? ;;
        esac

        # no 'rm -rf $dir'
        if (( exit_code != 0 )); then
            echo "extract: failed to extract '$file' (error code: $exit_code). Output directory: '$dir/'" >&2
            global_exit=1
        fi
    done

    return $global_exit
}


#---------------------------------------------------------------------
#--- bgnotify
#--- background notifications for long running commands
#--- make sure you have `notify-send` and `jq`
#---------------------------------------------------------------------
__notify_preexec() {
    __notify_cmd_start=$EPOCHSECONDS
    __notify_cmd_name="$1"
    __notify_sway_id=$(swaymsg -t get_tree | jq '.. | select(.focused? == true) | .id' 2>/dev/null)
}

__notify_precmd() {
    local exit_code=$?
    [[ -z "$__notify_cmd_start" ]] && return

    local elapsed=$(( EPOCHSECONDS - __notify_cmd_start ))
    local start_id="$__notify_sway_id"
    local cmd_name="$__notify_cmd_name"
    unset __notify_cmd_start __notify_sway_id __notify_cmd_name

    (( elapsed < 5 )) && return

    local current_focused_id=$(swaymsg -t get_tree | jq '.. | select(.focused? == true) | .id' 2>/dev/null)
    [[ -n "$start_id" && "$start_id" == "$current_focused_id" ]] && return

    local s=$(( elapsed % 60 ))
    local m=$(( (elapsed / 60) % 60 ))
    local h=$(( (elapsed / 3600) % 24 ))
    local d=$(( elapsed / 86400 ))

    local t="${s}s"
    (( m > 0 || h > 0 || d > 0 )) && t="${m}m ${t}"
    (( h > 0 || d > 0 ))          && t="${h}h ${t}"
    (( d > 0 ))                   && t="${d}d ${t}"

    if [[ $exit_code -eq 0 ]]; then
        notify-send -u normal "win ($t)" "$cmd_name"
    else
        notify-send -u critical "fail ($exit_code) ($t)" "$cmd_name"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec __notify_preexec
add-zsh-hook precmd __notify_precmd
