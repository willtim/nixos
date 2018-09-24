{ config, pkgs, expr, buildVM, ... }:

let
  iconTheme = pkgs.breeze-icons.out;
  themeEnv = ''
    # QT: remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/Trolltech.conf

    # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini

    # GTK3: add breeze theme to search path for themes
    # (currently, we need to use gnome-breeze because the GTK3 version of breeze is broken)
    export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)

    # LS colors
    eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`
  '';

in {

imports = [];

nixpkgs.config = {
  packageOverrides = pkgs: rec {
    polybar = pkgs.polybar.override {
      i3Support = true;
    };
  };
};

fonts = {
    enableFontDir = true;
    enableCoreFonts = true; # MS proprietary Core Fonts
    enableGhostscriptFonts = true;
    fonts = [
       pkgs.corefonts
       pkgs.ttf_bitstream_vera
       pkgs.vistafonts          # e.g. consolas
       pkgs.font-awesome-ttf    # needed by my i3 config!
       pkgs.opensans-ttf        # my favourite sans font
       # pkgs.source-code-pro
    ];
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Consolas" ];
    };
  };

# needed to unlock gnome_keyring
# set the keyring password to be the same as the login
security.pam.services = [
  { name = "gnome_keyring";
    text = ''
      auth     optional    ${pkgs.gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
      session  optional    ${pkgs.gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so auto_start

      password  optional    ${pkgs.gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
    '';
  }
];

services.accounts-daemon.enable = true; # needed by lightdm

# Required for our screen-lock-on-suspend functionality
services.logind.extraConfig = ''
   LidSwitchIgnoreInhibited=False
   HandleLidSwitch=suspend
   HoldoffTimeoutSec=10
'';

# Enable the X11 windowing system.
services.xserver = {
  enable = true;
  useGlamor = true;

  layout = "gb";
  autorun = true;
  exportConfiguration = true;

  # wacom.enable = true;  # for my bamboo stylus

  # use the touch-pad for scrolling
  libinput = {
    enable = true;
    disableWhileTyping = true;
    naturalScrolling = true; # reverse scrolling
    scrollMethod = "twofinger";
    tapping = false;
    tappingDragLock = false;
  };

  # consensus is that libinput gives better results
  synaptics.enable = false;

  config = ''
      Section "InputClass"
        Identifier     "Enable libinput for TrackPoint"
        MatchIsPointer "on"
        Driver         "libinput"
        Option         "ScrollMethod" "button"
        Option         "ScrollButton" "8"
      EndSection
    '';

  xkbOptions = "eurosign:e";
  windowManager.i3.enable = true;
  # windowManager.default = "i3";
  displayManager.lightdm = {
    enable = true;
#    autoLogin = {
#      enable = true;
#      user = "tim";
#    };
  };

  videoDrivers = [ "intel" ];
  deviceSection = ''
    Option "DRI" "3"
    Option "TearFree" "true"
  '';

  displayManager.sessionCommands = ''
     ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr

     ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
     # ${pkgs.xlibs.xrdb}/bin/xrdb -merge /etc/X11/Xresources

     [ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

     # Restore color profile.
     # NOTE: xiccd is too buggy and sometimes eats 100% cpu... and seems unmaintained
     # pgrep xiccd>/dev/null || ${pkgs.xiccd}/bin/xiccd &
     {pkgs.argyllcms}/bin/dispwin -I "/home/tim/.local/share/icc/B140HAN01.7 #1 2018-03-09 13-53 2.2 F-S XYZLUT+MTX.icc"

     # background image - nitrogen has better multihead support than feh
     ${pkgs.nitrogen}/bin/nitrogen --restore

     # Subscribes to the systemd events and invokes i3lock.
     # Send notification after 10 mins of inactivity,
     # lock the screen 10 seconds later.
     # TODO nixify xss-lock scripts
     ${pkgs.xlibs.xset}/bin/xset s 600 10
     ${pkgs.xss-lock}/bin/xss-lock -n /home/tim/bin/lock-notify.sh -- /home/tim/bin/lock.sh &

     # disable PC speaker beep
     # ${pkgs.xlibs.xset}/bin/xset -b

     # gpg-agent for X session
     gpg-connect-agent /bye
     GPG_TTY=$(tty)
     export GPG_TTY

     # use gpg-agent for SSH
     # NOTE: make sure enable-ssh-support is included in ~/.gnupg/gpg-agent.conf
     unset SSH_AGENT_PID
     export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"
  '';
};

environment.extraInit = ''
  ${themeEnv}

  # these are the defaults, but some applications are buggy so we set them
  # here anyway
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
'';

# QT4/5 global theme
environment.etc."xdg/Trolltech.conf" = {
  text = ''
    [Qt]
    style=Breeze
  '';
  mode = "444";
};

# GTK3 global theme (widget and icon theme)
environment.etc."xdg/gtk-3.0/settings.ini" = {
  text = ''
    [Settings]
    gtk-icon-theme-name=breeze
    gtk-theme-name=Breeze-gtk
  '';
  mode = "444";
};

environment.systemPackages = with pkgs; [
  # i3 desktop support
  rxvt_unicode
  cmst
  desktop_file_utils
  dmenu
  dunst
  fontconfig
  i3lock
  polybar
  libnotify
  xfontsel
  xclip
  xss-lock
  xsel
  unclutter

  argyllcms # create color profiles
  # xiccd   # buggy 100% CPU color management
  compton
  nitrogen  # better multihead support than feh
  pinentry_qt4

  xlibs.xbacklight
  xlibs.xmodmap
  xlibs.xev
  xlibs.xinput
  xlibs.xmessage
  xlibs.xkill
  xlibs.xgamma
  xlibs.xset
  xlibs.xrandr
  xlibs.xrdb
  xlibs.xprop
  xlibs.libXScrnSaver # for argyllcms

  # GTK theme
  breeze-gtk
  gnome-breeze
  gnome3.gnome_themes_standard

  # keyring (e.g. for Skype)
  gnome3.gnome_keyring

  # Qt theme
  breeze-qt5
  # breeze-qt4

  # Icons (Main)
  iconTheme

  # Icons (Fallback)
  oxygen-icons5
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  pythonPackages.udiskie connman-notify # skype

];

# needed by mendeley
services.dbus.packages = [ pkgs.gnome3.gconf.out pkgs.gnome3.dconf ];

# needed by gtk apps
services.gnome3.at-spi2-core.enable = true;

# needed by skype
services.gnome3.gnome-keyring.enable = true;

# Make applications find files in <prefix>/share
environment.pathsToLink = [ "/share" "/etc/gconf" ];

services.udev = {
    packages = [ pkgs.libmtp ];
    extraRules = ''
      # For my Samsung Note 4 using go-mtpfs and fuse
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6860", MODE="0666", OWNER="tim"
    '';
 };
}
