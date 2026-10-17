# Загрузка C-модуля даты и времени (нужен для $EPOCHSECONDS в prompt и bgnotify)
zmodload zsh/datetime

# Интерактивное автодополнение со стрелочками и подсветкой
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Цвета для man-страниц (замена colored-man-pages из OMZ)
export LESS_TERMCAP_mb=$'\e[1;31m'      # Начало мигания (красный)
export LESS_TERMCAP_md=$'\e[1;36m'      # Заголовки и жирный текст (голубой/cyan)
export LESS_TERMCAP_me=$'\e[0m'         # Конец жирного/мигания
export LESS_TERMCAP_so=$'\e[01;44;33m'  # Выделение/поиск (желтый на синем фоне)
export LESS_TERMCAP_se=$'\e[0m'         # Конец выделения
export LESS_TERMCAP_us=$'\e[1;32m'      # Подчеркивание/аргументы команд (зеленый)
export LESS_TERMCAP_ue=$'\e[0m'         # Конец подчеркивания
export GROFF_NO_SGR=1                   # Заставляет groff использовать termcap вместо ломаных escape-кодов

# Переходить в папку просто написав её имя
setopt AUTO_CD

# Разрешить комментарии с '#' в интерактивном шелле
setopt INTERACTIVE_COMMENTS

# Чтоб не только `*.jpg` работал, но и доп фильтры
# `ls ^*.nix` - показать всё, кроме файлов `.nix` (знак ^ = отрицание)
# `rm **/*.bak` - рекурсивно найти и удалить во всех подпапках
# `ls *(m-1)` — показать только файлы, изменённые за последний день
setopt EXTENDED_GLOB
