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
  system.stateVersion = "17.09";

  boot.kernelModules       = [ "kvm-intel" ]; # second-stage boot
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "pcspkr" "acer_wmi" ];
  # boot.kernelPackages = pkgs.linuxPackages_4_14;

  boot.initrd.kernelModules = [
   # Specify all kernel modules that are necessary for mounting the root
   # file system.
   "vfat" "i915" "nvme" "xfs" "dm_mod" "sd_mod" "xhci_pci" "usb_storage" "rtsx_pci_sdmmc" "nls_cp437" "nls_iso8859-1" "aesni_intel" "thinkpad_acpi" "exfat"
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

  virtualisation.libvirtd.enable = true;

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

  # latest fixes for buggy skylake
  hardware.cpu.intel.updateMicrocode = true;

  # needed for intel wifi
  hardware.enableAllFirmware = true;

  hardware.pulseaudio.enable = true;

  # for Steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

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
      passwordAuthentication = true;
    };

    # enable nixos manual on virtual console 8
    nixosManual.showManual = true;

    # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    syncthing = {
      enable = true;
      user = "tim";
      dataDir = "/home/tim/.config/syncthing";
      openDefaultPorts = true;
    };

    # manage, install and generate color profiles
    # USE argyllCMS dispwin instead
    # colord.enable = true;

    # udev.packages = with pkgs; [ ];

    # Perform keyboard mappings specific to the X1C laptop keyboard.
    # My Kinesis handles its own mappings.
    udev.extraHwdb = ''
      evdev:atkbd:dmi:*
        KEYBOARD_KEY_a0=mute
        KEYBOARD_KEY_ae=volumedown
        KEYBOARD_KEY_b0=volumeup
        KEYBOARD_KEY_3a=tab
        KEYBOARD_KEY_1d=leftalt
        KEYBOARD_KEY_38=leftctrl
        KEYBOARD_KEY_9d=leftalt
        KEYBOARD_KEY_b8=rightctrl
    '';

    # Maximum trackpoint sensitivity and speed
    # Monitor hot-plugging from KVM switching
    udev.extraRules = ''

    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="/home/tim/bin/toggle-display"

    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl" OWNER="tim"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl" OWNER="tim"

    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2c97"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2581"

    KERNEL=="serio2", SUBSYSTEM=="serio", DRIVERS=="psmouse", ATTR{sensitivity}:="255", ATTR{speed}:="255"
    '';
  };

  # psmouse driver attributes are not available at the right time during boot
  # NOTE: systemd path unit, watching on the attributes, didn't work, never triggers
  # systemd.paths.my-trackpoint = {
  #   enable = true;
  #   description = "Watch for, and modify, Trackpoint attributes";
  #   pathConfig = {
  #     PathExistsGlob = "/sys/devices/platform/i8042/serio1/serio2/{speed,sensitivity}";
  #     Unit = "my-trackpoint.service";
  #   };
  #   wantedBy = [ "default.target" ];
  # };

  systemd.services.my-trackpoint = {
    enable = true;
    description = "Ensure trackpoint settings are set";
    requires = ["display-manager.service"];
    after=["suspend.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/home/tim/bin/setup-trackpoint"; # waits for attributes to be present
    };
    wantedBy = ["multi-user.target" "suspend.target"];
  };

  # systemd.services.my-backup = {
  #   enable = True;
  #   description = "My Backup";
  #   startAt = "*-*-* 01:15:00";  # see systemd.time(7)
  #   path = with pkgs; [ bash rsync openssh utillinux gawk nettools time ];
  #   serviceConfig.ExecStart = /home/bfo/bin/backup.sh;
  # };

  systemd.services.low-battery-check = {
    enable = true;
    description = "LowBatteryCheck";
    path = with pkgs; [ bash pmutils ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/home/tim/bin/low-battery-check";
    };
  };

  systemd.timers.low-battery-check = {
    unitConfig = {
      Description = "Run low-battery-check every minute";
    };
    timerConfig = {
      OnBootSec="2min";
      OnUnitActiveSec="1min";
      Unit="low-battery-check.service";
    };
    wantedBy = ["multi-user.target"];
  };

}
