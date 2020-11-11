{ pkgs }: {

packageOverrides = super: let self = super.pkgs; in with self; rec {

  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    pysdl2
    setuptools
    pip
    # other python packages you want
  ];
  python-with-my-packages = python3.withPackages my-python-packages;

  profiledHaskellPackages = self.haskellPackages.override {
      overrides = self: super: {
        mkDerivation = args: super.mkDerivation (args // {
          enableLibraryProfiling = true;
        });
      };
    };

  # TODO change to a function
  # http://stackoverflow.com/questions/27728838/using-hoogle-in-a-haskell-development-environment-on-nix
  ghcEnv = pkgs.buildEnv {
    name = "ghc-env";
    paths = with haskellPackages; [
      (ghcWithHoogle (import ./haskell-packages.nix))
      alex happy
      # cabal-install cabal2nix
      ghc-core
      hlint
      # pointfree
      hasktags
      # djinn mueval
      # lambdabot
      # threadscope ## marked as broken 20190722
      # timeplot    ## /
      # splot
      # liquidhaskell liquidhaskell-cabal
      # idris
      # Agda
      ];
    };
  };

  allowUnfree = true;
  allowBroken = false;

  zathura.useMupdf = true;

  firefox = {
    # enableGoogleTalkPlugin = true;
    enableAdobeFlash = true;
  };

  polybar = pkgs.polybar.override {
    i3Support = true;
  };

  mixxx = pkgs.mixxx.override {
    aacSupport = true;
  };

}
