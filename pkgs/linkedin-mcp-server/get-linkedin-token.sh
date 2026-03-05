#!/usr/bin/env bash
# LinkedIn OAuth 2.0 Token Helper
# This script helps you obtain a LinkedIn access token using the Authorization Code flow

set -e

# Configuration
CLIENT_ID="${LINKEDIN_CLIENT_ID:-}"
CLIENT_SECRET="${LINKEDIN_CLIENT_SECRET:-}"
REDIRECT_URI="http://localhost:3000/callback"
SCOPES="openid%20profile%20email"
PORT=3000

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo "Error: Please set LINKEDIN_CLIENT_ID and LINKEDIN_CLIENT_SECRET environment variables"
    echo ""
    echo "Usage:"
    echo "  export LINKEDIN_CLIENT_ID='your-client-id'"
    echo "  export LINKEDIN_CLIENT_SECRET='your-client-secret'"
    echo "  ./get-linkedin-token.sh"
    exit 1
fi

# Generate random state for CSRF protection
STATE=$(openssl rand -hex 16)

# Build authorization URL
AUTH_URL="https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&state=${STATE}&scope=${SCOPES}"

echo "============================================"
echo "LinkedIn OAuth 2.0 Token Helper"
echo "============================================"
echo ""
echo "Step 1: Opening browser for authorization..."
echo ""
echo "If the browser doesn't open, visit this URL manually:"
echo "$AUTH_URL"
echo ""

# Try to open browser
if command -v open &> /dev/null; then
    open "$AUTH_URL" &
elif command -v xdg-open &> /dev/null; then
    xdg-open "$AUTH_URL" &
fi

echo "Step 2: Waiting for callback on http://localhost:${PORT}/callback"
echo "        (Press Ctrl+C to cancel)"
echo ""

# Create a simple HTTP server to capture the callback
# Using netcat for simplicity
RESPONSE=$(mktemp)
FIFO=$(mktemp -u)
mkfifo "$FIFO"

cleanup() {
    rm -f "$RESPONSE" "$FIFO"
}
trap cleanup EXIT

# Start a simple server
{
    while true; do
        cat "$FIFO" | nc -l $PORT > "$RESPONSE" &
        NC_PID=$!
        
        # Wait for the response file to have content
        sleep 1
        
        if grep -q "GET /callback" "$RESPONSE" 2>/dev/null; then
            # Extract the code from the request
            CODE=$(grep "GET /callback" "$RESPONSE" | sed -n 's/.*code=\([^&]*\).*/\1/p')
            RETURNED_STATE=$(grep "GET /callback" "$RESPONSE" | sed -n 's/.*state=\([^ ]*\).*/\1/p' | tr -d '\r\n ')
            
            # Send success response
            echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<html><body><h1>Success!</h1><p>You can close this window.</p></body></html>" > "$FIFO"
            
            break
        fi
        
        # Send a response for other requests
        echo -e "HTTP/1.1 404 Not Found\r\n\r\nNot Found" > "$FIFO"
    done
} 2>/dev/null

if [ -z "$CODE" ]; then
    echo "Error: Failed to receive authorization code"
    exit 1
fi

echo "Step 3: Received authorization code!"
echo ""
echo "Step 4: Exchanging code for access token..."
echo ""

# Exchange code for token
TOKEN_RESPONSE=$(curl -s -X POST "https://www.linkedin.com/oauth/v2/accessToken" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=authorization_code" \
    -d "code=${CODE}" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "redirect_uri=${REDIRECT_URI}")

# Check for error
if echo "$TOKEN_RESPONSE" | grep -q "error"; then
    echo "Error getting token:"
    echo "$TOKEN_RESPONSE" | jq . 2>/dev/null || echo "$TOKEN_RESPONSE"
    exit 1
fi

# Extract tokens
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.refresh_token // empty')
EXPIRES_IN=$(echo "$TOKEN_RESPONSE" | jq -r '.expires_in')

echo "============================================"
echo "SUCCESS! Here are your tokens:"
echo "============================================"
echo ""
echo "Add these to your environment or MCP configuration:"
echo ""
echo "export LINKEDIN_ACCESS_TOKEN=\"${ACCESS_TOKEN}\""
if [ -n "$REFRESH_TOKEN" ]; then
    echo "export LINKEDIN_REFRESH_TOKEN=\"${REFRESH_TOKEN}\""
fi
echo ""
echo "Token expires in: ${EXPIRES_IN} seconds"
echo ""
echo "============================================"

