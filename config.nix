{ pkgs }: {


packageOverrides = super: let self = super.pkgs; in with self; rec {

  # TODO change to a function
  # http://stackoverflow.com/questions/27728838/using-hoogle-in-a-haskell-development-environment-on-nix
  ghcEnv = pkgs.buildEnv {
    name = "ghc-env";
    paths = with haskellPackages; [
      (ghcWithHoogle (import ~/nixos/haskell-packages.nix))
      alex happy cabal-install cabal2nix
      ghc-core
      hlint
      # pointfree
      hasktags
      # djinn mueval
      # lambdabot
      threadscope
      timeplot splot
      # liquidhaskell liquidhaskell-cabal
      # idris
      # Agda
      ];
    };

  # desktop support packages for which we want regular updates for
  desktopEnv = pkgs.buildEnv {
     name = "desktop-support";
     paths = [
         # polybar         # status bar

         cmst            # connman UI
         nitrogen        # background previewer/setter
         pavucontrol     # audio mixer
         copyq           # clipboard manager
         rofi            # drop-in dmenu replacement (xft support)
         arandr          # generate xrandr commands

         scrot           # screen capture util
         # termite       # terminal emulator with fontconfig support
         unclutter

         wmname          # set the windowmanager name

         recoll          # xapian search engine UI
         mupdf           # fast pdf viewer lib
         llpp            # less-like pdf viewer using mupdf (in OCaml!)
         ranger          # ncurses file browser

         redshift        # colour temperature adjustment for night time (gradual unlike xflux)
         # feh             # image viewer, useful to call with -ZFx
         sxiv            # simple bloat-free image viewer with thumbnails
         python27Packages.udiskie # automounter
         ];
  };

  # large app packages for which we want regular updates for
  appsEnv = pkgs.buildEnv {
     name = "apps";
     paths = [
         emacs

         # chromium
         # firefox
         google-chrome
         thunderbird

         dropbox
         libreoffice
         mendeley
         gnuplot_qt
         gtypist
         # gimp
         krita

         weechat
         # keepassx2       # qt-based password manager

         inkscape        # vector drawing
         # digikam         # photo management/viewer (needs kde themes below)
         # darktable       # RAW workflow
         # xournal         # tablet note taking

         kdiff3          # diff/merge tool
         xarchiver       # simple UI to browse archives
         httrack         # website downloader

         deadbeef-with-plugins  # music player
             # always check hardware is receiving 44.1Khz and no resampling
             # is happening!
             # use "pactl info" and e.g. cat /proc/asound/card0/pcm0p/sub0/hw_params
             # plugins inside ~/.local/lib/deadbeef

         vlc             # plays anything
         mpv             # good hardware video decoding
         smplayer        # richer UI for mpv

         # ardour        # DAW
         # guitarix      # virtual amp

         zathura         # configure for mupdf: zathura.useMupdf = true;

         rdesktop        # windows RDP client

         go-mtpfs        # transfer files to android phone: go-mtpfs ~/mnt, fusermount -u ~/mnt
         unetbootin      # make bootable USB keys from ISO images

         # abcde           # cd-ripping automation script - need 2.7.1+ for qaac

         poppler_utils   # pdf library and utils
         graphviz
         imagemagick

         wine            # for qaac

         # python27Full    # put python in nix-profile

         haskellPackages.yeganesh
         haskellPackages.pandoc

         # kde_workspace  # dark theme for digikam (!)
         # kde_baseapps
         # kdeadmin
         # desktopthemes
         ];
      };
  };

  allowUnfree = true;
  allowBroken = false;

  zathura.useMupdf = true;

  firefox = {
    enableGoogleTalkPlugin = true;
    enableAdobeFlash = true;
  };

  chromium = {
    enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
    enablePepperPDF = true;
  };
  
  polybar = pkgs.polybar.override {
    i3Support = true;
  };

# These must be built from source to get official branding - takes a long time!
#  packageOverrides = pkgs : with pkgs; rec {
#    firefox = pkgs.firefox.override { enableOfficialBranding = true; };
#    thunderbird = pkgs.thunderbird.override { enableOfficialBranding = true; };
#  };

}
