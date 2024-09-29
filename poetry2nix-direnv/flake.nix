{
  description = "Application packaged using nix-direnv and poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-utils = {
      url = "github:letsql/nix-utils/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, nix-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            poetry2nix.overlays.default
          ];
        };
        utils = nix-utils.lib.${system}.mkUtils { inherit pkgs; };
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
        myapp = mkPoetryApplication {
          projectDir = ./.;
          preferWheels = true;
        };
        mypython = myapp.python.withPackages (_: myapp.requiredPythonModules ++ [ myapp ]);
      in {
        apps = {
          # nix-flake-metadata-refresh = utils.mkNixFlakeMetadataRefresh "github:myuser/this-repo";
          mypython = utils.drvToApp { drv = mypython; name = "python"; };
          default = self.apps.${system}.mypython;
        };
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
