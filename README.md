# Smithy 

install [smithy](https://github.com/smithy-lang/smithy) from binary release with nix.

## Install 

```sh
nix profile add .#
```

## remove

```sh
nix profile remove smithy-nixpkg
```

## use in devShell


```flake.nix
{
  description = "A Nix-flake providing development tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.smithy.url = "github:gotha/smithy-nixpkg?ref=main";

  outputs = { self, nixpkgs, smithy, ... }:
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
            (smithy.packages.${system}.smithy-cli)
          ];
        };
      });
    };
}
```
