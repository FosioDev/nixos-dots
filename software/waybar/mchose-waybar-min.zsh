#!/usr/bin/env zsh

setopt errexit nounset pipefail extended_glob

cache="${XDG_RUNTIME_DIR:-/tmp}/mchose-bat.cache"
charge_icon=""

bat=""
if info_out=$(mchose info 2>&1); then
  if [[ $info_out == (#b)*battery[[:space:]]##([0-9]##)* ]] {
    bat=$match[1]
    print -r -- "$bat" >| "$cache"
  }
  [[ $info_out == *charging* ]] && charge_icon=" "
elif [[ $info_out != *'empty identity'* ]]; then
  cache=""
fi

[[ -z $bat && -r $cache && -s $cache ]] && bat=$(<"$cache")
if [[ -z $bat ]] { print -r -- '{"text": ""}'; exit 0 }

cls="connected"
(( bat <= 30 ))       && cls="warning"
(( bat <= 15 ))       && cls="critical"
[[ -n $charge_icon ]] && cls="charging"

printf '{"text": "󰍽 %d%%%s", "class": "%s"}\n' "$bat" "$charge_icon" "$cls"

