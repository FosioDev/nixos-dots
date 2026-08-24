{
  description = "Main flake file";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs2.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgsld.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Лок конкретного софта
    strawberry.url = "github:nixos/nixpkgs/nixos-26.05";

    # Внешние flake inputs
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:mrshmllow/affinity-nix";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    username = "fosio";
    state = "26.05"; # Брать значение из родного state и не менять его
    is4k = true; # Поставь false, если не 4к монитор (WIP)
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    pkgs  = import nixpkgs { inherit system config; };
    pkgs2 = import inputs.nixpkgs2 { inherit system config; };
    spkgs = import inputs.nixpkgs-stable { inherit system config; };
    pkgsld = import inputs.nixpkgsld { inherit system config; };
    strawberry = import inputs.strawberry { inherit system config; };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      specialArgs = {
        inherit username state is4k spkgs pkgs2 pkgsld strawberry inputs;
      };
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit username state is4k spkgs pkgs2 pkgsld strawberry inputs;
          };
        }
        inputs.stylix.nixosModules.stylix
      ];
    };
  };
}
