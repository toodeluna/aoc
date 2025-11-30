{ inputs, ... }:
{
  imports = [ inputs.treefmt.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs = {
      nixfmt.enable = true;
      ormolu.enable = true;
      rustfmt.enable = true;
      zig.enable = true;
    };
  };
}
