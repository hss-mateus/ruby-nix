bundix: pkgs:
let
  rubyNix = import ./default.nix bundix pkgs;
  inherit
    (rubyNix {
      name = "rubynix-test";
      gemLock = ./tests/tiny_app/Gemfile.lock;
      ruby = pkgs.ruby_3_4;
    })
    env
    ruby
    ;
in
pkgs.mkShell {
  buildInputs =
    [
      ruby
      env
    ]
    ++ (with pkgs; [
      nix
      nixfmt
    ]);
}
