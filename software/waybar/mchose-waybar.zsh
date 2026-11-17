#!/usr/bin/env zsh

setopt errexit nounset pipefail extended_glob

cache="${XDG_RUNTIME_DIR:-/tmp}/mchose-bat.cache"
typeset -A data
bat=""
charge_icon=""

if info_out=$(mchose info 2>&1); then
  show_out=$(mchose show 2>/dev/null) || show_out=""

  for line in ${(f)info_out} ${(f)show_out}; do
    if [[ $line == (#b)[[:space:]]#\*[[:space:]]##[0-9]##[[:space:]]##(*) ]] {
      data[dpi]=${match[1]%%[[:space:]]##}
    } elif [[ $line == (#b)(link|battery|rate|debounce|sleep|lod)[[:space:]]##(*) ]] {
      data[$match[1]]=${match[2]%%[[:space:]]##}
    }
  done

  bat=${${data[battery]:-}//[^0-9]/}
  [[ ${data[battery]:-} == *charging* ]] && charge_icon=" "

  if [[ -n $bat ]] {
    lod=${${data[lod]:-?}%% \(*}
    tooltip="DPI: ${data[dpi]:-?}\nRate: ${data[rate]:-?}\nDebounce: ${data[debounce]:-?}\nSleep: ${data[sleep]:-?}\nLOD: $lod\nLink: ${data[link]:-?}"
    printf '%s\n%s\n' "$bat" "$tooltip" >| "$cache"
  }
elif [[ $info_out != *'empty identity'* ]]; then
  cache=""
fi

if [[ -z $bat && -r $cache && -s $cache ]] {
  cached=(${(f)"$(<"$cache")"})
  bat=${cached[1]:-}
  tooltip=${cached[2]:-Mouse idle (cached)}
}

if [[ -z $bat ]] { print -r -- '{"text": ""}'; exit 0 }

cls="connected"
(( bat <= 30 ))       && cls="warning"
(( bat <= 15 ))       && cls="critical"
[[ -n $charge_icon ]] && cls="charging"

printf '{"text": "󰍽 %d%%%s", "tooltip": "%s", "class": "%s"}\n' \
  "$bat" "$charge_icon" "$tooltip" "$cls"

