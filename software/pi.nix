{ pkgs, ... }: {
  environment.systemPackages = with pkgs; let
    # Библиотеки рантайма
    runtimeLibs = lib.makeLibraryPath [
      openssl
      stdenv.cc.cc.lib
    ];

    # npm для pi
    pi-npm = writeShellApplication {
      name = "pi-npm";
      runtimeInputs = [ nodejs ];
      text = ''
        exec npm "$@"
      '';
    };

    # Сам pi изменён, чтоб nix-ld не руинил его работу
    pi-fixed = symlinkJoin {
      name = "pi-fixed";
      paths = [ pi-coding-agent ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --unset NIX_LD \
          --unset NIX_LD_LIBRARY_PATH \
          --set LD_LIBRARY_PATH "${runtimeLibs}" \
          --prefix PATH : "${pi-npm}/bin" \
          --set PI_OFFLINE 1
      '';
    };

    # Инструмент для работы с контекстом кода CodeMapper
    # https://github.com/elpapi42/codemapper-fork
    codemapper = rustPlatform.buildRustPackage {
      pname = "codemapper";
      version = "unstable-2026";
      src = fetchFromGitHub {
        owner = "elpapi42";
        repo = "codemapper-fork";
        rev = "7b167a67f89a9e28102708d430b9406e5f385f89";
        hash = "sha256-rNnrJOxgC51vi1CQ+z2hrnklBn7q4mVISq3oZ1/ebYk=";
      };
      # Отключаем тесты, так как тест 'test_is_git_repo' требует папки .git,
      # которая отсутствует в изолированной среде сборки Nix.
      doCheck = false;
      cargoHash = "sha256-SZHWaXYUxF68yQVb7oJV7PLrnqaTyG6ZtJE5WR74Gys=";
    };
  in [
    pi-fixed
    pi-npm
    codemapper
  ];
}
