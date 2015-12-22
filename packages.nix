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
     feh             # image viewer, useful to call with -ZFx
     sxiv            # simple image viewer, alternative to feh
     poppler         # pdf library and utils
     graphviz
     imagemagick
  ;

  inherit (haskellngPackages)
     yeganesh
     pandoc
  ;

  inherit (gnome3)
     gnome_themes_standard  # gtk2 and gtk3 themes
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
     clementine      # music player
     inkscape        # vector drawing
     digikam         # photo management/viewer

     recoll          # xapian search engine UI
     xarchiver       # simple UI to browse archives
     httrack         # website downloader

     # viber         # VOIP/Chat with 64-bits
     skype
     vlc
     zathura

     rofi            # drop-in dmenu replacement (xft support)
     python27Full    # put python in nix-profile
  ;

  #oraclejdk8 # cannot be auto-installed!!
  #inherit(idea)
  #   idea-community
  #;

  inherit(python27Packages)
     ranger  # fast file-browsing via console
     pip     # use --user to install e.g. gcalcli locally
     notify
     dbus
     pygobject
     pycairo
     pygtk
  ;

  inherit (zathuraCollection)
     zathura_pdf_mupdf
     zathura_djvu
     zathura_ps
  ;
}
