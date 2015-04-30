{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # boot.kernelPackages = pkgs.linuxPackages_3_18;
  boot.kernelModules       = [ "tp_smapi" "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];
  boot.blacklistedKernelModules = [ "pcspkr" ];

  boot.initrd.kernelModules = [
   # Specify all kernel modules that are necessary for mounting the root
   # file system.
   "fbcon" "vfat" "i915" "aesni-intel" "usb_storage" "ehci_pci" "uhci_hcd" "ahci"
  ];

  # Legacy BIOS booting
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Crypto setup, set modules accordingly
  # boot.initrd.luks.cryptoModules = [ "aes" "xts" "sha512" ];
  #
  # boot.loader.gummiboot = {
  #   enable = true;
  #   timeout = 5;
  #  };
  #
  # boot.loader.efi = {
  #   canTouchEfiVariables = true;
  #   efibootmgr = {
  #     efidisk = "/dev/sda";
  #     efipartition = 1;
  #   };
  # };

  # boot.initrd.luks.devices = [
  #   {
  #     name = "root";
  #     device = "/dev/sda2";
  #     preLVM = true;
  #     allowDiscards = true;
  #   }
  # ];

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
  # fileSystems."/boot" = {
  #   label = "efi";
  #   device = "/dev/sda1";
  #   fsType = "vfat";
  # };
  # fileSystems."/" = {
  #   label = "root";
  #   device = "/dev/vg/root";
  #   fsType = "ext4";
  #   options = "discard,noatime";
  # };
  # swapDevices = [ { device = "/dev/vg/swap"; } ];

  fileSystems."/" = {
    label = "root";
    device = "/dev/sda1";
    fsType = "ext4";
    options = "discard,noatime";
  };
  fileSystems."/home" = {
    label = "home";
    device = "/dev/sda3";
    fsType = "ext4";
    options = "discard,noatime";
  };
  swapDevices = [ { device = "/dev/sda5"; } ];


  # Network
  networking = {
    hostName = "evil";  # Define your hostname.
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
    printing.enable = true;

    # thinkfan.enable = true;
    # thinkfan.sensor = "/sys/class/hwmon/hwmon1/temp1_input";

    # udev.packages = with pkgs; [ ];
    # udev.extraRules = ''...'';

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

      # multitouch.enable = true; # is this needed?

      # synaptics = {
      #   enable = true;
      #   twoFingerScroll = true;
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


  environment.shellAliases = {
    "l"   = "ls";
    "ll"  = "ls -al";
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
     bzip2
     bc
     cdparanoia
     colordiff
     coreutils
     cpio
     cpufrequtils
     cryptsetup
     curl
     dos2unix
     diffstat
     diffutils
     e2fsprogs
     file
     flac
     findutils
     gawk
     gdb
     ghostscript
     gitAndTools.gitFull
     gitAndTools.gitAnnex
     gnupg
     graphviz
     gzip
     hdparm
     htop            # multicore cpu monitoring
     iotop           # i/o monitoring
     iftop           # network monitoring
     iptables
     imagemagick
     lzma            # xz compressor
     lsof            # list open files
     lshw            # list hardware
     ltrace
     manpages
     mosh            # mobile shell (ssh alternative)
     mupdf           # fast pdf viewer lib
     netcat
     nettools
     nix-repl
     nmap
     nasm            # assembler
     openssh
     pass            # password manager
     patchutils
     pciutils
     pmutils
     psmisc          # fuser, killall, pstree, peekfd
     poppler         # pdf utils
     powertop
     p7zip
     rfkill          # query, enable and disable wireless devices
     rsync
     s3cmd           # manipulate Amazon S3 buckets
     screen
     smartmontools
     sudo
     sysstat
     traceroute
     time
     tree
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

     # Latex/Xetex
     (pkgs.texLiveAggregationFun {
       paths = [ pkgs.texLive
                 pkgs.texLiveExtra
                 pkgs.texLiveBeamer
                 pkgs.lmodern # hidden dependency of xetex
                 pkgs.tipa    # hidden dependency of xetex
               ];
       })

     # desktop support
     compton
     conky
     cmst # connman UI
     dmenu
     dunst
     emacs
     fontconfig
     haskellngPackages.yeganesh
     i3lock
     i3status
     libnotify
     nitrogen
     pavucontrol
     python34Packages.udiskie
     rdesktop
     rxvt_unicode
     scrot           # screen capture util
     # termite       # terminal emulator with fontconfig support
     unclutter
     weechat
     wmname          # set the windowmanager name
     xfontsel
     xclip
     xlibs.xmodmap
     xlibs.xev
     xlibs.xinput
     xlibs.xmessage
     xlibs.xkill
     xlibs.xgamma
     xlibs.xset
     xlibs.xrandr
     xss-lock

     # desktop apps
     chromium
     clawsMail
     dropbox
     libreoffice
     mendeley
     gnuplot_qt
     gtypist
     gimp
     inkscape
     # viber         # VOIP/Chat with 64-bits
     # tomahawk      # music player
     skype
     vlc
     zathura
     zathuraCollection.zathura_pdf_mupdf
     zathuraCollection.zathura_djvu
     zathuraCollection.zathura_ps

     # other packages (debian names)
     # autoconf
     # avahi (aka zeroconf?
     # quvi
     # sed
     # ufw
     # gdisk
  ];

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true; # MS proprietary Core Fonts
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.corefonts
       pkgs.ttf_bitstream_vera
       pkgs.vistafonts # e.g. consolas
       pkgs.source-code-pro
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
}
