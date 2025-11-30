{
  perSystem =
    { pkgs, ... }:
    {
      devShells.haskell = pkgs.mkShell {
        packages = [ pkgs.ghc ];
      };
    };
}
