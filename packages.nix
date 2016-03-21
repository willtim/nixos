# Install all of them with:
#    nix-env -f packages.nix -i
# Install all the packages and remove everything else:
#    nix-env -f packages.nix -ir
#
# NOTE: config overrides in ~/.nixpkgs/config.nix
#
with (import <nixpkgs> {});
{

  inherit
     # desktop support
     conky
     cmst            # connman UI
     emacs
     mupdf           # fast pdf viewer lib
     nitrogen        # background previewer/setter
     pavucontrol     # audio mixer
     copyq           # clipboard manager
     rdesktop

     scrot           # screen capture util
     # termite       # terminal emulator with fontconfig support
     unclutter
     weechat
     wmname          # set the windowmanager name

     # utils
     redshift        # colour temperature adjustment for night time (gradual unlike xflux)
     feh             # image viewer, useful to call with -ZFx
     sxiv            # simple image viewer, alternative to feh
     poppler         # pdf library and utils
     go-mtpfs        # transfer files to android phone: go-mtpfs ~/mnt, fusermount -u ~/mnt

     # abcde           # cd-ripping automation script - need 2.7.1+ for qaac

     graphviz
     imagemagick

     wine            # for qaac

     rofi            # drop-in dmenu replacement (xft support)
     arandr          # generate xrandr commands
     python27Full    # put python in nix-profile

     # themes
     arc-gtk-theme           # in my .gtkrc-2.0
     gtk-engine-murrine      # hidden thunar dependency
     numix-icon-theme        # in my .gtkrc-2.0
     numix-icon-theme-circle
     hicolor_icon_theme
  ;

  inherit (haskellngPackages)
     yeganesh
     pandoc
  ;

  inherit (xfce)
     thunar
     exo
  ;

  inherit (gnome3)
     gnome_themes_standard  # gtk2 and gtk3 themes
     gnome_icon_theme       # icons
  ;

  inherit
     # desktop apps
     chromium
     firefox
     thunderbird
     dropbox
     libreoffice
     mendeley
     gnuplot_qt
     gtypist
     gimp
     inkscape        # vector drawing
     digikam         # photo management/viewer (needs kde themes below)
     darktable       # RAW workflow

     kdiff3          # diff/merge tool
     recoll          # xapian search engine UI
     xarchiver       # simple UI to browse archives
     httrack         # website downloader

     # viber         # VOIP/Chat with 64-bits
     skype

     deadbeef        # music player - always check hardware is receiving 44.1Khz and no resampling is happening!
                     # use "pactl info" and e.g. cat /proc/asound/card0/pcm0p/sub0/hw_params
                     # plugins inside ~/.local/lib/deadbeef

     vlc             # plays anything
     mpv             # good hardware video decoding
     smplayer        # richer UI for mpv

     # ardour        # DAW
     # guitarix      # virtual amp

     zathura         # configure for mupdf in config.nix: zathura.useMupdf = true;

  ;

  #oraclejdk8 # cannot be auto-installed!!
  #inherit(idea)
  #   idea-community
  #;

  inherit(kde4)
     kde_workspace  # dark theme for digikam (!)
     kde_baseapps
     kdeadmin
     desktopthemes
  ;

  inherit(python27Packages)
     udiskie # automounter
     pip     # use --user to install e.g. gcalcli locally
     notify
     dbus
     pygobject
     pycairo
     pygtk
  ;
}
