# nixpkgs

collection of packages for nix

## Available Packages

- [context7-mcp](https://github.com/upstash/context7) - Up-to-date Code Docs For Any Prompt
- [gcloud-mcp](https://github.com/googleapis/gcloud-mcp) - Model Context Protocol server for Google Cloud Platform APIs
- [kubectl-mcp-server](https://github.com/rohitg00/kubectl-mcp-server): MCP server for Kubernetes
- [mcp-atlassian](https://github.com/sooperset/mcp-atlassian): MCP server for Atlassian tools (Confluence, Jira)
- [mcp-server-git](https://github.com/modelcontextprotocol/servers/tree/main/src/git): MCP server for Git repository interaction and automation
- [smithy](https://github.com/smithy-lang/smithy) - Command-line interface for the Smithy IDL and tooling

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
            (gotha.packages.${system}.gcloud-mcp)
            (gotha.packages.${system}.kubectl-mcp-server)
            (gotha.packages.${system}.mcp-atlassian)
            (gotha.packages.${system}.mcp-server-git)
            (gotha.packages.${system}.smithy-cli)
          ];
        };
      });
    };
}
```
