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
          nix.settings = {
            extra-experimental-features = [ "nix-command" "flakes" ];
            download-buffer-size = 536870912;
            max-substitution-jobs = 8;
          };

          # --- ハードウェア互換性 / カーネル ---
          boot.kernelPackages = pkgs.linuxPackages_latest;
          boot.supportedFilesystems = [ "zfs" "btrfs" "ext4" "vfat" "ntfs" "exfat" ];

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
            disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
          ];

          # ISOファイル名の指定
          isoImage.isoName = "nixos-custom-flakes.iso";
          # image.fileName は古い形式のことがあるため、isoImage.isoName を推奨
        })
      ];
    };
  };
}
