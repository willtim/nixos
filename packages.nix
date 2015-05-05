# Install all of them with:
#    nix-env -f packages.nix -i
# Install all the packages and remove everything else:
#    nix-env -f packages.nix -ir
#
with (import <nixpkgs> {});
{

  inherit
     # desktop support
     conky
     cmst # connman UI
     emacs
     mupdf           # fast pdf viewer lib
     nitrogen
     pavucontrol
     rdesktop

     scrot           # screen capture util
     # termite       # terminal emulator with fontconfig support
     unclutter
     weechat
     wmname          # set the windowmanager name

     # utils
     poppler         # pdf library and utils
     graphviz
     imagemagick
  ;

  # Latex/Xetex
  texLive = (pkgs.texLiveAggregationFun {
       paths = [ pkgs.texLive
                 pkgs.texLiveExtra
                 pkgs.texLiveBeamer
                 pkgs.lmodern # hidden dependency of xetex
                 pkgs.tipa    # hidden dependency of xetex
               ];
       });

  inherit (haskellngPackages)
     yeganesh
     pandoc
  ;

  inherit (python34Packages)
     udiskie
  ;

  inherit (gnome3)
     gnome_themes_standard  # gtk2 and gtk3 themes
  ;


  inherit
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
 ;

 inherit (zathuraCollection)
     zathura_pdf_mupdf
     zathura_djvu
     zathura_ps
 ;
}
