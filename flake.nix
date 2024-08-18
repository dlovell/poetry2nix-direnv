{
  description = "A template for using nix-direnv and poetry2nix";

  outputs = { self }: {
    templates = {
      poetry2nix-direnv = {
        path = ./poetry2nix-direnv;
        description = "Application packaged using nix-direnv and poetry2nix";
        welcomeText = ''
          You just create a poetry2nix-direnv template
        '';
      };
      default = self.templates.poetry2nix-direnv;
      defaultTemplate = self.templates.poetry2nix-direnv;
    };
  };
}
