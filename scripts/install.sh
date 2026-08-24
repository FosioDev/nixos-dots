#!/usr/bin/env bash

mkdir -p "$HOME/.config/xfce4/"
mkdir -p "$HOME/Pictures/Screenshots"
cp "$HOME/nixos-dots/scripts/helpers.rc" "$HOME/.config/xfce4/helpers.rc"
cp "$HOME/nixos-dots/scripts/mimeapps.list" "$HOME/.config/mimeapps.list"
ln -s ~/nixos-dots/software/nvim ~/.config/nvim
sudo nixos-rebuild boot --impure --flake ~/nixos-dots
