{
  perSystem =
    { pkgs, ... }:
    {
      devShells.zig = pkgs.mkShellNoCC {
        packages = [ pkgs.zig ];
      };
    };
}
