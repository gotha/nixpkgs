# NPM Package Management Rules

This rule describes how to build npm packages in this nixpkgs repository with maximum reproducibility.

## Package Building Strategy (Priority Order)

### 1. **buildNpmPackage (Preferred)**
Use `buildNpmPackage` for most npm packages as it provides the best reproducibility:

```nix
{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    hash = "sha256-...";
  };

  npmDepsHash = "sha256-...";  # Generated with prefetch-npm-deps
  
  # Use specific Node.js version if required
  nodejs = nodejs_18;  # or nodejs_20, etc.
  
  # Build configuration
  npmBuildScript = "build";  # Default, can be customized
  
  # Skip tests if they require network/credentials
  doCheck = false;
  
  meta = with lib; {
    description = "Package description";
    homepage = "https://github.com/owner/repo";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "binary-name";
  };
}
```

### 2. **Pre-built Binaries (try to avoid)**
Use pre-built packages only when `buildNpmPackage` fails due to complex dependency issues.

For packages with pre-built binaries, use `fetchurl` or `fetchzip`:

```nix
{ lib, stdenvNoCC, fetchzip, nodejs, makeWrapper }:

stdenvNoCC.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/package/-/package-${version}.tgz";
    hash = "sha256-...";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/node_modules/package
    cp -r . $out/lib/node_modules/package/

    makeWrapper ${nodejs}/bin/node $out/bin/package \
      --add-flags "$out/lib/node_modules/package/dist/index.js"
  '';
}
```

### 3. **node2nix (Last Resort)**
Use `node2nix` only when `buildNpmPackage` fails due to complex dependency issues:

```bash
# Generate node2nix files
nix-shell -p node2nix --run "node2nix -i node-packages.json -o node-packages.nix -c composition.nix"
```

```nix
# pkgs/node-packages/default.nix
{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs;
    inherit (pkgs) nodejs;
  };
in
nodePackages // {
  # Override specific packages if needed
  package-name = nodePackages.package-name.override {
    # Custom overrides
  };
}
```

## Reproducibility Best Practices

### Hash Management
1. **Always use specific hashes**: Never use `lib.fakeSha256` in production
2. **Generate npmDepsHash**: Use `prefetch-npm-deps` for `buildNpmPackage`
3. **Update hashes when versions change**: Automated with `nix-update` if available

```bash
# Generate npmDepsHash for buildNpmPackage
nix run nixpkgs#prefetch-npm-deps package-lock.json

# Or if you have the source
nix-build -A package-name.npmDeps 2>&1 | grep "got:" | cut -d' ' -f2
```

### Dependency Pinning
1. **Pin Node.js version**: Use specific nodejs version (nodejs_18, nodejs_20)
2. **Lock file inclusion**: Always include package-lock.json or yarn.lock
3. **Avoid global dependencies**: All deps should be declared in package.json

### Build Configuration
```nix
buildNpmPackage rec {
  # ... basic config ...

  # Reproducibility settings
  npmFlags = [ "--offline" "--ignore-scripts" ];

  # Custom build phase if needed
  buildPhase = ''
    runHook preBuild
    npm run build --offline
    runHook postBuild
  '';

  # Skip problematic lifecycle scripts
  npmConfigHook = ''
    npmConfigHook() {
      echo "registry=https://registry.npmjs.org/" > .npmrc
      echo "audit=false" >> .npmrc
      echo "fund=false" >> .npmrc
    }
  '';
}
```

## Common Patterns and Solutions

### Pattern 1: Simple CLI Tool
```nix
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "cli-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "cli-tool";
    rev = "v${version}";
    hash = "sha256-...";
  };

  npmDepsHash = "sha256-...";

  # Most CLI tools don't need a build step
  dontNpmBuild = true;

  meta = with lib; {
    description = "CLI tool description";
    homepage = "https://github.com/owner/cli-tool";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    mainProgram = "cli-tool";
  };
}
```

