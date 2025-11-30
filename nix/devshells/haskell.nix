{
  perSystem =
    { pkgs, ... }:
    {
      devShells.haskell = pkgs.mkShellNoCC {
        packages = [ pkgs.ghc ];
      };
    };
}
