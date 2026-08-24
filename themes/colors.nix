{ lib, ... }: {
  # Создаю свой кастомный параметр my.colors
  # Вызывать потом через config.my.colors
  # Создано на случай, если я захочу отказаться от stylix
  # Чтоб не пришлось переписывать другие конфиги на новые цвета
  options.my.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Цветовая схема (base16)";
  };
}
