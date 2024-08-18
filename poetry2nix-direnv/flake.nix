{
  description = "Application packaged using nix-direnv and poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            poetry2nix.overlays.default
          ];
        };
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
        myapp = mkPoetryApplication {
          projectDir = ./.;
          preferWheels = true;
        };
      in
      {
        packages = {
          inherit myapp;
          default = self.packages.${system}.myapp;
        };
        devShells = {
          inputs = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.myapp ];
          };
          poetry = pkgs.mkShell {
            packages = [ pkgs.poetry ];
          };
          myShell = pkgs.mkShell {
            packages = [
              pkgs.poetry
              myapp
            ];
          };
          default = self.devShells.${system}.myShell;
        };
      });
}
