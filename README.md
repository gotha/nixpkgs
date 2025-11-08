# nixpkgs

collection of custom packages for nix

## use in devShell

```flake.nix
{
  description = "my nix-flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.gotha.url = "github:gotha/nixpkgs?ref=main";

  outputs = { self, nixpkgs, gotha, ... }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import nixpkgs { inherit system; }; });
    in {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            coreutils
            (gotha.packages.${system}.smithy-cli)
          ];
        };
      });
    };
}
```
