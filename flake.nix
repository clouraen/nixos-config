{
  description = "Cyberpunk-styled NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    maple-mono = {
      url = "github:subframe7536/maple-font/variable";
      flake = false;
    };

    superfile.url = "github:yorukot/superfile";
    vicinae.url = "github:vicinaehq/vicinae";
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
  };

  outputs =
    { nixpkgs, self, ... }@inputs:
    let
      username = "developer";
      lib = nixpkgs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      mkPackages = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          customPackages = import ./pkgs {
            inherit inputs pkgs system;
          };
        in
        customPackages // {
          default = customPackages.codex;
        };

      hosts = [
        {
          name = "desktop";
          system = "x86_64-linux";
          modulePath = ./hosts/desktop;
        }
        {
          name = "laptop";
          system = "x86_64-linux";
          modulePath = ./hosts/laptop;
        }
        {
          name = "vm";
          system = "x86_64-linux";
          modulePath = ./hosts/vm;
        }
        {
          name = "desktop-apple";
          system = "aarch64-linux";
          modulePath = ./hosts/desktop-apple;
        }
        {
          name = "laptop-apple";
          system = "aarch64-linux";
          modulePath = ./hosts/laptop-apple;
        }
        {
          name = "vm-apple";
          system = "aarch64-linux";
          modulePath = ./hosts/vm-apple;
        }
      ];

      mkHost = { name, system, modulePath }:
        lib.nameValuePair name (nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ modulePath ];
          specialArgs = {
            host = name;
            inherit self inputs username;
          };
        });
    in
    {
      packages = lib.genAttrs supportedSystems mkPackages;

      nixosConfigurations = lib.listToAttrs (map mkHost hosts);
    };
}
