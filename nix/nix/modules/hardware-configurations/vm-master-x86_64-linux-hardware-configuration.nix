{ config, lib, pkgs, modulesPath, ... }:
{
   imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "virtio_scsi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

   nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}