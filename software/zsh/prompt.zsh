setopt PROMPT_SUBST
export VIRTUAL_ENV_DISABLE_PROMPT=1

if [[ "$TERM" == "linux" ]]; then
    _ICO_PROMPT=">"
    _ICO_GIT=""
    _ICO_PY="py:"
    _ICO_NIX="nix:"
else
    _ICO_PROMPT="❯"
    _ICO_GIT=" "
    _ICO_PY=" "
    _ICO_NIX=" "
fi

preexec() {
    _CMD_START=$EPOCHSECONDS
}

_prompt_git() {
    local branch
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(command git rev-parse --short HEAD 2>/dev/null) || return
    # Защита от знака % в имени ветки
    branch=${branch//\%/%%}

    echo " on %B%F{magenta}${_ICO_GIT}${branch}%f%b"
}

_prompt_python() {
    [[ -z "$VIRTUAL_ENV" ]] && return
    echo " via %B%F{yellow}${_ICO_PY}(${VIRTUAL_ENV:t})%f%b"
}

_prompt_nix() {
    [[ -z "$IN_NIX_SHELL" ]] && return
    echo " via %B%F{blue}${_ICO_NIX}${IN_NIX_SHELL} (${name:-nix-shell-env})%f%b"
}

_prompt_duration() {
    local elapsed=$(( EPOCHSECONDS - ${_CMD_START:-EPOCHSECONDS} ))
    unset _CMD_START
    (( elapsed < 2 )) && return

    local m=""
    (( elapsed >= 60 )) && m="$(( elapsed / 60 ))m"
    echo " took %B%F{yellow}${m}$(( elapsed % 60 ))s%f%b"
}

precmd() {
    PS1="
%B%F{cyan}%1~%f%b$(_prompt_git)$(_prompt_python)$(_prompt_nix)$(_prompt_duration)
%(?.%B%F{green}.%B%F{red})${_ICO_PROMPT}%f%b "
}
