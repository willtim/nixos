{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_4;

  # boot.kernelPackages = pkgs.linuxPackages_custom {
  #   version = "3.18.1-custom";
  #   src = pkgs.fetchurl {
  #     url = "mirror://kernel/linux/kernel/v3.x/linux-3.18.1.tar.xz";
  #     sha256 = "13m0s2m0zg304w86yvcmxgbjl41c4kc420044avi8rnr1xwcscsq";
  #   };
  #   configfile = /etc/nixos/customKernel.config; # cat /proc/config.gz | gunzip
  # };

  boot.kernelModules       = [ "kvm-intel" ]; # second-stage boot
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "pcspkr" ];

  boot.initrd.kernelModules = [
   # Specify all kernel modules that are necessary for mounting the root
   # file system.
   "fbcon" "vfat" "i915" "nvme" "btrfs" "nls_cp437" "nls_iso8859-1"
  ];

  # only use intel_pstate on systems which support hardware p-state control (HWP)
  boot.kernelParams = [
    # "intel_pstate=hwp_only" <-- cannot enable yet due to bugs
    "intel_pstate=no_hwp"
  ];

  boot.loader.gummiboot = {
    enable = true;
    timeout = 5;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efibootmgr = {
      efidisk = "/dev/??";
      efipartition = 1;
    };
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    # consoleFont = "sun12x22";
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";

  # File systems
  # explicitly configure fileSystems here, not in hardware-configuration.nix
  fileSystems."/boot" = {
    label = "efi";
    device = "/dev/??1";
    fsType = "vfat";
  };
  # note: currently with btrfs, most mount options (e.g. nodatacow, compress)
  # apply to the whole filesystem; and cannot be set per sub-volume.
  fileSystems."/" = {
    label   = "root";
    device  = "/dev/??3";
    fsType  = "btrfs";
    options = "subvol=root,ssd,discard,noatime,nodiratime,space_cache";
  };
  fileSystems."/home" = {
    label   = "home";
    device  = "/dev/??3";
    fsType  = "btrfs";
    options = "subvol=home,ssd,discard,noatime,nodiratime,space_cache";
  };
  swapDevices = [ { device = "/dev/??2"; } ];

  # Network
  networking = {
    hostName = "x1c";   # Define your hostname.
    enableIPv6 = false; # To make wifi work?
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
    connman.enable = true;
  };

  # install zsh into your system and provide a /etc/zshenv which is sourced every zsh invocation
  programs.zsh.enable = true;

  powerManagement.enable = true;

  hardware.pulseaudio.enable = true;

  security.sudo.enable = true;

  services = {
    acpid.enable = true;
    thermald.enable = true;
    tlp.enable = true;
    locate.enable = true;
    fprintd.enable = true; # finger-print daemon and PAM module

    # check this
    openssh = {
      enable = true;
      passwordAuthentication = false;
      extraConfig = ''
        AllowUsers bfo
        # Allow password authentication (only) from local network
        Match Address 192.168.0.0/24
          PasswordAuthentication yes
          # End the match group so that any remaining options (up to the end
          # of file) applies globally
          Match All
    '';
    };

    # enable nixos manual on virtual console 8
    # nixosManual.showManual = true;

    # CUPS printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # udev.packages = with pkgs; [ ];

    accounts-daemon.enable = true; # needed by lightdm

    xserver = {
      enable = true;
      # Important: default Intel UXA with multi-monitor crashes,
      # whereas SNA works great
      deviceSection = ''
        # Identifier "Intel Graphics"
        Driver "intel"
        Option "AccelMethod"  "sna"
        Option "TearFree"    "true"
      '';

      vaapiDrivers = [ pkgs.vaapiIntel ];
      autorun = true;
      exportConfiguration = true;
      layout = "gb";

      wacom.enable = true;  # for my bamboo stylus

      # multitouch.enable = true; # is this needed?

      # synaptics = {
      #   enable = true;
      #   twoFingerScroll = true;
      #   buttonsMap = [ 1 3 2];
      #   fingersMap = [ 0 0 0 ];
      #   tapButtons = true;
      #   vertEdgeScroll = false;
      #   maxSpeed = "5.0";  # what number here?
      #   accelFactor = "0"; # no acceleration?
      # }

      xkbOptions = "eurosign:e";
      windowManager.i3.enable = true;
      windowManager.default = "i3";
      displayManager.desktopManagerHandlesLidAndPower=false;
      displayManager.lightdm = {
        enable = true;
      };
    };

    # virtualboxHost.enable = true;
    # virtualboxHost.enableHardening = true;
  };

  # Nikpgs overrides
  nixpkgs.config = {
    allowUnfree = true;
    chromium.enablePepperFlash = true;
    chromium.enableGoogleTalkPlugin = true;
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  environment.shellAliases = {
    "ll"  = "ls -alF";
    "la"  = "ls -A";
    "l"   = "ls -CF";
    ".."  = "cd ..";
    "..." = "cd ../..";
    "..2" = "cd ../..";
    "..3" = "cd ../../..";
    "..4" = "cd ../../../..";
  };

  # system-wide packages
  environment.systemPackages = with pkgs; [
     aspell
     aspellDicts.en
     bc
     btrfsProgs
     bzip2
     cdparanoia
     colordiff
     coreutils
     cpio
     cpufrequtils
     cryptsetup
     curl
     dvdplusrwtools  # contains growisofs for Blu-ray burning
     dos2unix
     diffstat
     diffutils
     e2fsprogs
     file
     flac            # lossless audio encoder

     libcdio         # abcde dependencies
     cddiscid
     eject
     mkcue

     findutils
     gawk
     gdb
     ghostscript
     gitAndTools.gitFull
     gitAndTools.gitAnnex
     gnupg
     gzip
     hdparm
     htop            # multicore cpu monitoring
     iotop           # i/o monitoring
     iftop           # network monitoring
     iptables

     # LaTex/XeTex is in configuration.nix as it is expensive to build/rebuild and has been broken
     # before in unstable.

     # old style
     # (pkgs.texLiveAggregationFun {
     #  paths = [ pkgs.texLive
     #            pkgs.texLiveExtra
     #            pkgs.texLiveBeamer
     #            pkgs.lmodern # hidden dependency of xetex
     #            pkgs.tipa    # hidden dependency of xetex
     #          ];
     #  })

     # new style
     (texlive.combine {
      inherit (texlive) scheme-medium supertabular titlesec;
      # more packages to be found at
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/typesetting/tex/texlive-new/pkgs.nix if needed
     })

     lzma            # xz compressor
     lsof            # list open files
     lshw            # list hardware
     ltrace
     manpages
     mosh            # mobile shell (ssh alternative)
     mg              # micro-emacs
     ncdu            # disk-usage analysis
     netcat
     nettools
     nix-repl
     nox             # nixos package search
     nmap
     nasm            # assembler
     openssh
     pass            # password manager
     patchutils
     pciutils
     pmutils
     psmisc          # fuser, killall, pstree, peekfd
     powertop
     p7zip
     rfkill          # query, enable and disable wireless devices
     rsync
     s3cmd           # manipulate Amazon S3 buckets
     screen
     sharutils       # uuencode/decode
     smartmontools
     sudo
     sysstat
     traceroute
     time
     tree
     unison          # bi-directional sync
     units
     unrar
     unzip
     usbutils
     vcsh
     vim
     wget
     which
     zsh
     zip

     # minimal desktop
     rxvt_unicode
     compton
     dmenu
     dunst
     fontconfig
     i3lock
     # i3status
     i3blocks
     libnotify
     ponymix   # needed to output pulseaudio current volume
     xfontsel
     xclip
     xss-lock
     xsel

     xlibs.xmodmap
     xlibs.xev
     xlibs.xinput
     xlibs.xmessage
     xlibs.xkill
     xlibs.xgamma
     xlibs.xset
     xlibs.xrandr
     xlibs.xprop
  ];

  # use micro-emacs as the default editor
  environment.variables.EDITOR = pkgs.lib.mkOverride 0 "mg";

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true; # MS proprietary Core Fonts
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.corefonts
       pkgs.ttf_bitstream_vera
       pkgs.vistafonts          # e.g. consolas
       pkgs.font-awesome-ttf    # needed by my i3 config!
       # pkgs.source-code-pro
    ];
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Consolas" ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";
  users.extraUsers.tim = {
    description = "Tim Williams";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "audio"
      "dip"
      "lpadmin"
      "netdev"
      "plugdev"
      "sudo"
      "vboxusers"
      "video"
      "wheel"
    ];
  };


  services.udev = {
    extraRules = ''
      # For my Samsung Note 4 using go-mtpfs and fuse
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6860", MODE="0666", OWNER="tim"
    '';
  };

  services.logind.extraConfig = ''
    HandleLidSwitch=suspend
  '';

  # custom services
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

  # virtualisation.docker.enable = true;
}
