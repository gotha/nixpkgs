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
          context7-mcp = pkgs.callPackage ./pkgs/context7-mcp { };
          gcloud-mcp = pkgs.callPackage ./pkgs/gcloud-mcp { };
          kubectl-mcp-server = pkgs.callPackage ./pkgs/kubectl-mcp-server { };
          mcp-atlassian = pkgs.callPackage ./pkgs/mcp-atlassian {
            inherit markdown-to-confluence fastmcp;
          };
          mcp-server-git = pkgs.callPackage ./pkgs/mcp-server-git { };
          mcp-server-github = pkgs.callPackage ./pkgs/mcp-server-github { };
          mcp-server-memory = pkgs.callPackage ./pkgs/mcp-server-memory { };
          mcp-server-sequential-thinking = pkgs.callPackage ./pkgs/mcp-server-sequential-thinking { };
          smithy-cli = pkgs.callPackage ./pkgs/smithy { };
          goose = pkgs.callPackage ./pkgs/goose { };
          inherit json-strong-typing fastmcp markdown-to-confluence;
        });

      # wrappers so `nix run` works
      apps = forAllSystems (system: {
        context7-mcp = {
          type = "app";
          program = "${self.packages.${system}.context7-mcp}/bin/context7-mcp";
        };
        gcloud-mcp = {
          type = "app";
          program = "${self.packages.${system}.gcloud-mcp}/bin/gcloud-mcp";
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
        mcp-server-github = {
          type = "app";
          program =
            "${self.packages.${system}.mcp-server-github}/bin/mcp-server-github";
        };
        mcp-server-memory = {
          type = "app";
          program =
            "${self.packages.${system}.mcp-server-memory}/bin/mcp-server-memory";
        };
        mcp-server-sequential-thinking = {
          type = "app";
          program =
            "${self.packages.${system}.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking";
        };
        kubectl-mcp-server = {
          type = "app";
          program = "${
              self.packages.${system}.kubectl-mcp-server
            }/bin/kubectl-mcp-server";
        };
        smithy-cli = {
          type = "app";
          program = "${self.packages.${system}.smithy-cli}/bin/smithy";
        };
        goose = {
          type = "app";
          program = "${self.packages.${system}.goose}/bin/goose";
        };
      });

      # overlay so you can use it from other flakes via `overlays`
      overlays.default = final: prev: {
        gcloud-mcp = final.callPackage ./pkgs/gcloud-mcp { };
        context7-mcp = final.callPackage ./pkgs/context7-mcp { };
        fastmcp = final.callPackage ./pkgs/python-packages/fastmcp { };
        json-strong-typing =
          final.callPackage ./pkgs/python-packages/json-strong-typing { };
        kubectl-mcp-server = final.callPackage ./pkgs/kubectl-mcp-server { };
        markdown-to-confluence =
          final.callPackage ./pkgs/python-packages/markdown-to-confluence {
            inherit (final) json-strong-typing;
          };
        mcp-atlassian = final.callPackage ./pkgs/mcp-atlassian {
          inherit (final) markdown-to-confluence fastmcp;
        };
        mcp-server-git = final.callPackage ./pkgs/mcp-server-git { };
        mcp-server-github = final.callPackage ./pkgs/mcp-server-github { };
        mcp-server-memory = final.callPackage ./pkgs/mcp-server-memory { };
        mcp-server-sequential-thinking = final.callPackage ./pkgs/mcp-server-sequential-thinking { };
        smithy-cli = final.callPackage ./pkgs/smithy { };
        goose = final.callPackage ./pkgs/goose { };
      };
    };
}
