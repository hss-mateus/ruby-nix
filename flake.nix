{
  description = "Nix function(s) for creating ruby environments";

  inputs = {
    nixpkgs.url = "nixpkgs";

    bundix = {
      url = "github:hss-mateus/bundix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, bundix }:
    {
      lib = import ./. bundix;

      overlays.ruby = import ./modules/overlays/ruby-overlay.nix;

      templates = {
        simple-app = {
          path = ./examples/simple-app;
          description = "A flake that drives a simple ruby app";
        };
      };
      templates.default = self.templates.simple-app;

      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ (import ./modules/overlays/ruby-overlay.nix) ];
          };
        in
        import ./shell.nix bundix pkgs;
    };
}
