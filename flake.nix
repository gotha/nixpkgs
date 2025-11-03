{
  description = "Smithy CLI (multi-system flake)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, ... }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          smithy-cli = pkgs.callPackage ./smithy.nix { };
          default = self.packages.${system}.smithy-cli;
        });

      # wrappers so `nix run` works
      apps = forAllSystems (system: {
        smithy-cli = {
          type = "app";
          program = "${self.packages.${system}.smithy-cli}/bin/smithy";
        };
        default = self.apps.${system}.smithy-cli;
      });

      # overlay so you can use it from other flakes via `overlays`
      overlays.default = final: prev: {
        smithy-cli = final.callPackage ./smithy.nix { };
      };
    };
}
