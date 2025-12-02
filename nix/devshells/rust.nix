{
  perSystem =
    { pkgs, ... }:
    {
      devShells.rust = pkgs.mkShell {
        RUST_SRC_PATH = toString pkgs.rust.packages.stable.rustPlatform.rustLibSrc;

        packages = [
          pkgs.cargo
          pkgs.rustc
        ];
      };
    };
}
