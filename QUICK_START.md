# MCP Registry - Quick Start Guide

Get your custom MCP Registry running in minutes!

---

## 📋 Prerequisites

Install Podman and required tools:

```bash
# macOS
brew install podman podman-compose go

# Linux (Ubuntu/Debian)
sudo apt-get install podman golang-go
pip3 install podman-compose

# Install Go tools (all platforms)
go install github.com/google/ko@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

---

## 🚀 Start the Registry

```bash
# Clone or navigate to the repository
cd registry

# Start the registry (builds and runs with Podman)
make dev-compose
```

**Access the registry at:** http://localhost:8080

**Important ports:**
- Web UI: http://localhost:8080
- PostgreSQL: localhost:5433 (external), 5432 (internal)

---

## ⚙️ Configuration

### Set Company Name

Edit `registry/docker-compose.yml` or create a `.env` file:

```yaml
environment:
  - MCP_REGISTRY_COMPANY_NAME=Your Company Name
  - MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg
```

Or create `registry/.env`:
```bash
MCP_REGISTRY_COMPANY_NAME=Acme Corporation
MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg
```

### Custom Package Registries

Configure custom NPM, PyPI, or NuGet registry URLs:

```yaml
environment:
  - MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://localhost:4873
  - MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://localhost:8080
  - MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://localhost:5000/v3/index.json
```

**After configuration changes:** Restart the registry
```bash
make dev-down && make dev-compose
```

---

## 📝 Add MCP Servers

### 1. Edit the Seed File

Open `registry/data/seed.json` and add your server:

```json
[
  {
    "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
    "name": "com.example/my-server",
    "description": "Description of your MCP server",
    "repository": {
      "url": "https://github.com/yourorg/your-repo",
      "source": "github"
    },
    "version": "1.0.0",
    "packages": [{
      "registryType": "npm",
      "identifier": "@yourorg/package-name",
      "version": "1.0.0",
      "runtimeHint": "npx",
      "transport": {"type": "stdio"},
      "environmentVariables": [{
        "name": "API_KEY",
        "description": "Your API key",
        "isRequired": true,
        "isSecret": true
      }]
    }]
  }
]
```

### 2. Package Types

**NPM Package:**
```json
{
  "registryType": "npm",
  "identifier": "@org/package",
  "version": "1.0.0",
  "runtimeHint": "npx",
  "transport": {"type": "stdio"}
}
```

**PyPI Package:**
```json
{
  "registryType": "pypi",
  "identifier": "package-name",
  "version": "1.0.0",
  "runtimeHint": "uvx",
  "transport": {"type": "stdio"}
}
```

**Docker/OCI Package:**
```json
{
  "registryType": "oci",
  "identifier": "docker.io/username/image:tag",
  "runtimeHint": "docker",
  "transport": {"type": "stdio"}
}
```

### 3. Restart to Apply Changes

```bash
make dev-down && make dev-compose
```

---

## 🎨 Customize Branding

### Change Company Icon

1. **Prepare your icon** (SVG recommended, or PNG/JPG)
   - Size: 64x64px or larger
   - Format: SVG, PNG, or JPG

2. **Replace the icon:**
   ```bash
   # For SVG (recommended)
   cp /path/to/your-logo.svg registry/static/company-icon.svg

   # For PNG
   cp /path/to/your-logo.png registry/static/company-icon.png
   ```

3. **Update configuration** (if using PNG):
   ```yaml
   environment:
     - MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.png
   ```

4. **Restart:**
   ```bash
   make dev-down && make dev-compose
   ```

---

## 🛑 Stop the Registry

```bash
make dev-down
```

---

## 🔍 Common Commands

```bash
# Start registry
make dev-compose

# Stop registry
make dev-down

# View logs
podman-compose logs -f

# View logs for specific service
podman-compose logs registry
podman-compose logs postgres

# Restart after code changes
make dev-down && make dev-compose

# Check health
curl http://localhost:8080/v0/health

# Run tests
make check
```

---

## 🐛 Troubleshooting

### Port Already in Use

If you see "port is already allocated":
```bash
# Edit registry/docker-compose.yml
# Change the port mapping:
ports:
  - "8081:8080"  # Change 8080 to any available port
```

### Registry Not Starting

```bash
# Check logs
podman-compose logs registry

# Check PostgreSQL
podman-compose logs postgres

# Rebuild from scratch
make clean
make dev-compose
```

### Seed Data Not Loading

```bash
# Validate JSON syntax
cat registry/data/seed.json | jq .

# Check for errors in logs
podman-compose logs registry | grep -i error
```

---

## 📖 Full Documentation

For comprehensive documentation, see:
- **[CUSTOM_SETUP.md](./CUSTOM_SETUP.md)** - Complete setup and configuration guide
- **API Reference**: http://localhost:8080/docs (when running)
- **Server JSON Schema**: `registry/docs/reference/server-json/`

---

## 🎯 What's Included

- ✅ **Podman-based** deployment (rootless, secure)
- ✅ **Configurable branding** (company name and icon)
- ✅ **Custom package registries** (NPM, PyPI, NuGet)
- ✅ **Seed data support** for pre-populating servers
- ✅ **PostgreSQL database** (port 5433 to avoid conflicts)
- ✅ **Complete API** for MCP server discovery

---

**Need help?** Check the [troubleshooting section](#-troubleshooting) or see the full [CUSTOM_SETUP.md](./CUSTOM_SETUP.md) guide.
