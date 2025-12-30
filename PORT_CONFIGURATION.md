# Port Configuration Guide

This guide explains how to change the ports used by the MCP Registry.

## Current Default Ports

- **Registry Web UI/API**: `8080`
- **PostgreSQL**: `5433` (external) → `5432` (internal container port)

---

## Change Registry Port (Web UI/API)

### Option 1: Edit docker-compose.yml

**File:** `registry/docker-compose.yml`

Find the `registry` service section and change the port mapping:

```yaml
services:
  registry:
    ports:
      - "8080:8080"  # Change the FIRST number to your desired port
```

**Examples:**

```yaml
# Use port 3000
ports:
  - "3000:8080"

# Use port 8081
ports:
  - "8081:8080"

# Use port 9000
ports:
  - "9000:8080"
```

**Format:** `"HOST_PORT:CONTAINER_PORT"`
- **First number (HOST_PORT)**: The port on your computer (change this)
- **Second number (CONTAINER_PORT)**: The port inside the container (keep as `8080`)

### Option 2: Use Environment Variable

Create or edit `registry/.env`:

```bash
# This doesn't work directly with docker-compose ports,
# but you can override in docker-compose.yml like this:
```

Edit `registry/docker-compose.yml`:
```yaml
ports:
  - "${REGISTRY_PORT:-8080}:8080"
```

Then in `registry/.env`:
```bash
REGISTRY_PORT=3000
```

### After Changing the Port

1. **Stop the registry:**
   ```bash
   make dev-down
   ```

2. **Start with new port:**
   ```bash
   make dev-compose
   ```

3. **Access at new port:**
   ```bash
   # If you changed to port 3000:
   http://localhost:3000
   ```

---

## Change PostgreSQL Port

### Edit docker-compose.yml

**File:** `registry/docker-compose.yml`

Find the `postgres` service section:

```yaml
services:
  postgres:
    ports:
      - "5433:5432"  # Change the FIRST number
```

**Examples:**

```yaml
# Use port 5434
ports:
  - "5434:5432"

# Use port 5435
ports:
  - "5435:5432"

# Use default PostgreSQL port (if nothing else is using it)
ports:
  - "5432:5432"
```

**Important:** Only change the first number. The second number (`5432`) is the PostgreSQL default inside the container and should not be changed.

### After Changing PostgreSQL Port

1. **Stop the registry:**
   ```bash
   make dev-down
   ```

2. **Start with new port:**
   ```bash
   make dev-compose
   ```

3. **Connect to PostgreSQL:**
   ```bash
   # If you changed to port 5434:
   psql -h localhost -p 5434 -U mcpregistry -d mcp-registry
   ```

---

## Change Both Ports

Edit `registry/docker-compose.yml`:

```yaml
services:
  registry:
    ports:
      - "3000:8080"  # Registry on port 3000
    # ... rest of config ...

  postgres:
    ports:
      - "5434:5432"  # PostgreSQL on port 5434
    # ... rest of config ...
```

Then restart:
```bash
make dev-down && make dev-compose
```

Access:
- **Web UI**: http://localhost:3000
- **PostgreSQL**: `localhost:5434`

---

## Port Conflict Troubleshooting

### Error: "port is already allocated"

This means another service is using the port.

**Solution 1: Find what's using the port**

```bash
# macOS/Linux
lsof -i :8080

# Or check all Podman containers
podman ps
```

**Solution 2: Change to a different port**

Edit `registry/docker-compose.yml` and use a free port:

```yaml
ports:
  - "8081:8080"  # Try 8081
  # or
  - "9000:8080"  # or 9000
  # or
  - "3000:8080"  # or 3000
```

**Solution 3: Stop the conflicting service**

```bash
# Find and stop the service using the port
# For example, if another Podman container is using it:
podman stop <container-name>
```

---

## Common Port Configurations

### Development (Avoid Conflicts)

```yaml
services:
  registry:
    ports:
      - "8081:8080"  # Different from default
  postgres:
    ports:
      - "5434:5432"  # Different from default PostgreSQL
```

### Production (Standard Ports)

```yaml
services:
  registry:
    ports:
      - "80:8080"    # HTTP on port 80 (requires root/sudo)
      # or
      - "443:8080"   # HTTPS on port 443 (with reverse proxy)
  postgres:
    # Don't expose externally in production
    # Remove the ports section entirely
```

### Multiple Registries (Different Ports)

```yaml
# First registry
services:
  registry:
    ports:
      - "8080:8080"
  postgres:
    ports:
      - "5433:5432"

# Second registry (in different docker-compose.yml)
services:
  registry:
    ports:
      - "8081:8080"  # Different port
  postgres:
    ports:
      - "5434:5432"  # Different port
```

---

## Quick Reference

| What to Change | File | Line | Format |
|---|---|---|---|
| Registry Web/API Port | `registry/docker-compose.yml` | ~32 | `"YOUR_PORT:8080"` |
| PostgreSQL Port | `registry/docker-compose.yml` | ~51 | `"YOUR_PORT:5432"` |

**Remember:**
- Always change the **first number** (host port)
- Keep the **second number** (container port) unchanged
- Restart after changes: `make dev-down && make dev-compose`

---

## Examples

### Example 1: Change Registry to Port 3000

```bash
# 1. Edit registry/docker-compose.yml
# Change line ~32 from:
#   ports:
#     - "8080:8080"
# To:
#   ports:
#     - "3000:8080"

# 2. Restart
make dev-down
make dev-compose

# 3. Access
open http://localhost:3000
```

### Example 2: Change PostgreSQL to Port 5435

```bash
# 1. Edit registry/docker-compose.yml
# Change line ~51 from:
#   ports:
#     - "5433:5432"
# To:
#   ports:
#     - "5435:5432"

# 2. Restart
make dev-down
make dev-compose

# 3. Connect
psql -h localhost -p 5435 -U mcpregistry -d mcp-registry
```

### Example 3: Use Non-Standard Ports for Everything

```bash
# 1. Edit registry/docker-compose.yml
services:
  registry:
    ports:
      - "9090:8080"  # Web UI on 9090
  postgres:
    ports:
      - "9432:5432"  # PostgreSQL on 9432

# 2. Restart
make dev-down
make dev-compose

# 3. Access
# Web UI: http://localhost:9090
# PostgreSQL: localhost:9432
```

---

**Need Help?** See [QUICK_START.md](./QUICK_START.md#troubleshooting) for more troubleshooting tips.
