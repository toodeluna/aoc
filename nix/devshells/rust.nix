{
  perSystem =
    { pkgs, ... }:
    {
      devShells.rust = pkgs.mkShell {
        packages = [ pkgs.cargo ];
      };
    };
}
