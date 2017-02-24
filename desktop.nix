{ config, pkgs, expr, buildVM, ... }:

let
  iconTheme = pkgs.kde5.breeze-icons.out;
  themeEnv = ''
    # QT: remove local user overrides (for determinism, causes hard to find bugs)
    rm -f ~/.config/Trolltech.conf

    # GTK3: remove local user overrides (for determinisim, causes hard to find bugs)
    rm -f ~/.config/gtk-3.0/settings.ini

    # GTK3: add breeze theme to search path for themes
    # (currently, we need to use gnome-breeze because the GTK3 version of kde5.breeze is broken)
    export XDG_DATA_DIRS="${pkgs.gnome-breeze}/share:$XDG_DATA_DIRS"

    # GTK3: add /etc/xdg/gtk-3.0 to search path for settings.ini
    # We use /etc/xdg/gtk-3.0/settings.ini to set the icon and theme name for GTK 3
    export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

    # GTK2 theme + icon theme
    export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="breeze"''}:${pkgs.kde5.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc:$GTK2_RC_FILES

    # SVG loader for pixbuf (needed for GTK svg icon themes)
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache)

    # LS colors
    eval `${pkgs.coreutils}/bin/dircolors "${./dircolors}"`
  '';

in {

imports = [];

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

  multitouch.enable = true;
  multitouch.ignorePalm = true;

  synaptics = {
     enable = true;
     twoFingerScroll = true;
     horizTwoFingerScroll = true;

     buttonsMap = [ 1 3 2];
     fingersMap = [ 0 0 0 ];
     tapButtons = false;
     vertEdgeScroll = false;
  };

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
  displayManager.sessionCommands = ''
     ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr

     ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
     ${pkgs.xlibs.xrdb}/bin/xrdb -merge /etc/X11/Xresources

     # Assume laptop keyboard and swap Ctrl and Alt
     [ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

     # background image - nitrogen has better multihead support than feh
     ${pkgs.nitrogen}/bin/nitrogen --restore

     # Subscribes to the systemd events and invokes i3lock.
     # Send notification after 10 mins of inactivity,
     # lock the screen 10 seconds later.
     # TODO nixify xss-lock scripts
     ${pkgs.xlibs.xset}/bin/xset 600 10
     ${pkgs.xss-lock}/bin/xss-lock -n ~/bin/lock-notify.sh -- ~/bin/lock.sh &

     # disable PC speaker beep
     ${pkgs.xlibs.xset}/bin/xset -b
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
  dmenu
  dunst
  fontconfig
  i3lock
  # i3blocks
  polybar
  redshift
  rofi
  libnotify
  xfontsel
  xclip
  xss-lock
  xsel
  unclutter

  compton
  nitrogen # better multihead support than feh

  xlibs.xmodmap
  xlibs.xev
  xlibs.xinput
  xlibs.xmessage
  xlibs.xkill
  xlibs.xgamma
  xlibs.xset
  xlibs.xrandr
  xlibs.xprop

  # GTK theme
  kde5.breeze-gtk
  gnome-breeze
  gnome3.gnome_themes_standard
  gnome_icon_theme
  gtk-engine-murrine # sometimes a hidden dependency

  # Qt theme
  kde5.breeze-qt5
  kde5.breeze-qt4

  # Icons (Main)
  iconTheme

  # Icons (Fallback)
  kde5.oxygen-icons5
  gnome3.adwaita-icon-theme
  hicolor_icon_theme

  # These packages are used in autostart, they need to in systemPackages
  # or icons won't work correctly
  pythonPackages.udiskie connman-notify

];

# Make applications find files in <prefix>/share
environment.pathsToLink = [ "/share" ];

services.udev = {
    extraRules = ''
      # For my Samsung Note 4 using go-mtpfs and fuse
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6860", MODE="0666", OWNER="tim"
    '';
 };
}
