{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/4181644d09b96af0f92c2f025d3463f9d19c7790.tar.gz") {} }:
with pkgs;
let
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix/";
    ref = "refs/tags/3.3.0";
  }) {};
  customPython = mach-nix.mkPython {
    python = "python38";
    requirements = ''
      sel4-deps
    '';
  };
in
pkgs.mkShell {
  buildInputs = [ customPython mlton curl ncurses ninja
    gnumake rsync zlib cmake
    libyaml stack ccache libxml2
    dtc librsvg texlive.combined.scheme-full isabelle gitRepo ];

  shellHook = ''
    stack upgrade --binary-only
    repo init -u ssh://git@github.com/seL4/verification-manifest.git
    repo sync
    mkdir -p ~/.isabelle/etc
    cp l4v/misc/etc/settings ~/.isabelle/etc/settings
    ./isabelle/bin/isabelle components -a
    ./isabelle/bin/isabelle jedit -bf
    ./isabelle/bin/isabelle build -bv HOL-Word
  '';
}
