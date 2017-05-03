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
  system.stateVersion = "17.03";

  boot.kernelModules       = [ "kvm-intel" ]; # second-stage boot
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "pcspkr" "acer_wmi" ];

  boot.initrd.kernelModules = [
   # Specify all kernel modules that are necessary for mounting the root
   # file system.
   "vfat" "i915" "nvme" "xfs" "dm_mod" "sd_mod" "xhci_pci" "usb_storage" "rtsx_pci_sdmmc" "nls_cp437" "nls_iso8859-1" "aesni_intel" "thinkpad_acpi"
  ];

  # only use intel_pstate on systems which support hardware p-state control (HWP)
  boot.kernelParams = [
    "intel_pstate=hwp_only"
  ];

  boot.loader.timeout = 5;
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  boot.initrd.luks.devices = [{
        name = "enc-pv";
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
    }];


  # File systems
  # explicitly configure fileSystems here, not in hardware-configuration.nix
  fileSystems."/boot" = {
    label = "uefi";
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };
  fileSystems."/" = {
    label   = "root";
    device  = "/dev/mapper/vg-root";
    fsType  = "xfs";
    options = ["discard" "noatime" "nodiratime"];
  };
  swapDevices = [ { device = "/dev/mapper/vg-swap"; } ];

  # Network
  networking = {
    hostName = "x1c";   # Define your hostname.
    enableIPv6 = false; # To make wifi work?
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    wireless.enable = true;
    connman.enable = true;
  };

  powerManagement.enable = true;

  # needed for intel wifi
  hardware.enableAllFirmware = true;

  hardware.pulseaudio.enable = true;

  # cannot enable with virtual box guest additions
  # security.grsecurity.enable = true;

  security.sudo.enable = true;

  services = {
    acpid.enable = true;
    thermald.enable = true;

    tlp.enable = true;
    tlp.extraConfig = ''
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth wwan"
      DEVICES_TO_ENABLE_ON_STARTUP="wifi"
      DISK_DEVICES="nvme0n1"
    '';

    locate.enable = true;
    # fprintd.enable = true; # finger-print daemon and PAM module

    # check this
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    # enable nixos manual on virtual console 8
    nixosManual.showManual = true;

    # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # udev.packages = with pkgs; [ ];

    # Get my volume buttons working
    # libinput does not seem to work.
    udev.extraHwdb = ''
      evdev:input:b0003v17aap5054*
        KEYBOARD_KEY_a0=mute
        KEYBOARD_KEY_ae=volumedown
        KEYBOARD_KEY_b0=volumeup
    '';

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

}
