# Custom NixOS Live ISO (Flakes Enabled, Stable DNS)

This repository provides a **custom NixOS Live ISO built with flakes enabled and stable DNS configuration**, intended to avoid issues encountered with the official NixOS installer ISO.

## Motivation

When installing NixOS using the official installer ISO, I ran into the following problems:

- **Unreliable name resolution (DNS)**
- As a result, errors occurred when fetching or building the **NVIDIA driver**

During installation, unstable networking can easily break driver downloads, especially for proprietary drivers like NVIDIA.

To address this, I created a custom Live ISO with:

- **Reliable DNS configuration**
- **NetworkManager + systemd-resolved enabled by default**

This ensures that name resolution works consistently during installation.

## Why flakes and nix-command are enabled

In the official NixOS installer ISO, the following features are disabled by default:

- nix-command
- flakes

This is inconvenient if your workflow is already flake-based, because:

- You cannot directly use nix build or nixos-install --flake
- Temporary configuration changes are required in the live environment

This ISO enables flakes out of the box:

```nix
nix.settings = {
  sandbox = true;
  extra-experimental-features = [
    "nix-command"
    "flakes"
  ];
};
```

With this setup, flake-based workflows work immediately after booting the live system.

## Included tools

This ISO is tailored to **my personal dotfiles and installation workflow**.  
To make the live environment usable without any extra setup, the following tools are **preinstalled**:

- **git**
- **pciutils** — hardware / GPU inspection
- **whois** — network diagnostics
- **sudo**
- **curl**, **wget**
- **vim**, **nano**

These tools allow you to clone repositories, inspect hardware, and perform basic diagnostics directly from the live system.

---

## Building the ISO

From the root of this repository, build the ISO using the following command:

```bash
nix build .#nixosConfigurations.custom-iso.config.system.build.isoImage
```

After the build finishes, the ISO will be available at:

```text
./result/iso/nixos-custom-flakes.iso
```

## Writing the ISO to a USB drive

⚠ **Be careful:** selecting the wrong device will destroy data.

Use the following command to write the ISO to a USB drive:

```bash
sudo dd if=./result/iso/nixos-custom-flakes.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace /dev/sdX with your actual USB device  
(for example: /dev/sdb).

Once completed, the USB drive should be bootable.

## Intended use cases

- Installing NixOS with a **flake-based configuration**
- Stable installation on systems with **NVIDIA GPUs**
- Testing or bootstrapping **personal dotfiles**
- Creating a **reliable live environment** for NixOS experimentation

## Notes

- This ISO is **not intended for general distribution**
- It is a **personal, opinionated setup** designed for a specific workflow

Feel free to modify the configuration to suit your own needs.
