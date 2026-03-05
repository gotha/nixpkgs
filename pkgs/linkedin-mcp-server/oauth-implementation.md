# LinkedIn 3-Legged OAuth Implementation

This document describes how to implement proper OAuth 2.0 Authorization Code Flow for the LinkedIn MCP Server.

## The Problem

LinkedIn does NOT support `client_credentials` grant type for standard developer applications.
You need to use the **Authorization Code Flow** which requires user interaction.

## Implementation Overview

### 1. New Environment Variables

```typescript
// src/schemas/env.schema.ts
import { z } from 'zod'

export const envSchema = z.object({
  LINKEDIN_CLIENT_ID: z.string().min(1),
  LINKEDIN_CLIENT_SECRET: z.string().min(1),
  // New: Optional pre-configured token (skip OAuth flow)
  LINKEDIN_ACCESS_TOKEN: z.string().optional(),
  LINKEDIN_REFRESH_TOKEN: z.string().optional(),
  // OAuth callback configuration
  LINKEDIN_REDIRECT_URI: z.string().default('http://localhost:3000/callback'),
  LINKEDIN_SCOPES: z.string().default('openid,profile,email,w_member_social'),
})
```

### 2. Modified Token Service

```typescript
// src/services/token.service.ts
import axios from 'axios'
import http from 'http'
import open from 'open'  // npm install open
import { URL } from 'url'
import crypto from 'crypto'

@injectable()
export class TokenService {
  private accessToken: string | null = null
  private refreshToken: string | null = null
  private tokenExpiry: number | null = null
  private readonly EXPIRY_THRESHOLD = 5 * 60 * 1000

  constructor(
    @inject(AuthConfig) private readonly config: AuthConfig,
    @inject(LoggerService) private readonly logger: LoggerService
  ) {
    // Check for pre-configured token
    if (process.env.LINKEDIN_ACCESS_TOKEN) {
      this.accessToken = process.env.LINKEDIN_ACCESS_TOKEN
      this.refreshToken = process.env.LINKEDIN_REFRESH_TOKEN || null
      this.tokenExpiry = Date.now() + 60 * 60 * 1000 // Assume 1 hour validity
      this.logger.info('Using pre-configured access token')
    }
  }

  public async authenticate(): Promise<void> {
    if (this.hasValidToken()) {
      return
    }

    if (this.refreshToken) {
      try {
        await this.refreshAccessToken()
        return
      } catch (error) {
        this.logger.warn('Token refresh failed, starting new OAuth flow')
      }
    }

    // Start OAuth Authorization Code flow
    await this.startOAuthFlow()
  }

  private async startOAuthFlow(): Promise<void> {
    const state = crypto.randomBytes(16).toString('hex')
    const redirectUri = this.config.getRedirectUri()
    const port = new URL(redirectUri).port || 3000

    // Build authorization URL
    const authUrl = new URL('https://www.linkedin.com/oauth/v2/authorization')
    authUrl.searchParams.set('response_type', 'code')
    authUrl.searchParams.set('client_id', this.config.getClientId())
    authUrl.searchParams.set('redirect_uri', redirectUri)
    authUrl.searchParams.set('state', state)
    authUrl.searchParams.set('scope', this.config.getScopes())

    this.logger.info('Starting OAuth flow. Opening browser...')
    this.logger.info(`If browser doesn't open, visit: ${authUrl.toString()}`)

    // Create temporary HTTP server to receive callback
    const code = await this.waitForAuthorizationCode(Number(port), state)
    
    // Exchange code for token
    await this.exchangeCodeForToken(code, redirectUri)
  }

  private waitForAuthorizationCode(port: number, expectedState: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const server = http.createServer((req, res) => {
        const url = new URL(req.url!, `http://localhost:${port}`)
        
        if (url.pathname === '/callback') {
          const code = url.searchParams.get('code')
          const state = url.searchParams.get('state')
          const error = url.searchParams.get('error')

          if (error) {
            res.writeHead(400, { 'Content-Type': 'text/html' })
            res.end(`<h1>Authorization Failed</h1><p>${error}</p>`)
            server.close()
            reject(new Error(`OAuth error: ${error}`))
            return
          }

          if (state !== expectedState) {
            res.writeHead(400, { 'Content-Type': 'text/html' })
            res.end('<h1>State Mismatch</h1><p>Possible CSRF attack.</p>')
            server.close()
            reject(new Error('State mismatch'))
            return
          }

          if (code) {
            res.writeHead(200, { 'Content-Type': 'text/html' })
            res.end('<h1>Success!</h1><p>You can close this window.</p>')
            server.close()
            resolve(code)
          }
        }
      })

      server.listen(port, () => {
        this.logger.info(`OAuth callback server listening on port ${port}`)
        // Open browser
        const authUrl = this.buildAuthUrl(expectedState)
        open(authUrl.toString()).catch(() => {
          this.logger.warn('Could not open browser automatically')
        })
      })

      // Timeout after 5 minutes
      setTimeout(() => {
        server.close()
        reject(new Error('OAuth timeout - no authorization received'))
      }, 5 * 60 * 1000)
    })
  }

  private async exchangeCodeForToken(code: string, redirectUri: string): Promise<void> {
    const response = await axios.post(
      'https://www.linkedin.com/oauth/v2/accessToken',
      new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        client_id: this.config.getClientId(),
        client_secret: this.config.getClientSecret(),
        redirect_uri: redirectUri,
      }),
      {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      }
    )

    this.accessToken = response.data.access_token
    this.refreshToken = response.data.refresh_token
    this.tokenExpiry = Date.now() + response.data.expires_in * 1000

    this.logger.info('Successfully obtained access token')
    this.logger.info(`Token expires in ${response.data.expires_in} seconds`)
    
    // Log tokens so user can save them for future use
    this.logger.info('Save these for future use:')
    this.logger.info(`LINKEDIN_ACCESS_TOKEN=${this.accessToken}`)
    if (this.refreshToken) {
      this.logger.info(`LINKEDIN_REFRESH_TOKEN=${this.refreshToken}`)
    }
  }
}
```

## Usage

### Option 1: First-time OAuth Flow

```bash
export LINKEDIN_CLIENT_ID="your-client-id"
export LINKEDIN_CLIENT_SECRET="your-client-secret"
linkedin-mcp-server
# Browser opens -> Login -> Authorize -> Token obtained
```

### Option 2: With Pre-configured Token

```bash
export LINKEDIN_CLIENT_ID="your-client-id"
export LINKEDIN_CLIENT_SECRET="your-client-secret"
export LINKEDIN_ACCESS_TOKEN="your-saved-access-token"
export LINKEDIN_REFRESH_TOKEN="your-saved-refresh-token"
linkedin-mcp-server
```

## LinkedIn App Configuration

In your LinkedIn Developer App settings:

1. Go to https://www.linkedin.com/developers/apps
2. Select your app -> Auth tab
3. Add `http://localhost:3000/callback` to "Authorized redirect URLs"
4. Request the following OAuth 2.0 scopes:
   - `openid`
   - `profile`
   - `email`
   - `w_member_social` (for messaging)

## Required npm Dependencies

```bash
npm install open
```

