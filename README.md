Другие README:
- [notes](./NOTES.md)
- [mpv](./software/mpv/README.md)

# Установка

## NixOS

Качаю NixOS GUI и ставлю minimal через визуальный установщик. Потом так:
```sh
sudo nano /etc/nixos/configuration.nix
```
```diff
{
+  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
+    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
+    wget
+    git
+    curl
  ];
}
```
```sh
sudo nixos-rebuild switch
```
Ребут системы и можно ставить конфиг


## Конфиг

```sh
git clone https://github.com/fosiodev/nixos-dots
cd nixos-dots
```

- Сменить ник в `flake.nix` и выбрать `state`
- Выбрать GPU в `bundle.nix` и настроить сам конфиг для GPU
- Включить настройки для виртуалок в `virtualisation.nix`, если ставишь на виртуалку
- Выбрать часовой пояс и локаль в `configuration.nix`
- Настроить монитор в `sway.nix`
- Активировать скрипт в `./scripts/install.sh`. Если нет прав, то `chmod +x scripts/install.sh`
- После установки ребилдить систему можно алиасом `rbs`. Остальные алиасы в `zsh.nix`

После установки:
- В firefox based браузерах `about:config` поставить `browser.tabs.inTitlebar = 0` чтоб стили sway работали
- В chromium based браузерах `chrome://settings/appearance` включить `Use system title bar and borders` чтоб стили sway работали
- При желании включить/настроить закомментированные конфиги из `bundle.nix`

## Изменения для виртуалок

Виртуалка под мои задачи требует 150гб памяти. Если хочешь меньше, то удали огромную кучу лишнего софта из конфигов.

В файле `virtualisation.nix` включи настройки в конце файла (если хост на X11 и скейл отличается от 1.0, то могут быть баги с координатами курсора, тогда лучше выключить эти настройки)
