# LinkedIn MCP Server

A Model Context Protocol server for LinkedIn API integration.

## Prerequisites

### 1. Create a LinkedIn Developer App

1. Go to [LinkedIn Developer Portal](https://www.linkedin.com/developers/apps)
2. Click **"Create app"**
3. Fill in the required information:
   - App name
   - LinkedIn Page (create one if needed)
   - App logo
4. Accept the terms and create the app

### 2. Enable Required Products

In your app's **Products** tab, request access to:

| Product | Required | Scopes Granted |
|---------|----------|----------------|
| **Sign In with LinkedIn using OpenID Connect** | ✅ Yes | `openid`, `profile`, `email` |
| **Share on LinkedIn** | ✅ Yes | `w_member_social` |

> **Note:** Some products require approval which may take a few days.

### 3. Configure OAuth Redirect URI

In your app's **Auth** tab:
1. Under **OAuth 2.0 settings**, add a redirect URL:
   ```
   http://localhost:8089/callback
   ```
   (Use your preferred port)

### 4. Get Your Credentials

In the **Auth** tab, copy:
- **Client ID**
- **Client Secret** (click "eye" icon to reveal)

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LINKEDIN_CLIENT_ID` | Yes | Your LinkedIn app's Client ID |
| `LINKEDIN_CLIENT_SECRET` | Yes | Your LinkedIn app's Client Secret |
| `LINKEDIN_ACCESS_TOKEN` | Yes* | OAuth access token (see below) |

> *The access token is required because LinkedIn doesn't support `client_credentials` flow for standard apps.

## Getting an Access Token

LinkedIn requires the OAuth 2.0 Authorization Code flow (3-legged OAuth), which needs user interaction via browser.

### Using the Token Helper

```bash
# Set your credentials
export LINKEDIN_CLIENT_ID="your-client-id"
export LINKEDIN_CLIENT_SECRET="your-client-secret"

# Optional: customize port and scopes
export LINKEDIN_OAUTH_PORT=8089
export LINKEDIN_SCOPES="openid profile email w_member_social"

# Run the helper script
node get-token.mjs
```

This will:
1. Open your browser to LinkedIn's authorization page
2. You log in and authorize the app
3. The script captures the callback and exchanges the code for a token
4. Prints the token for you to use

### Token Lifetime

- **Access tokens** expire in **60 days**
- You'll need to regenerate the token after expiration

## Running the MCP Server

```bash
export LINKEDIN_CLIENT_ID="your-client-id"
export LINKEDIN_CLIENT_SECRET="your-client-secret"
export LINKEDIN_ACCESS_TOKEN="your-access-token"

linkedin-mcp-server
```

### MCP Client Configuration (Claude Desktop)

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "linkedin": {
      "command": "/path/to/linkedin-mcp-server",
      "env": {
        "LINKEDIN_CLIENT_ID": "your-client-id",
        "LINKEDIN_CLIENT_SECRET": "your-client-secret",
        "LINKEDIN_ACCESS_TOKEN": "your-access-token"
      }
    }
  }
}
```

## API Limitations

LinkedIn heavily restricts API access. With standard developer access, you can:

| Feature | Availability |
|---------|--------------|
| Get user info (`/v2/userinfo`) | ✅ Available |
| Get profile (`/v2/me`) | ✅ With "Share on LinkedIn" product |
| Search people | ❌ Partner API only |
| Search jobs | ❌ Partner API only |
| Send messages | ❌ Partner API only |

For full MCP server functionality, you need LinkedIn Partner Program access.

## Troubleshooting

### "invalid_scope_error"
- Enable the required products in your app's Products tab
- Regenerate your token after enabling new products

### "ACCESS_DENIED" / 403 errors
- Your token doesn't have the required scopes
- Request additional products and regenerate token

### "access_denied: This application is not allowed to create application tokens"
- You're missing `LINKEDIN_ACCESS_TOKEN`
- LinkedIn doesn't support `client_credentials` flow - use the token helper

## Links

- [LinkedIn Developer Portal](https://www.linkedin.com/developers/apps)
- [LinkedIn OAuth Documentation](https://learn.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow)
- [Upstream Project](https://github.com/felipfr/linkedin-mcpserver)

