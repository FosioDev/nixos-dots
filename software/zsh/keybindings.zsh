# Узнать bindkey можно нажатием Ctrl + V и после этого нажать бинд

# Режим Emacs (стандарт для bash/zsh, отменяет случайный vi-режим)
bindkey -e

# Прыжки через слово по Ctrl + Стрелкам
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Запасные коды для разных терминалов
bindkey '^[[5D'   backward-word
bindkey '^[[5C'   forward-word
bindkey '^[^[[D'  backward-word
bindkey '^[^[[C'  forward-word

# Клавиша Home (в начало строки)
bindkey '^[[H'  beginning-of-line # xterm / modern
bindkey '^[OH'  beginning-of-line # application mode
bindkey '^[[1~' beginning-of-line # vt / xterm fallback
bindkey '^[[7~' beginning-of-line # rxvt

# Клавиша End (в конец строки)
bindkey '^[[F'  end-of-line       # xterm / modern
bindkey '^[OF'  end-of-line       # application mode
bindkey '^[[4~' end-of-line       # vt / xterm fallback
bindkey '^[[8~' end-of-line       # rxvt

# Клавиша Delete
bindkey '^[[3~'   delete-char          # Delete

# Удаление целых слов
bindkey '^H'      backward-kill-word   # Ctrl + Backspace
bindkey '^?'      backward-delete-char # Обычный Backspace
bindkey '^[[3;5~' kill-word            # Ctrl + Delete
bindkey '^W'      backward-kill-word   # Ctrl + W
