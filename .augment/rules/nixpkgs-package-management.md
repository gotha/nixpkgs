# Nixpkgs Package Management Rules

This rule describes how packages are organized and added in this nixpkgs repository.

## Package Organization Structure

### Directory Structure
```
pkgs/
├── <package-name>/                    # For standalone packages
│   └── default.nix
├── python-packages/                   # For Python packages
│   └── <package-name>/
│       └── default.nix
└── <language>-packages/              # For other language-specific packages
    └── <package-name>/
        └── default.nix
```

### Package Types and Builders
- **Python packages**: Use `python3.pkgs.buildPythonPackage` or `python3.pkgs.buildPythonApplication`
- **Node.js packages**: Use `buildNpmPackage`
- **Binary packages**: Use `stdenvNoCC.mkDerivation` with `fetchzip`
- **Source packages**: Use appropriate language-specific builders

## Flake.nix Integration

Every package must be integrated into `flake.nix` in THREE places:

### 1. Packages Section (lines 12-32)
```nix
packages = forAllSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    # Define dependencies first if needed
    dependency-name = pkgs.callPackage ./pkgs/path/to/dependency { };
  in {
    # Add your package here
    package-name = pkgs.callPackage ./pkgs/package-name { 
      inherit dependency-name;  # Pass dependencies if needed
    };
    # ... other packages
  });
```

### 2. Apps Section (lines 35-61)
```nix
apps = forAllSystems (system: {
  package-name = {
    type = "app";
    program = "${self.packages.${system}.package-name}/bin/binary-name";
  };
  # ... other apps
});
```

### 3. Overlays Section (lines 64-79)
```nix
overlays.default = final: prev: {
  package-name = final.callPackage ./pkgs/package-name { 
    inherit (final) dependency-name;  # Use final. for dependencies
  };
  # ... other packages
};
```

## Package Definition Template

### Basic Package Structure (default.nix)
```nix
{ lib, <builder-function>, <dependencies...> }:

<builder-function> rec {
  pname = "package-name";
  version = "x.y.z";
  
  src = <source-fetcher> {
    # Source configuration
  };
  
  # Builder-specific configuration
  # ...
  
  meta = with lib; {
    description = "Short description";
    longDescription = ''
      Detailed description explaining what the package does,
      its key features, and use cases.
    '';
    homepage = "https://github.com/owner/repo";
    changelog = "https://github.com/owner/repo/releases/tag/v${version}";
    license = licenses.<license-type>;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "binary-name";  # For applications
    platforms = platforms.all;    # or specific platforms
  };
}
```

## Adding a New Package - Step by Step

1. **Create package directory**: `mkdir -p pkgs/<package-name>` or `pkgs/<language>-packages/<package-name>`

2. **Write default.nix**: Follow the template above with appropriate builder and dependencies

3. **Update flake.nix** in all three sections:
   - Add to `packages` section with `callPackage`
   - Add to `apps` section if it's an executable
   - Add to `overlays.default` section

4. **Test the package**:
   ```bash
   nix build .#package-name
   nix run .#package-name  # if it's an app
   ```

5. **Update README.md**: Add the package to the Available Packages list

## Common Patterns

### Python Package Dependencies
- Use `inherit` to pass custom Python packages as dependencies
- Place Python packages in `pkgs/python-packages/`
- Use `dontCheckRuntimeDeps = true` if type stubs are missing

### Binary Packages
- Use `fetchzip` for pre-built binaries
- Use `makeWrapper` to set environment variables
- Support multiple architectures with conditional logic

### Source Dependencies
- Define dependencies in the `let` block before the main packages
- Use `inherit` to pass dependencies to packages
- In overlays, use `inherit (final)` to reference other overlay packages

## Naming Conventions
- Package names: lowercase with hyphens (e.g., `mcp-server-git`)
- Directory names: match package names exactly
- Binary names: can differ from package names (specify in `mainProgram`)

## Examples from Current Repository

