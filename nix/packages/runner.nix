{ self, lib, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      requiredPackages = lib.flatten (
        map (shell: shell.nativeBuildInputs) (lib.attrValues self'.devShells)
      );
    in
    {
      packages.default = pkgs.writeShellApplication {
        name = "aoc-runner";
        runtimeInputs = requiredPackages ++ [ pkgs.clang ];
        text = builtins.readFile "${self}/scripts/runner.sh";
      };
    };
}
