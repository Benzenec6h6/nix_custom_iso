{
  description = "Custom NixOS Live ISO with flakes & sandbox disabled";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.custom-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
        disko.nixosModules.disko

        ({ pkgs, ... }: {

          # --- Nix 設定 ---
          nix.settings = {
            sandbox = true;
            #sandbox-fallback = true;
            extra-experimental-features = [
              "nix-command"
              "flakes"
            ];
          };

          # --- DNS ---
          services.resolved.enable = true;

          environment.etc."resolv.conf".source =
            "/run/systemd/resolve/stub-resolv.conf";

          networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

          # NetworkManager を使う（DHCP を含む）
          networking.networkmanager.enable = true;

          # --- live 環境のツール ---
          environment.systemPackages = with pkgs; [
            git
            pciutils
            whois
            sudo
            curl
            wget
            vim
            nano
            disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
          ];

          image.fileName = "nixos-custom-flakes.iso";
        })
      ];
    };
  };
}
