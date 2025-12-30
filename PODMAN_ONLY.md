# Running with Podman Only (No podman-compose)

If you prefer to use native Podman commands without installing podman-compose, use the provided shell scripts.

## Prerequisites

- **Podman** (version 4.0+)
- **Go** (version 1.24.x)
- **ko** - Container image builder for Go

```bash
# macOS
brew install podman go

# Linux (Ubuntu/Debian)
sudo apt-get install podman golang-go

# Install ko
go install github.com/google/ko@latest
export PATH=$PATH:$(go env GOPATH)/bin
```

## Quick Start

### 1. Start the Registry

```bash
cd registry
./podman-start.sh
```

This script will:
- Create a Podman pod named `mcp-registry-pod`
- Start PostgreSQL container
- Build the registry image with ko (if needed)
- Start the registry container
- Wait for everything to be ready

### 2. Access the Registry

- **Web UI**: http://localhost:8081
- **API Docs**: http://localhost:8081/docs
- **Health Check**: http://localhost:8081/v0/health
- **PostgreSQL**: localhost:5434

### 3. Stop the Registry

```bash
./podman-stop.sh
```

This will stop and remove all containers and the pod.

## Useful Commands

### View Logs

```bash
# Registry logs
./podman-logs.sh registry

# PostgreSQL logs
./podman-logs.sh postgres

# Or use Podman directly
podman logs -f registry
podman logs -f postgres
```

### Check Status

```bash
# View pod status
podman pod ps

# View containers in the pod
podman ps --pod

# Check health
curl http://localhost:8081/v0/health
```

### Restart After Changes

```bash
# Stop everything
./podman-stop.sh

# Rebuild and start
cd registry
make ko-build
./podman-start.sh
```

## How It Works

### Podman Pod

The scripts use a **Podman pod** to group the containers together. This is similar to how docker-compose groups services:

- Pod name: `mcp-registry-pod`
- Containers share the same network namespace
- Port mappings are defined at the pod level

### Container Setup

**PostgreSQL Container:**
- Image: `postgres:16-alpine`
- Port: 5434 (external) → 5432 (internal)
- Health checks enabled
- Auto-restart enabled

**Registry Container:**
- Built with ko from source
- Port: 8081 (external) → 8080 (internal)
- Mounts:
  - `./data` → `/data` (seed data)
  - `./static` → `/static` (company icon)
- Auto-restart enabled

## Configuration

### Environment Variables

You can set environment variables before running the script:

```bash
export MCP_REGISTRY_COMPANY_NAME="Acme Corporation"
export MCP_REGISTRY_COMPANY_ICON_PATH="/static/acme-logo.svg"
./podman-start.sh
```

### Modify Scripts

Edit [podman-start.sh](podman-start.sh) to change configuration. All environment variables from docker-compose.yml are included in the script.

## Advantages of This Approach

1. **No Dependencies**: Only requires Podman, no need for podman-compose or Python
2. **Native Podman**: Uses Podman pods and native features
3. **Simple**: Easy to understand shell scripts
4. **Portable**: Works on any system with Podman installed

## Comparison: podman-compose vs Native Podman

| Feature | podman-compose | Native Podman (scripts) |
|---------|----------------|------------------------|
| Dependencies | Python, podman-compose | Only Podman |
| Configuration | docker-compose.yml | Shell scripts |
| Complexity | Medium | Simple |
| Flexibility | High | High |
| Portability | Needs Python | Shell only |

## Troubleshooting

### Port Already in Use

If ports 8081 or 5434 are in use, edit [podman-start.sh](podman-start.sh):

```bash
# Change these lines:
podman pod create \
  --name mcp-registry-pod \
  -p 3000:8080 \        # Change 8081 to 3000
  -p 5435:5432 \        # Change 5434 to 5435
```

### Containers Already Exist

If you get "container already exists" errors:

```bash
./podman-stop.sh
./podman-start.sh
```

### Image Build Fails

```bash
# Build manually
cd registry
export KO_DOCKER_REPO=ko.local
ko build --preserve-import-paths --tags=dev --sbom=none ./cmd/registry

# Then start
./podman-start.sh
```

### View What's Running

```bash
# See all pods
podman pod ps

# See all containers with their pod
podman ps --pod

# Detailed pod inspection
podman pod inspect mcp-registry-pod
```

## Advanced Usage

### Manual Container Management

If you prefer manual control:

```bash
# Create pod
podman pod create --name mcp-registry-pod -p 8081:8080 -p 5434:5432

# Start PostgreSQL
podman run -d --name postgres --pod mcp-registry-pod \
  -e POSTGRES_DB=mcp-registry \
  -e POSTGRES_USER=mcpregistry \
  -e POSTGRES_PASSWORD=mcpregistry \
  postgres:16-alpine

# Start registry
podman run -d --name registry --pod mcp-registry-pod \
  -v ./data:/data:ro,z \
  -v ./static:/static:ro,z \
  -e MCP_REGISTRY_DATABASE_URL=postgres://mcpregistry:mcpregistry@localhost:5432/mcp-registry \
  ko.local/github.com/modelcontextprotocol/registry/cmd/registry:dev

# Stop everything
podman pod stop mcp-registry-pod

# Remove everything
podman pod rm -f mcp-registry-pod
```

### Using systemd (Auto-start on Boot)

Generate systemd service files:

```bash
cd registry

# Generate pod service
podman generate systemd --new --name mcp-registry-pod > ~/.config/systemd/user/mcp-registry-pod.service

# Enable and start
systemctl --user enable mcp-registry-pod
systemctl --user start mcp-registry-pod

# Check status
systemctl --user status mcp-registry-pod
```

## Files

- [podman-start.sh](podman-start.sh) - Start the registry with Podman
- [podman-stop.sh](podman-stop.sh) - Stop and clean up
- [podman-logs.sh](podman-logs.sh) - View container logs

## See Also

- [QUICK_START.md](../QUICK_START.md) - Quick start with podman-compose
- [CUSTOM_SETUP.md](../CUSTOM_SETUP.md) - Complete setup guide
- [PORT_CONFIGURATION.md](../PORT_CONFIGURATION.md) - Port configuration guide
