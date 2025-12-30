# MCP Registry - Quick Start

## 🚀 Start the Registry

```bash
cd registry
make dev-compose
```

**Access at:** http://localhost:8080

---

## ⚙️ Basic Configuration

Edit `registry/docker-compose.yml`:

```yaml
environment:
  - MCP_REGISTRY_COMPANY_NAME=Your Company Name
  - MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg
```

---

## 📝 Add a New MCP Server

1. Edit `registry/data/seed.json`
2. Add your server definition:

```json
{
  "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
  "name": "com.example/my-server",
  "description": "My awesome MCP server",
  "repository": {
    "url": "https://github.com/user/repo",
    "source": "github"
  },
  "version": "1.0.0",
  "packages": [{
    "registryType": "npm",
    "identifier": "@user/package",
    "version": "1.0.0",
    "runtimeHint": "npx",
    "transport": {"type": "stdio"}
  }]
}
```

3. Restart: `make dev-down && make dev-compose`

---

## 🎨 Change Company Icon

```bash
# Copy your icon
cp /path/to/icon.svg registry/static/company-icon.svg

# Restart
make dev-down && make dev-compose
```

---

## 🛑 Stop the Registry

```bash
make dev-down
```

---

## 📖 Full Documentation

See [CUSTOM_SETUP.md](./CUSTOM_SETUP.md) for complete guide.
