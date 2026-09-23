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

При установке конфига будет происходить компиляция [sway-layout-sync](https://github.com/fosiodev/sway-layout-sync), [uniclip-rs](https://github.com/YuriNek0/uniclip-rs), [waybar](https://github.com/Alexays/Waybar) и [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). Это может занять какое-то время. На моём пк это 1-5 минут.

```sh
git clone https://github.com/fosiodev/nixos-dots
cd nixos-dots
```

- Сменить ник в `flake.nix` и выбрать `state`
- Выбрать GPU в `bundle.nix` и настроить сам конфиг для GPU
- Выбрать часовой пояс и локаль в `configuration.nix`
- Настроить монитор в `sway.nix`
- Если ставишь на виртуалку, то прочитай допы ниже
- Активировать скрипт в `./scripts/install.sh`. Если нет прав, то `chmod +x scripts/install.sh`
- После установки ребилдить систему можно алиасом `rbs`. Остальные алиасы в `zsh.nix`

Если ставишь конфиг на виртуалку:
- Включить `qemu-guest.nix` в `bundle.nix`
- Для синхронизации раскладок клавиатуры хоста и виртуалки, если обе системы являются этим конфигом и используют `capslock` для смены раскладки, надо использовать [sway-layout-sync](https://github.com/fosiodev/sway-layout-sync). На хосте (сервер) `sway-layout-sync -s`. На виртуалке (клиент) `sway-layout-sync`.
- Для общего буфера обмена виртуалки и хоста использую [uniclip-rs](https://github.com/YuriNek0/uniclip-rs). На хосте (сервер) `uniclip-rs -s 192.168.122.1:8888`. На виртуалке (клиент) `uniclip-rs -p 192.168.122.1:8888`. Общий буфер обмена через `spice-vdagent` работает криво и полностью ломает виртуалку на 4к мониторе со scale 2.0
- Для виртуалки выделяю 100гб+. Сама система весит 60гб. Если много, то удали кучу лишнего софта

После установки:
- В firefox based браузерах `about:config` поставить `browser.tabs.inTitlebar = 0` чтоб стили sway работали
- В chromium based браузерах `chrome://settings/appearance` включить `Use system title bar and borders` чтоб стили sway работали
- При желании включить/настроить закомментированные конфиги из `bundle.nix`
