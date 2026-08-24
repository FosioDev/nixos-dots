# https://nixos.wiki/wiki/AMD_GPU
# Тут настройки для моей rx6600
# На другом поколении GPU может не работать
{ pkgs, ... }: {
  boot.initrd.kernelModules = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware = {
    amdgpu = {
      opencl.enable = true;
      # Норм разрешение экрана с первых секунд, для 4к моника мб норм тема
      # Если вдруг пиздец, то офнешь
      # Добавляет примерно 20-40мб в /boot
      # initrd.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva # VAAPI (Video Acceleration API)
        rocmPackages.clr.icd # OpenCL
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    rocmPackages.rocm-smi
    rocmPackages.rocblas
    rocmPackages.hipblas
    rocmPackages.clr
    clinfo # verify that OpenCL is correctly setup
  ];
}
