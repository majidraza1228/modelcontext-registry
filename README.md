# Custom MCP Registry

A customizable, self-hosted Model Context Protocol (MCP) server registry with company branding, custom package registries, and Podman support.

## ✨ Features

- 🏢 **Custom Branding** - Configure your company name and logo
- 📦 **Custom Package Registries** - Use your own NPM, PyPI, or NuGet registries
- 🔒 **Podman-based** - Secure, rootless container deployment
- 🎯 **Seed Data** - Pre-populate with your MCP servers
- 🌐 **Web UI** - Beautiful interface for discovering MCP servers
- 🔌 **Complete API** - RESTful API for programmatic access
- 🐘 **PostgreSQL** - Reliable database backend

## 🚀 Quick Start

**1. Install Prerequisites:**
```bash
# macOS
brew install podman podman-compose go

# Linux
sudo apt-get install podman golang-go
pip3 install podman-compose
```

**2. Install Go Tools:**
```bash
go install github.com/google/ko@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

**3. Start the Registry:**
```bash
cd registry
make dev-compose
```

**4. Access:**
- **Web UI**: http://localhost:8081
- **API Docs**: http://localhost:8081/docs
- **Health Check**: http://localhost:8081/v0/health

## 📖 Documentation

- **[QUICK_START.md](./QUICK_START.md)** - Get started in 5 minutes
- **[CUSTOM_SETUP.md](./CUSTOM_SETUP.md)** - Complete configuration guide
- **[PORT_CONFIGURATION.md](./PORT_CONFIGURATION.md)** - Change registry and database ports

## ⚙️ Configuration

### Company Branding

Edit `registry/docker-compose.yml`:

```yaml
environment:
  - MCP_REGISTRY_COMPANY_NAME=Your Company Name
  - MCP_REGISTRY_COMPANY_ICON_PATH=/static/company-icon.svg
```

### Custom Package Registries

Point to your own package registries:

```yaml
environment:
  - MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://localhost:4873
  - MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://localhost:8080
  - MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://localhost:5000/v3/index.json
```

### Add MCP Servers

Edit `registry/data/seed.json`:

```json
[
  {
    "$schema": "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json",
    "name": "com.example/my-server",
    "description": "My MCP server",
    "repository": {
      "url": "https://github.com/yourorg/repo",
      "source": "github"
    },
    "version": "1.0.0",
    "packages": [{
      "registryType": "npm",
      "identifier": "@yourorg/package",
      "version": "1.0.0",
      "runtimeHint": "npx",
      "transport": {"type": "stdio"}
    }]
  }
]
```

## 🎨 Customization

### Change Company Icon

```bash
# Copy your SVG icon
cp /path/to/logo.svg registry/static/company-icon.svg

# Restart
make dev-down && make dev-compose
```

### Use .env File

Create `registry/.env` instead of editing docker-compose.yml:

```bash
MCP_REGISTRY_COMPANY_NAME=Acme Corporation
MCP_REGISTRY_COMPANY_ICON_PATH=/static/acme-logo.svg
MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=https://npm.acme.com
```

## 🔧 Common Commands

```bash
# Start registry
make dev-compose

# Stop registry
make dev-down

# View logs
podman-compose logs -f

# Restart after changes
make dev-down && make dev-compose

# Run tests
make check

# Build publisher CLI
make publisher
```

## 📦 What's Inside

```
.
├── QUICK_START.md           # Quick start guide
├── CUSTOM_SETUP.md          # Detailed setup documentation
├── README.md                # This file
└── registry/
    ├── Makefile             # Build and dev commands
    ├── docker-compose.yml   # Podman/Docker configuration
    ├── data/
    │   └── seed.json        # MCP server definitions
    ├── static/
    │   └── company-icon.svg # Company logo
    ├── internal/            # Go application code
    ├── cmd/
    │   ├── registry/        # Registry server
    │   └── publisher/       # Publishing CLI tool
    └── docs/                # Additional documentation
```

## 🐛 Troubleshooting

### Port Already in Use

```bash
# Edit registry/docker-compose.yml and change:
ports:
  - "8081:8080"  # Change first port to any available port
```

See **[PORT_CONFIGURATION.md](./PORT_CONFIGURATION.md)** for detailed port configuration guide.

### Registry Not Starting

```bash
# Check logs
podman-compose logs registry

# Rebuild
make clean && make dev-compose
```

### Seed Data Issues

```bash
# Validate JSON
cat registry/data/seed.json | jq .

# Check logs
podman-compose logs registry | grep -i error
```

## 🔒 Production Deployment

For production deployments:

1. **Change default credentials** in docker-compose.yml
2. **Enable registry validation**: `MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION=true`
3. **Disable anonymous auth**: `MCP_REGISTRY_ENABLE_ANONYMOUS_AUTH=false`
4. **Use external database** instead of containerized PostgreSQL
5. **Configure proper authentication** (GitHub OAuth or OIDC)

See [CUSTOM_SETUP.md](./CUSTOM_SETUP.md#production-deployment) for details.

## 🏗️ Architecture

- **Language**: Go 1.24+
- **Database**: PostgreSQL 16
- **Container Runtime**: Podman (or Docker)
- **Build Tool**: ko (container image builder)
- **API**: RESTful (OpenAPI documented)
- **Frontend**: HTML + Tailwind CSS

## 📊 API Endpoints

- `GET /v0.1/servers` - List MCP servers
- `GET /v0.1/servers/{name}` - Get server details
- `POST /v0.1/servers` - Publish new server (requires auth)
- `PUT /v0.1/servers/{name}` - Update server (requires auth)
- `GET /v0.1/version` - Get registry version
- `GET /v0/health` - Health check

Full API documentation: http://localhost:8080/docs

## 🤝 Contributing

This is a customized fork of the official MCP Registry. For the upstream project:
- GitHub: https://github.com/modelcontextprotocol/registry

## 📄 License

See [registry/LICENSE](./registry/LICENSE) for details.

## 🆘 Support

1. Check [QUICK_START.md](./QUICK_START.md#-troubleshooting)
2. Review [CUSTOM_SETUP.md](./CUSTOM_SETUP.md#troubleshooting)
3. Check logs: `podman-compose logs -f`
4. Open an issue on GitHub

---

**Built with** the [Model Context Protocol Registry](https://github.com/modelcontextprotocol/registry) | **Powered by** Podman & Go
