#!/usr/bin/env bash

# Сюда сохраняются скрины
mkdir -p "$HOME/Pictures/Screenshots"

# Для нормальной работы thunar
mkdir -p "$HOME/.config/xfce4/"
cp "$HOME/nixos-dots/scripts/helpers.rc" "$HOME/.config/xfce4/helpers.rc"
cp "$HOME/nixos-dots/scripts/nvim.desktop" "$HOME/.local/share/applications/nvim.desktop"

# Приложения по умолчанию
cp "$HOME/nixos-dots/scripts/mimeapps.list" "$HOME/.config/mimeapps.list"

# Настройки neovim
ln -s ~/nixos-dots/software/nvim ~/.config/nvim

# Ребилд системы
sudo nixos-rebuild boot --impure --flake ~/nixos-dots