### Pattern 2: Package with Native Dependencies
```nix
{ lib, buildNpmPackage, fetchFromGitHub, python3, pkg-config, node-gyp }:

buildNpmPackage rec {
  pname = "native-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "native-package";
    rev = "v${version}";
    hash = "sha256-...";
  };

  npmDepsHash = "sha256-...";

  # Native build dependencies
  nativeBuildInputs = [ python3 pkg-config node-gyp ];

  # Allow npm scripts for native compilation
  npmFlags = [ "--ignore-scripts=false" ];

  # Set environment for native builds
  env = {
    PYTHON = "${python3}/bin/python";
  };
}
```

### Pattern 3: Monorepo Package
```nix
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "monorepo-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "monorepo";
    rev = "v${version}";
    hash = "sha256-...";
  };

  npmDepsHash = "sha256-...";

  # Build specific workspace
  npmWorkspace = "packages/specific-package";

  # Custom build script for monorepo
  npmBuildScript = "build:package";
}
```

## Troubleshooting Common Issues

### Issue 1: npmDepsHash Mismatch
```bash
# Fix hash mismatch by getting the correct hash
nix-build -A package-name 2>&1 | grep "got:" | cut -d' ' -f2

# Or use prefetch-npm-deps
nix run nixpkgs#prefetch-npm-deps package-lock.json
```

### Issue 2: Native Dependencies Failing
```nix
# Add required build tools
nativeBuildInputs = [
  python3
  pkg-config
  node-gyp
  makeWrapper
];

# Set environment variables
env = {
  PYTHON = "${python3}/bin/python";
  PKG_CONFIG_PATH = "${lib.makeSearchPath "lib/pkgconfig" buildInputs}";
};
```

### Issue 3: Scripts Not Running
```nix
# Allow specific scripts
npmFlags = [ "--ignore-scripts=false" ];

# Or run scripts manually in buildPhase
buildPhase = ''
  runHook preBuild
  npm run prepare
  npm run build
  runHook postBuild
'';
```

### Issue 4: Missing Binary
```nix
# Ensure binary is installed correctly
postInstall = ''
  # Create symlink if binary is in wrong location
  ln -s $out/lib/node_modules/package/bin/cli $out/bin/cli

  # Or use makeWrapper for complex setups
  makeWrapper $out/lib/node_modules/package/dist/cli.js $out/bin/cli \
    --prefix PATH : ${lib.makeBinPath [ nodejs ]}
'';
```

## Testing NPM Packages

### Build Test
```bash
# Test build
nix build .#package-name

# Test with verbose output
nix build .#package-name --print-build-logs
```

### Runtime Test
```bash
# Test execution
nix run .#package-name -- --help

# Test in clean environment
nix shell .#package-name --command package-name --version
```

### Reproducibility Test
```bash
# Build twice and compare
nix build .#package-name --rebuild
nix build .#package-name --rebuild
diff -r result result-2  # Should be identical
```

## Integration with Flake

Add npm packages to your flake.nix following the standard pattern:

```nix
packages = forAllSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    npm-package = pkgs.callPackage ./pkgs/npm-package { };
  });

apps = forAllSystems (system: {
  npm-package = {
    type = "app";
    program = "${self.packages.${system}.npm-package}/bin/npm-package";
  };
});

overlays.default = final: prev: {
  npm-package = final.callPackage ./pkgs/npm-package { };
};
```

## Best Practices Summary

1. **Always prefer `buildNpmPackage`** over other methods
2. **Use specific Node.js versions** (nodejs_18, nodejs_20)
3. **Generate proper hashes** with prefetch-npm-deps
4. **Include lock files** (package-lock.json, yarn.lock)
5. **Pin all dependencies** in package.json
6. **Test thoroughly** with nix build and nix run
7. **Document any special requirements** in meta.longDescription
8. **Use node2nix only as last resort** when buildNpmPackage fails
9. **Prefer upstream sources** over npm registry when possible
10. **Validate reproducibility** by building multiple times

### Hash Generation
```bash
# Generate source hash
nix-prefetch-github <owner> <repo> --rev v<version>

# Generate npmDepsHash
nix run nixpkgs#prefetch-npm-deps package-lock.json

# Or get hash from failed build
nix-build -A package-name 2>&1 | grep "got:" | cut -d' ' -f2
```
