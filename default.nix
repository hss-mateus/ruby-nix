bundix:

{
  stdenv,
  lib,
  buildEnv,
  ruby,
  makeBinaryWrapper,
  defaultGemConfig,
  buildRubyGem,
  runCommand,
  system,
  ...
}@pkgs:

# this is where we specify how the ruby environment should be built
{
  name ? "ruby-nix", # passed along to buildEnv
  gemLock ? null, # path to Gemfile.lock
  gemset ? null, # path to gemset.nix
  ruby ? pkgs.ruby, # allow ruby to be overriden
  gemConfig ? defaultGemConfig, # specific build instructions for native gems
  groups ? null, # null or a list of groups, used by Bundler.setup
  document ? [ ], # e.g. [ "ri" "rdoc" ]
  extraRubySetup ? null, # additional setup script goes here
  ignoreCollisions ? true, # whether to ignore collisions or abort
}:

let
  my = import ./mylib.nix pkgs;

  resolved-gemset =
    if gemset == null then
      runCommand "gemset" { nativeBuildInputs = [ bundix.packages.${system}.default ]; } ''
        touch Gemfile
        cp ${gemLock} ./Gemfile.lock
        bundix --gemset=$out
      ''
    else
      gemset;

  requirements = (
    pkgs
    // {
      inherit
        my
        name
        ruby
        gempaths
        gemConfig
        groups
        document
        extraRubySetup
        ignoreCollisions
        ;

      gemset = import resolved-gemset;
    }
  );

  inherit (import ./modules/gems requirements) gempaths;
  inherit (import ./modules/ruby-env requirements) env envMinimal;
in
rec {
  version = "v0.1.2";
  ruby = env.ruby;
  inherit env envMinimal;
}
