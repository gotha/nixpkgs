# nixpkgs

collection of packages for nix

## Available Packages

- [auggie](https://augmentcode.com) - Auggie CLI Client by Augment Code
- [gcloud-mcp](https://github.com/googleapis/gcloud-mcp) - Model Context Protocol server for Google Cloud Platform APIs
- [kubectl-mcp-server](https://github.com/rohitg00/kubectl-mcp-server) - MCP server for Kubernetes
- [mcp-atlassian](https://github.com/sooperset/mcp-atlassian) - MCP server for Atlassian tools (Confluence, Jira)
- [redis-insight-bin](https://github.com/redis/RedisInsight) - Redis GUI for streamlined Redis application development

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
            (gotha.packages.${system}.auggie)
            (gotha.packages.${system}.gcloud-mcp)
            (gotha.packages.${system}.kubectl-mcp-server)
            (gotha.packages.${system}.mcp-atlassian)
            (gotha.packages.${system}.redis-insight-bin)
          ];
        };
      });
    };
}
```
