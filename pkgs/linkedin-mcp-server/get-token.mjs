#!/usr/bin/env node
/**
 * LinkedIn OAuth 2.0 Token Helper
 * 
 * This script helps you obtain a LinkedIn access token using the Authorization Code flow.
 * 
 * Usage:
 *   export LINKEDIN_CLIENT_ID="your-client-id"
 *   export LINKEDIN_CLIENT_SECRET="your-client-secret"
 *   node get-token.mjs
 */

import http from 'http';
import { URL } from 'url';
import { randomBytes } from 'crypto';
import { exec } from 'child_process';

const CLIENT_ID = process.env.LINKEDIN_CLIENT_ID;
const CLIENT_SECRET = process.env.LINKEDIN_CLIENT_SECRET;
const PORT = parseInt(process.env.LINKEDIN_OAUTH_PORT || '3000', 10);
const REDIRECT_URI = `http://localhost:${PORT}/callback`;
// Scopes can be customized via env var. Common scopes:
// - openid profile email (requires "Sign In with LinkedIn using OpenID Connect" product)
// - w_member_social (requires "Share on LinkedIn" product)
// - r_liteprofile r_emailaddress (legacy, deprecated)
const SCOPES = process.env.LINKEDIN_SCOPES || 'openid profile email';

if (!CLIENT_ID || !CLIENT_SECRET) {
  console.error('Error: Please set LINKEDIN_CLIENT_ID and LINKEDIN_CLIENT_SECRET');
  console.error('');
  console.error('Usage:');
  console.error('  export LINKEDIN_CLIENT_ID="your-client-id"');
  console.error('  export LINKEDIN_CLIENT_SECRET="your-client-secret"');
  console.error('  export LINKEDIN_OAUTH_PORT=3000              # optional, defaults to 3000');
  console.error('  export LINKEDIN_SCOPES="openid profile email" # optional, customize scopes');
  console.error('  node get-token.mjs');
  process.exit(1);
}

const state = randomBytes(16).toString('hex');

// Build authorization URL
const authUrl = new URL('https://www.linkedin.com/oauth/v2/authorization');
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('client_id', CLIENT_ID);
authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
authUrl.searchParams.set('state', state);
authUrl.searchParams.set('scope', SCOPES);

console.log('============================================');
console.log('LinkedIn OAuth 2.0 Token Helper');
console.log('============================================\n');
console.log('Opening browser for authorization...\n');
console.log('If browser does not open, visit this URL:');
console.log(authUrl.toString());
console.log('');

// Open browser
const openCmd = process.platform === 'darwin' ? 'open' : 
                process.platform === 'win32' ? 'start' : 'xdg-open';
exec(`${openCmd} "${authUrl.toString()}"`);

// Start server to receive callback
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  
  if (url.pathname !== '/callback') {
    res.writeHead(404);
    res.end('Not found');
    return;
  }

  const code = url.searchParams.get('code');
  const returnedState = url.searchParams.get('state');
  const error = url.searchParams.get('error');

  if (error) {
    res.writeHead(400, { 'Content-Type': 'text/html' });
    res.end(`<h1>Error</h1><p>${error}: ${url.searchParams.get('error_description')}</p>`);
    console.error(`OAuth Error: ${error}`);
    server.close();
    process.exit(1);
  }

  if (returnedState !== state) {
    res.writeHead(400, { 'Content-Type': 'text/html' });
    res.end('<h1>Error</h1><p>State mismatch - possible CSRF attack</p>');
    console.error('State mismatch');
    server.close();
    process.exit(1);
  }

  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end('<h1>Success!</h1><p>You can close this window. Check your terminal for the tokens.</p>');

  console.log('Received authorization code, exchanging for token...\n');

  // Exchange code for token
  try {
    const tokenResponse = await fetch('https://www.linkedin.com/oauth/v2/accessToken', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri: REDIRECT_URI,
      }),
    });

    const data = await tokenResponse.json();

    if (data.error) {
      console.error('Token exchange failed:', data);
      server.close();
      process.exit(1);
    }

    console.log('============================================');
    console.log('SUCCESS! Here are your tokens:');
    console.log('============================================\n');
    console.log('Add these to your environment:\n');
    console.log(`export LINKEDIN_ACCESS_TOKEN="${data.access_token}"`);
    if (data.refresh_token) {
      console.log(`export LINKEDIN_REFRESH_TOKEN="${data.refresh_token}"`);
    }
    console.log(`\nToken expires in: ${data.expires_in} seconds (${Math.round(data.expires_in/3600)} hours)`);
    console.log('\n============================================');

  } catch (err) {
    console.error('Failed to exchange code:', err);
  }

  server.close();
  process.exit(0);
});

server.listen(PORT, () => {
  console.log(`Waiting for callback on http://localhost:${PORT}/callback\n`);
  console.log('(Press Ctrl+C to cancel)\n');
});

// Timeout after 5 minutes
setTimeout(() => {
  console.error('Timeout: No authorization received after 5 minutes');
  server.close();
  process.exit(1);
}, 5 * 60 * 1000);

