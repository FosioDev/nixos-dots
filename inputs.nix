# Тут будут пакеты, которые требуют внешнего бинарного кеша, иначе будет компиляция.
# Бинарный кеш добавляется в packages.nix.
# Если ставить систему с нуля, то NixOS сначала пытается билдить пакеты
# и лишь после этого читает бинарный кеш.
# То есть он начнёт компилировать эти пакеты вместо скачивания.
# Чтоб это исправить, надо сначала закомментировать импорт этого файла,
# сделать ребилд, чтоб активировать бинарны кеш из packages.nix
# и только после этого делать ребилд с импортом этого файла, чтоб скачать пакеты.

{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-lazer-bin
    inputs.affinity-nix.packages.${pkgs.system}.v3 # Бесплатная замена photoshop через wine
  ];
}
