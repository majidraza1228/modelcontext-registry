# Custom MCP Registry Setup Guide

This guide explains how to run, configure, and customize your MCP Registry.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Adding MCP Servers](#adding-mcp-servers)
- [Customizing Company Branding](#customizing-company-branding)
- [Using Podman Instead of Docker](#using-podman-instead-of-docker)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before running the MCP Registry, ensure you have:

- **Podman** (version 4.0+) and **podman-compose**
- **Go** (version 1.24.x)
- **ko** - Container image builder for Go ([installation](https://ko.build/install/))
- **golangci-lint** (v2.4.0 or later)

### Installing Prerequisites

```bash
# Install Podman and podman-compose
# macOS
brew install podman podman-compose

# Linux (Ubuntu/Debian)
sudo apt-get install podman
pip3 install podman-compose

# Install ko
go install github.com/google/ko@latest

# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Add Go bin to PATH
export PATH=$PATH:$(go env GOPATH)/bin
```

---

## Quick Start

1. **Clone and navigate to the registry directory:**
   ```bash
   cd /path/to/modelcontext-registry/registry
   ```

2. **Start the development environment:**
   ```bash
   make dev-compose
   ```

3. **Access the registry:**
   - **Web UI**: http://localhost:8080
   - **API Documentation**: http://localhost:8080/docs
   - **Health Check**: http://localhost:8080/v0/health

4. **Stop the registry:**
   ```bash
   make dev-down
   # OR
   podman-compose down
   ```

---

## Configuration

### Environment Variables

Configure the registry by setting environment variables in `docker-compose.yml` or creating a `.env` file:

```bash
# Company/Organization Settings
MCP_REGISTRY_COMPANY_NAME=Your Company Name
MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg

# Custom Package Registry URLs (optional)
MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://localhost:4873
MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://localhost:8080
MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://localhost:5000/v3/index.json

# Registry Settings
MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION=false  # Disable for local development
MCP_REGISTRY_SEED_FROM=data/seed.json          # Path to seed data file

# Database Settings
MCP_REGISTRY_DATABASE_URL=postgres://mcpregistry:mcpregistry@postgres:5432/mcp-registry

# Authentication (for development)
MCP_REGISTRY_ENABLE_ANONYMOUS_AUTH=true
```

### Configuration File Location

Edit configuration in: `registry/docker-compose.yml`

---

## Adding MCP Servers

### Seed File Structure

MCP servers are defined in `registry/data/seed.json`. Each server follows the MCP server schema.

### Example: Adding a New Server

1. **Open the seed file:**
   ```bash
   nano registry/data/seed.json
   ```

2. **Add your server definition:**

```json
[
  {
    "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
    "name": "com.yourcompany/your-server-name",
    "description": "Description of what your MCP server does",
    "repository": {
      "url": "https://github.com/yourorg/your-repo",
      "source": "github"
    },
    "version": "1.0.0",
    "packages": [
      {
        "registryType": "npm",
        "identifier": "@yourorg/your-package",
        "version": "1.0.0",
        "runtimeHint": "npx",
        "transport": {
          "type": "stdio"
        },
        "environmentVariables": [
          {
            "name": "API_KEY",
            "description": "Your API key description",
            "isRequired": true,
            "isSecret": true
          }
        ]
      }
    ]
  }
]
```

### Server Definition Fields

| Field | Required | Description |
|-------|----------|-------------|
| `$schema` | Yes | Schema version URL (use latest: 2025-12-11) |
| `name` | Yes | Server name in format: `domain.tld/server-name` |
| `description` | Yes | Brief description of the server |
| `repository.url` | Yes | GitHub/GitLab repository URL |
| `repository.source` | Yes | Source type (`github` or `gitlab`) |
| `version` | Yes | Specific version (not "latest") |
| `packages` | Yes | Array of package definitions |

### Package Types

#### NPM Package
```json
{
  "registryType": "npm",
  "identifier": "package-name",
  "version": "1.0.0",
  "runtimeHint": "npx",
  "transport": {
    "type": "stdio"
  }
}
```

#### PyPI Package
```json
{
  "registryType": "pypi",
  "identifier": "package-name",
  "version": "1.0.0",
  "runtimeHint": "uvx",
  "transport": {
    "type": "stdio"
  }
}
```

#### Docker/OCI Package
```json
{
  "registryType": "oci",
  "identifier": "docker.io/username/image:tag",
  "runtimeHint": "docker",
  "transport": {
    "type": "stdio"
  }
}
```

### Applying Changes

After modifying `seed.json`:

```bash
# Restart the registry to reload seed data
make dev-down
make dev-compose
```

**Note:** The database is ephemeral - it resets each time you restart, ensuring a clean state.

---

## Customizing Company Branding

### 1. Company Name

**Option A: Edit docker-compose.yml**
```yaml
environment:
  - MCP_REGISTRY_COMPANY_NAME=Your Company Name
```

**Option B: Create .env file**
```bash
echo "MCP_REGISTRY_COMPANY_NAME=Your Company Name" > .env
```

### 2. Company Icon

#### Using a Custom Icon

1. **Prepare your icon:**
   - Format: SVG, PNG, or JPG
   - Recommended size: 64x64 pixels or larger
   - Save as: `registry/static/company-icon.svg` (or `.png`)

2. **Replace the default icon:**
   ```bash
   # For SVG
   cp /path/to/your-icon.svg registry/static/company-icon.svg

   # For PNG
   cp /path/to/your-icon.png registry/static/company-icon.png
   ```

3. **Update the configuration (if using PNG):**
   ```yaml
   environment:
     - MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.png
   ```

4. **Restart the registry:**
   ```bash
   make dev-down
   make dev-compose
   ```

#### Icon Specifications

- **Format**: SVG (recommended), PNG, or JPG
- **Size**: 64x64px minimum (will be displayed at 64x64px)
- **Location**: `registry/static/` directory
- **Naming**: Any name, configured via `COMPANY_ICON_PATH`

### 3. Example Custom Branding

Create a file `registry/.env`:
```bash
MCP_REGISTRY_COMPANY_NAME=Acme Corporation
MCP_REGISTRY_COMPANY_ICON_PATH=/static/acme-logo.svg
```

Then restart:
```bash
make dev-down
make dev-compose
```

---

## Podman Benefits

This registry is configured to use Podman by default instead of Docker.

**Why Podman?**
- **Rootless by default**: More secure than Docker (no daemon running as root)
- **Daemonless**: No background service needed
- **Compatible**: Works with docker-compose.yml files via podman-compose
- **Drop-in replacement**: Same commands and workflow as Docker

The Makefile and all scripts have been configured to use `podman-compose` instead of `docker compose`. Everything works the same way - just run `make dev-compose` to start.

---

## Registry URLs and Ports

| Service | URL | Notes |
|---------|-----|-------|
| Web UI | http://localhost:8080 | Main registry interface |
| API v0 | http://localhost:8080/v0 | Legacy API endpoints |
| API v0.1 | http://localhost:8080/v0.1 | Current stable API |
| API Docs | http://localhost:8080/docs | OpenAPI documentation |
| Health | http://localhost:8080/v0/health | Health check endpoint |
| PostgreSQL | localhost:5433 | Database (mapped from 5432) |

**Note:** PostgreSQL is mapped to port 5433 to avoid conflicts with local PostgreSQL instances.

---

## Custom Package Registries

By default, the registry points to localhost-based package registries. You can customize these URLs:

### NPM Registry
```bash
MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://your-npm-registry:4873
```

### PyPI Registry
```bash
MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://your-pypi-registry:8080
```

### NuGet Registry
```bash
MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://your-nuget-registry:5000/v3/index.json
```

### Disabling Custom Registries

To use public registries instead, remove or comment out these variables:
```yaml
# MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=
# MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=
# MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=
```

---

## Development Workflow

### 1. Making Code Changes

```bash
# Make your changes to Go files, then rebuild
make dev-down
make dev-compose
```

### 2. Running Tests

```bash
# Run all checks (lint, validate, tests)
make check

# Run only unit tests
make test-unit

# Run integration tests
make test-integration
```

### 3. Linting

```bash
# Run linter
make lint

# Auto-fix linting issues
make lint-fix
```

### 4. Building Publisher CLI

```bash
# Build the mcp-publisher tool
make publisher

# Use it
./bin/mcp-publisher --help
```

---

## Troubleshooting

### Port Already in Use

**Problem:** Port 5432 is already allocated

**Solution:** The registry is configured to use port 5433. If you still have conflicts:

```yaml
# Edit docker-compose.yml
postgres:
  ports:
    - "5434:5432"  # Change to any available port
```

### Ko Build Errors

**Problem:** `ko: command not found`

**Solution:**
```bash
go install github.com/google/ko@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

### Registry Not Starting

**Problem:** Container fails to start

**Solution:**
```bash
# Check logs
podman-compose logs registry

# Check PostgreSQL
podman-compose logs postgres

# Rebuild from scratch
make clean
make dev-compose
```

### Static Files Not Loading

**Problem:** Company icon not showing

**Solution:**
```bash
# Check file exists
ls -la registry/static/company-icon.svg

# Check docker-compose.yml has volume mounted
# volumes:
#   - ./static:/static:ro

# Restart registry
make dev-down
make dev-compose
```

### Seed Data Not Loading

**Problem:** Servers not appearing

**Solution:**
```bash
# Validate seed.json syntax
cat registry/data/seed.json | jq .

# Check logs for validation errors
podman-compose logs registry | grep -i error

# Verify seed path in docker-compose.yml
# - MCP_REGISTRY_SEED_FROM=data/seed.json
```

---

## File Structure

```
registry/
├── data/
│   └── seed.json              # MCP server definitions
├── static/
│   └── company-icon.svg       # Company logo/icon
├── docker-compose.yml         # Docker configuration
├── .env.example               # Example environment variables
├── Makefile                   # Build and dev commands
└── internal/
    └── config/
        └── config.go          # Configuration definitions
```

---

## Additional Resources

- **MCP Registry Documentation**: [./docs](./docs)
- **Server.json Schema**: [./docs/reference/server-json](./docs/reference/server-json)
- **API Reference**: http://localhost:8080/docs (when running)
- **Publishing Guide**: [./docs/modelcontextprotocol-io/quickstart.mdx](./docs/modelcontextprotocol-io/quickstart.mdx)

---

## Support

For issues or questions:
1. Check the [troubleshooting](#troubleshooting) section
2. Review logs: `podman-compose logs`
3. See the main [README.md](./registry/README.md)
4. Open an issue on GitHub

---

## Quick Reference Commands

```bash
# Start registry
make dev-compose

# Stop registry
make dev-down

# View logs
podman-compose logs -f

# Rebuild after code changes
make dev-down && make dev-compose

# Run tests
make check

# Build publisher CLI
make publisher

# Clean build artifacts
make clean
```

---

---

## Configuration Reference

### All Environment Variables

Complete list of configuration options:

```bash
# Server Settings
MCP_REGISTRY_SERVER_ADDRESS=:8080
MCP_REGISTRY_DATABASE_URL=postgres://mcpregistry:mcpregistry@postgres:5432/mcp-registry

# Company Branding
MCP_REGISTRY_COMPANY_NAME=Your Company Name
MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg

# Custom Package Registries
MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://localhost:4873
MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://localhost:8080
MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://localhost:5000/v3/index.json

# Registry Settings
MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION=false
MCP_REGISTRY_SEED_FROM=data/seed.json

# Authentication (for development)
MCP_REGISTRY_ENABLE_ANONYMOUS_AUTH=true
MCP_REGISTRY_GITHUB_CLIENT_ID=your-github-client-id
MCP_REGISTRY_GITHUB_CLIENT_SECRET=your-github-client-secret
MCP_REGISTRY_JWT_PRIVATE_KEY=your-jwt-private-key

# OIDC Settings (optional)
MCP_REGISTRY_OIDC_ENABLED=true
MCP_REGISTRY_OIDC_ISSUER=https://accounts.google.com
MCP_REGISTRY_OIDC_CLIENT_ID=your-oidc-client-id
MCP_REGISTRY_OIDC_EXTRA_CLAIMS=[{"hd":"yourdomain.com"}]
MCP_REGISTRY_OIDC_EDIT_PERMISSIONS=*
MCP_REGISTRY_OIDC_PUBLISH_PERMISSIONS=*
```

### Environment Variable Priority

1. `.env` file in registry directory (highest priority)
2. Environment variables set in shell
3. `docker-compose.yml` environment section
4. Default values in code (lowest priority)

---

## Advanced Usage

### Using a Custom .env File

Create `registry/.env` instead of editing `docker-compose.yml`:

```bash
# Create .env file
cat > registry/.env <<EOF
MCP_REGISTRY_COMPANY_NAME=Acme Corporation
MCP_REGISTRY_COMPANY_ICON_PATH=/static/acme-logo.svg
MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=https://npm.acme.com
MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION=false
EOF

# Restart
make dev-down && make dev-compose
```

### Multiple Server Versions

You can add multiple versions of the same server to seed.json:

```json
[
  {
    "name": "com.example/my-server",
    "version": "1.0.0",
    "packages": [...]
  },
  {
    "name": "com.example/my-server",
    "version": "2.0.0",
    "packages": [...]
  }
]
```

The registry will show both versions, with users able to select which version to use.

### Environment Variables in Server Definitions

Define required environment variables for your MCP servers:

```json
{
  "packages": [{
    "environmentVariables": [
      {
        "name": "API_KEY",
        "description": "Your API key from https://example.com/keys",
        "isRequired": true,
        "isSecret": true
      },
      {
        "name": "LOG_LEVEL",
        "description": "Logging level (debug, info, warn, error)",
        "isRequired": false,
        "isSecret": false
      }
    ]
  }]
}
```

---

## Production Deployment

### Security Considerations

Before deploying to production:

1. **Change default credentials:**
   ```yaml
   POSTGRES_USER: your-secure-user
   POSTGRES_PASSWORD: your-secure-password
   MCP_REGISTRY_JWT_PRIVATE_KEY: generate-a-secure-key
   ```

2. **Enable registry validation:**
   ```yaml
   MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION: true
   ```

3. **Disable anonymous auth:**
   ```yaml
   MCP_REGISTRY_ENABLE_ANONYMOUS_AUTH: false
   ```

4. **Use external PostgreSQL:**
   ```yaml
   MCP_REGISTRY_DATABASE_URL: postgres://user:pass@your-db-host:5432/mcp-registry?sslmode=require
   ```

5. **Configure proper authentication** (GitHub OAuth or OIDC)

### Using External Databases

To use an external PostgreSQL database:

```yaml
environment:
  - MCP_REGISTRY_DATABASE_URL=postgres://user:password@external-host:5432/dbname?sslmode=require

# Remove or comment out the postgres service
# postgres:
#   ...
```

---

**Last Updated:** 2025-12-30
