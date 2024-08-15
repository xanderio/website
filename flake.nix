{
  description = "xanderio.de flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x68_64-linux"
        "x68_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, lib, ... }:
        {
          packages = rec {
            website = pkgs.stdenvNoCC.mkDerivation {
              pname = "xanderio-blog";
              version =
                let
                  mtime = inputs.self.lastModifiedDate;
                in
                "${lib.substring 0 4 mtime}-${lib.substring 4 2 mtime}-${lib.substring 6 2 mtime}";

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

          devShells.default = pkgs.mkShellNoCC { buildInputs = [ pkgs.zola ]; };
        };
    };
}
