{
  perSystem =
    { pkgs, ... }:
    {
      devShells.zig = pkgs.mkShell {
        packages = [ pkgs.zig ];
      };
    };
}
