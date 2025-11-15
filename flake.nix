{
  description = "Custom packages for nix (multi-system flake)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, ... }:
    let
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          json-strong-typing =
            pkgs.callPackage ./pkgs/python-packages/json-strong-typing { };
          fastmcp = pkgs.callPackage ./pkgs/python-packages/fastmcp { };
          markdown-to-confluence =
            pkgs.callPackage ./pkgs/python-packages/markdown-to-confluence {
              inherit json-strong-typing;
            };
        in {
          smithy-cli = pkgs.callPackage ./pkgs/smithy { };
          inherit json-strong-typing fastmcp markdown-to-confluence;
          mcp-atlassian = pkgs.callPackage ./pkgs/mcp-atlassian {
            inherit markdown-to-confluence fastmcp;
          };
          mcp-server-git = pkgs.callPackage ./pkgs/mcp-server-git { };
          kubectl-mcp-server = pkgs.callPackage ./pkgs/kubectl-mcp-server { };
          context7-mcp = pkgs.callPackage ./pkgs/context7-mcp { };
          default = self.packages.${system}.smithy-cli;
        });

      # wrappers so `nix run` works
      apps = forAllSystems (system: {
        smithy-cli = {
          type = "app";
          program = "${self.packages.${system}.smithy-cli}/bin/smithy";
        };
        mcp-atlassian = {
          type = "app";
          program =
            "${self.packages.${system}.mcp-atlassian}/bin/mcp-atlassian";
        };
        mcp-server-git = {
          type = "app";
          program =
            "${self.packages.${system}.mcp-server-git}/bin/mcp-server-git";
        };
        kubectl-mcp-server = {
          type = "app";
          program = "${
              self.packages.${system}.kubectl-mcp-server
            }/bin/kubectl-mcp-server";
        };
        context7-mcp = {
          type = "app";
          program = "${self.packages.${system}.context7-mcp}/bin/context7-mcp";
        };
        default = self.apps.${system}.smithy-cli;
      });

      # overlay so you can use it from other flakes via `overlays`
      overlays.default = final: prev: {
        smithy-cli = final.callPackage ./pkgs/smithy { };
        json-strong-typing =
          final.callPackage ./pkgs/python-packages/json-strong-typing { };
        fastmcp = final.callPackage ./pkgs/python-packages/fastmcp { };
        markdown-to-confluence =
          final.callPackage ./pkgs/python-packages/markdown-to-confluence {
            inherit (final) json-strong-typing;
          };
        mcp-atlassian = final.callPackage ./pkgs/mcp-atlassian {
          inherit (final) markdown-to-confluence fastmcp;
        };
        mcp-server-git = final.callPackage ./pkgs/mcp-server-git { };
        kubectl-mcp-server = final.callPackage ./pkgs/kubectl-mcp-server { };
        context7-mcp = final.callPackage ./pkgs/context7-mcp { };
      };
    };
}
