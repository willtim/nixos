{ config, pkgs, ... }:

{

  console.font = "lat9w-16"; # "sun12x22";  
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  time.timeZone = "Europe/London";

  # Nikpgs overrides
  nixpkgs.config = {
    allowUnfree = true;

    zathura.useMupdf = true;

    firefox = {
      # enableGoogleTalkPlugin = true;
      # enableAdobeFlash = true;
    };

    # These must be built from source to get official branding - takes a long time!
    #  packageOverrides = pkgs : with pkgs; rec {
    #    firefox = pkgs.firefox.override { enableOfficialBranding = true; };
    #    thunderbird = pkgs.thunderbird.override { enableOfficialBranding = true; };
    #  };

    packageOverrides = super: let self = super.pkgs; in
    {
      haskellEnv = self.haskellPackages.ghcWithPackages (p: with p; [
        cabal2nix
        cabal-install
        QuickCheck
      ]);
    };

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
     acpi
     acpid
     aspell
     aspellDicts.en
     bc
     bmon # simple bandwidth monitor and rate estimator
pwgen
     bzip2
     cabextract
     cdparanoia
     cdrkit
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
     dhex            # hex editor with diff
     dmidecode       # read and display firmware info

     file

     firejail        # lightweight security sandbox

     flac            # lossless audio encoder

     libcdio         # abcde dependencies
     cddiscid
     eject
     mkcue

     findutils
     gawk
     gdb
     geteltorito
     ghostscript
     gitAndTools.gitFull
     # gitAndTools.gitAnnex
     gnupg
     gzip
     hdparm
     htop            # multicore cpu monitoring
     iotop           # i/o monitoring
     iftop           # network monitoring
     iptables

     # LaTex/XeTex is here in configuration.nix as it is expensive to build/rebuild and has been broken
     # before in unstable.
     # new style
     (texlive.combine {
       inherit (texlive) scheme-medium collection-latexextra supertabular titlesec tikz-qtree minted;
       # more packages to be found at
       # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/typesetting/tex/texlive/pkgs.nix if needed
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
     nox             # nixos package search
     nmap
     nasm            # assembler
     openssh
     openvpn
     pass            # password manager
     patchutils
     pciutils
     pmutils
     psmisc          # fuser, killall, pstree, peekfd
     powertop
     pwgen
     p7zip

     rlwrap          # readline wrap
     ripgrep         # fast grep
     rsync

     silver-searcher # a.k.a. ag
     s3cmd           # manipulate Amazon S3 buckets
     sharutils       # uuencode/decode
     smartmontools
     stow
     sudo
     sysstat
     tmux
     traceroute
     time
     tree
     unison          # bi-directional sync
     units
     unrar
     unzip
     usbutils
     utillinux
     vim
     wget
     which
     xfsprogs        # XFS filesystem utils
     exfat           # for SD cards
     zip

     gnupg
     opensc
     pcsctools
     libu2f-host
     yubikey-personalization
     wireguard

   ];

  # use micro-emacs as the default editor
  environment.variables.EDITOR = pkgs.lib.mkOverride 0 "mg";

  programs.bash.enableCompletion = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = "/var/run/current-system/sw/bin/bash";
  users.extraUsers.tim = {
    description = "Tim Williams";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "audio"
      "input"
      "dip"
      "lpadmin"
      "netdev"
      "plugdev"
      "sudo"
      "vboxusers"
      "docker"
      "video"
      "wheel"
    ];
  };

  services.pcscd.enable = true;
  services.udev.packages  = [
      pkgs.libu2f-host
      pkgs.yubikey-personalization
  ];
}
