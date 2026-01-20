# nixpkgs

collection of packages for nix

## Available Packages

- [context7-mcp](https://github.com/upstash/context7) - Up-to-date Code Docs For Any Prompt
- [gcloud-mcp](https://github.com/googleapis/gcloud-mcp) - Model Context Protocol server for Google Cloud Platform APIs
- [goose](https://github.com/block/goose) - An open source, extensible AI agent that goes beyond code suggestions
- [kubectl-mcp-server](https://github.com/rohitg00/kubectl-mcp-server): MCP server for Kubernetes
- [mcp-atlassian](https://github.com/sooperset/mcp-atlassian): MCP server for Atlassian tools (Confluence, Jira)
- [mcp-server-git](https://github.com/modelcontextprotocol/servers/tree/main/src/git): MCP server for Git repository interaction and automation
- [mcp-server-github](https://github.com/modelcontextprotocol/servers): MCP server for GitHub API integration (deprecated but functional)
- [mcp-server-memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory): MCP server for persistent memory through knowledge graph
- [mcp-server-playwright](https://github.com/microsoft/playwright-mcp): MCP server for browser automation via Playwright
- [mcp-server-sequential-thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking): MCP server for sequential thinking and problem solving
- [slack-mcp-server](https://github.com/korotovsky/slack-mcp-server): MCP server for Slack Workspaces with support for channels, DMs, threads, and search
- [redis-insight-bin](https://github.com/redis/RedisInsight) - Redis GUI for streamlined Redis application development
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
            (gotha.packages.${system}.goose)
            (gotha.packages.${system}.kubectl-mcp-server)
            (gotha.packages.${system}.mcp-atlassian)
            (gotha.packages.${system}.mcp-server-git)
            (gotha.packages.${system}.mcp-server-github)
            (gotha.packages.${system}.mcp-server-memory)
            (gotha.packages.${system}.mcp-server-playwright)
            (gotha.packages.${system}.mcp-server-sequential-thinking)
            (gotha.packages.${system}.slack-mcp-server)
            (gotha.packages.${system}.redis-insight-bin)
            (gotha.packages.${system}.smithy-cli)
          ];
        };
      });
    };
}
```
