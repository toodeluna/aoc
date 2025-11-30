{ inputs, ... }:
{
  imports = [ inputs.treefmt.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs = {
      nixfmt.enable = true;
      ormolu.enable = true;
      rustfmt.enable = true;
      shellcheck.enable = true;
      zig.enable = true;
    };
  };
}
