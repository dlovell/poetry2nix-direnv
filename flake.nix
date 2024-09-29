{
  description = "A template for using nix-direnv and poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    nix-utils = {
      url = "github:letsql/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-utils }: {
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
      utils = nix-utils.lib.${system}.mkUtils { inherit pkgs; };
      nix-flake-metadata-refresh = utils.mkNixFlakeMetadataRefreshApp "github:dlovell/poetry2nix-direnv";
    in
    {
      apps = {
        inherit nix-flake-metadata-refresh;
        default = self.apps.${system}.nix-flake-metadata-refresh;
      };
    }));
}
