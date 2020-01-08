let
  pkgs = import <nixpkgs> {};
  gems = pkgs.bundlerEnv {
    name = "kaiser-gems";
    gemdir = ./.;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "kaiser";
    src = null;
    buildInputs = [
      gems
    ];
  }