### Python Application Example (mcp-atlassian)
```nix
{ lib, python3, markdown-to-confluence, fastmcp }:

python3.pkgs.buildPythonApplication rec {
  pname = "mcp-atlassian";
  version = "0.11.9";
  pyproject = true;

  src = python3.pkgs.fetchPypi {
    pname = "mcp_atlassian";
    inherit version;
    hash = "sha256-G6ahcbUpnlVNTg7/mCeedM3E6xwSyOYr6SQQPZzTjl4=";
  };

  build-system = with python3.pkgs; [ hatchling uv-dynamic-versioning ];

  dependencies = with python3.pkgs; [
    # Standard nixpkgs dependencies
    atlassian-python-api requests beautifulsoup4
    # Custom dependencies passed as arguments
    fastmcp markdown-to-confluence
  ];

  doCheck = false;  # Skip tests that require credentials

  meta = with lib; {
    description = "Model Context Protocol server for Atlassian tools";
    homepage = "https://github.com/sooperset/mcp-atlassian";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "mcp-atlassian";
  };
}
```

### Binary Package Example (smithy-cli)
```nix
{ lib, stdenvNoCC, fetchzip, makeWrapper, zulu17 }:

stdenvNoCC.mkDerivation (finalAttrs:
  let
    version = "1.61.0";
    assets = {
      "x86_64-linux" = {
        url = "https://github.com/smithy-lang/smithy/releases/download/${version}/smithy-cli-linux-x86_64.zip";
        hash = "sha256-535m0qmju+PvLlZm+XclcgG9eIj1uEmZupxMAjOnpAg=";
      };
      # ... other architectures
    };
    sys = stdenvNoCC.hostPlatform.system;
    asset = assets.${sys} or (throw "smithy-cli: unsupported system ${sys}");
  in {
    pname = "smithy-cli";
    inherit version;

    src = fetchzip {
      inherit (asset) url hash;
      stripRoot = true;
    };

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      # Install binary and libraries
      install -Dm555 bin/smithy -t $out/libexec/smithy/bin
      cp -r ./lib/* $out/libexec/smithy/lib

      # Create wrapper with Java on PATH
      makeWrapper $out/libexec/smithy/bin/smithy $out/bin/smithy \
        --prefix PATH : ${lib.makeBinPath [ zulu17 ]}
    '';

    meta = with lib; {
      description = "Command-line interface for the Smithy IDL";
      homepage = "https://github.com/smithy-lang/smithy";
      license = licenses.asl20;
      maintainers = with maintainers; [ gotha ];
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "smithy";
    };
  })
```

## Best Practices

### Security and Reliability
- Always specify exact version numbers and hashes
- Use `doCheck = false` only when tests require external resources
- Prefer `fetchPypi` over `fetchFromGitHub` for Python packages when available
- Use `dontCheckRuntimeDeps = true` sparingly, only for missing type stubs

### Dependencies
- Minimize custom dependencies - prefer packages already in nixpkgs
- Group related packages (e.g., Python packages in `python-packages/`)
- Use `inherit` pattern for passing custom dependencies
- Document missing dependencies in comments

### Metadata
- Always include comprehensive `meta` section
- Use `longDescription` for detailed explanations
- Include `homepage`, `changelog`, and `license`
- Set appropriate `platforms` (don't use `platforms.all` unless truly universal)
- Add yourself as maintainer: `maintainers = with maintainers; [ gotha ];`

### Testing
- Test package builds: `nix build .#package-name`
- Test applications: `nix run .#package-name -- --help`
- Verify overlays work: `nix build --override-input nixpkgs . .#package-name`

## Troubleshooting

### Common Issues
- **Hash mismatches**: Update hashes when versions change
- **Missing dependencies**: Check if they exist in nixpkgs first
- **Build failures**: Check if `doCheck = false` is needed
- **Runtime errors**: May need `dontCheckRuntimeDeps = true` for Python packages

### Debugging Commands
```bash
# Build with verbose output
nix build .#package-name --print-build-logs

# Enter development shell for debugging
nix develop .#package-name

# Check what's in the built package
nix path-info --recursive .#package-name
```
