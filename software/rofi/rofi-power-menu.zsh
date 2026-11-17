#!/usr/bin/env zsh
set -euo pipefail

opts=(' Lock' '󰐥 Poweroff' '󰑓 Reboot' '󰤄 Suspend' '󰆓 Hibernate' '󰍃 Logout')
actions=(
    'loginctl lock-session' 'systemctl poweroff' 'systemctl reboot'
    'systemctl suspend' 'systemctl hibernate' 'swaymsg exit'
)

index=$(printf '%s\n' "${opts[@]}" | rofi -dmenu -p "Power Menu" -format i -theme ~/.config/rofi/power.rasi)
[[ -n "$index" ]] || exit 0

action=${actions[$((index + 1))]}
opt_name=${opts[$((index + 1))]}

# Отрезает иконку (Lock, Poweroff, Reboot...)
label="${opt_name#* }"

# Подтверждение для любого действия
ans=$(printf 'No\nYes' | rofi -dmenu -i -p "Confirm ${label}?" -theme ~/.config/rofi/power.rasi -selected-row 0 || true)
[[ "$ans" == "Yes" ]] || exit 0

exec ${=action}
