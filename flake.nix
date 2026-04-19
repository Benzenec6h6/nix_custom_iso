{
  description = "Custom NixOS Live ISO with flakes & latest kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, ... }: {
    nixosConfigurations.custom-iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
        disko.nixosModules.disko
        sops-nix.nixosModules.sops

        ({ pkgs, ... }: {
          # --- Nix 設定 ---
          nix = {
            package = pkgs.lixPackageSets.stable.lix;
            settings = {
              extra-experimental-features = [ "nix-command" "flakes" ];
              substituters = [ 
                "https://cache.lix.systems"
                "https://attic.xuyh0120.win/lantian"
                "https://cache.garnix.io"
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
                "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
                "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
              max-jobs = "auto";
              cores = 0;
              auto-optimise-store = true;
              #max-substitution-jobs = 8;
            };
          };

          # --- ハードウェア互換性 / カーネル ---
          boot.kernelPackages = pkgs.linuxPackages;
          boot.supportedFilesystems = [ "btrfs" "ext4" "vfat" "ntfs" "exfat" ];

          # --- ネットワーク設定 ---
          networking.networkmanager.enable = true;
          networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
          services.resolved.enable = true;

          # --- 便利サービス (SSH) ---
          services.openssh.enable = true;

          # --- システムパッケージ ---
          environment.systemPackages = with pkgs; [
            git curl wget pciutils usbutils
            sops age ssh-to-age sbctl
            whois gnused gawk
            vim nano
            links2
            disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
          ];

          # ISOファイル名の指定
          image.fileName = "nixos-custom-flakes.iso";
        })
      ];
    };
  };
}
