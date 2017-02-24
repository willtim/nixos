# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # settings common to all my machines
      ./common.nix

      # i3 desktop config
      ./desktop.nix
    ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "vfat";
    };
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f6df83a2-6b97-46bb-86c9-6e625e55c9f5";
      fsType = "xfs";
    };
  fileSystems."/vboxshare" = {
    fsType = "vboxsf";
    device = "vboxshare";
    options = ["rw"];
  };

  swapDevices = [ ];

  boot.loader.timeout = 5;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efibootmgr = {
      efidisk = "/dev/sda1";
      efipartition = 1;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  # Network
  networking = {
    hostName = "virtual";   # Define your hostname.
    enableIPv6 = false; # To make wifi work?
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    connman.enable = true;
  };

  powerManagement.enable = true;

  hardware.pulseaudio.enable = true;

  # cannot enable with virtual box guest additions
  # security.grsecurity.enable = true;

  security.sudo.enable = true;

  services = {
    acpid.enable = true;
    # thermald.enable = true;
    tlp.enable = true;
    locate.enable = true;
    fprintd.enable = true; # finger-print daemon and PAM module

    # check this
    openssh = {
      enable = true;
      # passwordAuthentication = false;
    };

    # enable nixos manual on virtual console 8
    nixosManual.showManual = true;

    # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # udev.packages = with pkgs; [ ];

    # virtualboxHost.enable = true;
    # virtualboxHost.enableHardening = true;
  };

  # custom services
  # systemd.services.my-backup = {
  #   enable = True;
  #   description = "My Backup";
  #   startAt = "*-*-* 01:15:00";  # see systemd.time(7)
  #   path = with pkgs; [ bash rsync openssh utillinux gawk nettools time ];
  #   serviceConfig.ExecStart = /home/bfo/bin/backup.sh;
  # };

  # systemd.services.low-battery-check = {
  #   enable = true;
  #   description = "LowBatteryCheck";
  #   path = with pkgs; [ bash pmutils ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "/home/tim/bin/low-battery-check";
  #   };
  # };

  # systemd.timers.low-battery-check = {
  #   unitConfig = {
  #     Description = "Run low-battery-check every minute";
  #   };
  #   timerConfig = {
  #     OnBootSec="2min";
  #     OnUnitActiveSec="1min";
  #     Unit="low-battery-check.service";
  #   };
  #   wantedBy = ["multi-user.target"];
  # };

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.guest.enable = true;
  services.xserver.videoDrivers = [ "virtualbox" "cirrus" "vesa" "modesetting" ];
}
