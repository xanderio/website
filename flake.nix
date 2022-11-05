{
  description = "xanderio.de flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      inherit (builtins) substring;
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages = rec {
        website = pkgs.stdenvNoCC.mkDerivation {
          pname = "xanderio-blog";
          version = let mtime = self.lastModifiedDate; in
            "${substring 0 4 mtime}-${substring 4 2 mtime}-${substring 6 2 mtime}";

          src = ./.;
          buildInputs = [ pkgs.zola ];
          buildPhase = ''
            	    zola build
            	  '';
          installPhase = ''
            	    mkdir -p $out
            	    cp -r public/* $out
            	  '';
        };
        default = website;
      };

      devShells.default = pkgs.mkShellNoCC {
        buildInputs = [ pkgs.zola ];
      };
    });
}
