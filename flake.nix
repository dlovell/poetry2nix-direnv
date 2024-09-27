{
  description = "A template for using nix-direnv and poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    # templates must not live insides eachDefaultSystem
    templates = {
      poetry2nix-direnv = {
        path = ./poetry2nix-direnv;
        description = "Application packaged using nix-direnv and poetry2nix";
        welcomeText = ''
          You just created a poetry2nix-direnv template
        '';
      };
      default = self.templates.poetry2nix-direnv;
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      nix-flake-metadata-refresh = pkgs.writeShellScriptBin "nix-flake-metadata-refresh" ''
        ${pkgs.nix}/bin/nix flake metadata --refresh github:dlovell/poetry2nix-direnv
      '';
    in
    {
      apps = {
        nix-flake-metadata-refresh = {
          type = "app";
          program = "${nix-flake-metadata-refresh}/bin/nix-flake-metadata-refresh";
        };
        default = self.apps.${system}.nix-flake-metadata-refresh;
      };
    }));
}
