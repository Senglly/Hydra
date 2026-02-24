# OAuth2 Client Setup for Hydra

## Creating an OAuth2 Client

An OAuth2 client represents your application that will receive tokens from Hydra.

### Using the Hydra Admin API

#### 1. Create a client via curl:

```bash
curl -X POST "http://hydra.railway.internal:4445/admin/clients" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "rexform",
    "client_name": "rexfrom_secret",
    "client_secret": "change-me-to-a-secure-secret",
    "grant_types": ["authorization_code", "refresh_token"],
    "response_types": ["code"],
    "redirect_uris": [
        "http://localhost:3000/callback",
        "https://gateway-production-6cac.up.railway.app/callback"
    ]
    "scope": "openid offline_access email profile",
    "token_endpoint_auth_method": "client_secret_post"
  }'
```

#### 2. For Railway deployment, use the public admin URL:

```bash
# Replace with your Hydra admin URL
HYDRA_ADMIN="https://hydra-production-a56f.up.railway.app"

curl -X POST "${HYDRA_ADMIN}/admin/clients" \
  -H "Content-Type: application/json" \
  -d '{ ... }'
```

### Using the Hydra CLI (if installed)

```bash
hydra clients create \
  --endpoint http://hydra.railway.internal:4445 \
  --id my-app \
  --secret my-super-secret-secret \
  --grant-types authorization_code,refresh_token \
  --response-types code \
  --scope openid,offline_access,email,profile \
  --callbacks http://localhost:3000/callback
```

## Client Configuration

### Important Fields:

- **client_id**: Unique identifier for your app (choose any string)
- **client_secret**: Secret password for your app (keep secure!)
- **grant_types**: How your app gets tokens
  - `authorization_code`: Standard OAuth2 flow (recommended)
  - `refresh_token`: Get new tokens without re-login
  - `client_credentials`: For server-to-server
- **redirect_uris**: Where Hydra sends users after login (must match exactly)
- **scope**: What permissions to request
  - `openid`: Required for OIDC
  - `offline_access`: Get refresh tokens
  - `email`: Get user's email
  - `profile`: Get user's profile info

### Security Settings:

- **skip_consent**: `false` = show consent screen, `true` = auto-accept (use true for trusted first-party apps)
- **token_endpoint_auth_method**:
  - `client_secret_post`: Send secret in POST body (recommended)
  - `client_secret_basic`: Send secret in Authorization header

## Testing the Flow

### 1. Start the authorization flow:

```
https://hydra-production-a56f.up.railway.app/oauth2/auth?client_id=my-app&response_type=code&scope=openid+email+profile&redirect_uri=http://localhost:3000/callback&state=random-state
```

### 2. Flow will:

- Check if you're logged in (via Kratos session)
- If not → redirect to Kratos login
- After login → redirect to consent
- After consent → redirect to your callback with `code`

### 3. Exchange code for tokens:

```bash
curl -X POST "https://hydra-production-a56f.up.railway.app/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=YOUR_CODE_HERE" \
  -d "redirect_uri=http://localhost:3000/callback" \
  -d "client_id=my-app" \
  -d "client_secret=my-super-secret-secret"
```

### 4. Response:

```json
{
  "access_token": "...",
  "id_token": "...",
  "refresh_token": "...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

## Managing Clients

### List all clients:

```bash
curl http://hydra.railway.internal:4445/admin/clients
```

### Get specific client:

```bash
curl http://hydra.railway.internal:4445/admin/clients/my-app
```

### Update client:

```bash
curl -X PUT "http://hydra.railway.internal:4445/admin/clients/my-app" \
  -H "Content-Type: application/json" \
  -d '{ "client_id": "my-app", ... }'
```

### Delete client:

```bash
curl -X DELETE "http://hydra.railway.internal:4445/admin/clients/my-app"
```

## Common Client Configurations

### 1. First-party web app (skip consent):

```json
{
  "client_id": "web-app",
  "skip_consent": true,
  "grant_types": ["authorization_code", "refresh_token"],
  "scope": "openid offline_access email profile"
}
```

### 2. Third-party app (show consent):

```json
{
  "client_id": "third-party-app",
  "skip_consent": false,
  "grant_types": ["authorization_code"],
  "scope": "openid email"
}
```

### 3. Mobile app (PKCE):

```json
{
  "client_id": "mobile-app",
  "token_endpoint_auth_method": "none",
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "scope": "openid offline_access email profile"
}
```

### 4. Server-to-server (no user):

```json
{
  "client_id": "backend-service",
  "grant_types": ["client_credentials"],
  "scope": "api.read api.write"
}
```
