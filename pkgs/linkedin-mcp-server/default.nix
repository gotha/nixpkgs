{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage rec {
  pname = "linkedin-mcp-server";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "felipfr";
    repo = "linkedin-mcpserver";
    rev = "v${version}";
    hash = "sha256-XTLNAcKpI1b1oLcOM7P8ca6ROyLAJQP8aEjAbShMjHA=";
  };

  npmDepsHash = "sha256-n1XS0Jbcs5zAJ8mmfgvavFqEChEZqt7Mm509kIV6sLI=";

  # The build script in package.json tries to use --env-file which doesn't work in nix
  # Also, the bin field points to index.js but the entry point is main.ts
  # The project uses baseUrl in tsconfig which causes import resolution issues after build
  postPatch = ''
    # Fix the build script to not require .env file and rename main.js to index.js
    ${nodejs}/bin/node -e "
      const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
      pkg.scripts.build = 'tsc && mv build/main.js build/index.js && chmod 755 build/index.js';
      require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "

    # Fix imports - the baseUrl paths don't work after compilation
    # Convert bare module paths to relative paths

    # src/main.ts
    substituteInPlace src/main.ts \
      --replace-fail "from 'container.js'" "from './container.js'" \
      --replace-fail "from 'utils/shutdown.utils.js'" "from './utils/shutdown.utils.js'"

    # src/container.ts
    substituteInPlace src/container.ts \
      --replace-fail "from 'auth/auth.config.js'" "from './auth/auth.config.js'" \
      --replace-fail "from 'server.js'" "from './server.js'" \
      --replace-fail "from 'services/client.service.js'" "from './services/client.service.js'" \
      --replace-fail "from 'services/logger.service.js'" "from './services/logger.service.js'" \
      --replace-fail "from 'services/metrics.service.js'" "from './services/metrics.service.js'" \
      --replace-fail "from 'services/token.service.js'" "from './services/token.service.js'"

    # src/auth/auth.config.ts
    substituteInPlace src/auth/auth.config.ts \
      --replace-fail "from 'schemas/env.schema.js'" "from '../schemas/env.schema.js'"

    # src/server.ts
    substituteInPlace src/server.ts \
      --replace-fail "from 'types/mcp.js'" "from './types/mcp.js'"

    # src/services/logger.service.ts
    substituteInPlace src/services/logger.service.ts \
      --replace-fail "from 'types/logger.js'" "from '../types/logger.js'"

    # src/services/client.service.ts
    substituteInPlace src/services/client.service.ts \
      --replace-fail "} from 'types/linkedin.js'" "} from '../types/linkedin.js'" \
      --replace-fail "from 'types/metrics.js'" "from '../types/metrics.js'"

    # src/services/metrics.service.ts
    substituteInPlace src/services/metrics.service.ts \
      --replace-fail "from 'types/metrics.js'" "from '../types/metrics.js'"

    # Remove pino-pretty transport from logger - MCP servers use stdio and should not format logs
    # Use standard pino JSON output to stderr instead
    sed -i '/transport: {/,/},$/d' src/services/logger.service.ts

    # Add support for LINKEDIN_ACCESS_TOKEN env var to skip OAuth flow
    # Patch the authenticate method to check for pre-configured token first
    substituteInPlace src/services/token.service.ts \
      --replace-fail "if (this.hasValidToken()) {" \
"// Check for pre-configured access token from environment
    if (!this.accessToken && process.env.LINKEDIN_ACCESS_TOKEN) {
      this.accessToken = process.env.LINKEDIN_ACCESS_TOKEN;
      this.tokenExpiry = Date.now() + 60 * 24 * 60 * 60 * 1000; // 60 days
      this.logger.info('Using pre-configured access token from LINKEDIN_ACCESS_TOKEN');
      return;
    }
    if (this.hasValidToken()) {"
  '';

  # Build the TypeScript source
  npmBuildScript = "build";

  # Skip tests as they are not included and would require API credentials
  doCheck = false;

  meta = with lib; {
    description = "A Model Context Protocol server for LinkedIn API integration";
    longDescription = ''
      LinkedIn MCP Server brings the power of the LinkedIn API to your AI assistants
      through the Model Context Protocol (MCP). This TypeScript server empowers AI
      agents to interact with LinkedIn data, search profiles, find jobs, and send
      messages.

      Features:
      - Profile Search - Find LinkedIn profiles with advanced filters
      - Profile Retrieval - Get detailed information about LinkedIn profiles
      - Job Search - Discover job opportunities with customized criteria
      - Messaging - Send messages to LinkedIn connections
      - Network Stats - Access connection statistics and analytics
      - TypeScript with dependency injection using TSyringe
      - Structured logging with Pino
      - Axios-powered API client with automatic token management
    '';
    homepage = "https://github.com/felipfr/linkedin-mcpserver";
    changelog = "https://github.com/felipfr/linkedin-mcpserver/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ gotha ];
    platforms = platforms.all;
    mainProgram = "linkedin-mcp-server";
  };
}

