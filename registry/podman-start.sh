#!/bin/bash
# Start MCP Registry using Podman (without podman-compose)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting MCP Registry with Podman...${NC}"

# Create a pod to group containers
echo -e "${YELLOW}Creating pod 'mcp-registry-pod'...${NC}"
podman pod create \
  --name mcp-registry-pod \
  -p 8081:8080 \
  -p 5434:5432 \
  2>/dev/null || echo "Pod already exists, continuing..."

# Start PostgreSQL container
echo -e "${YELLOW}Starting PostgreSQL container...${NC}"
podman run -d \
  --name postgres \
  --pod mcp-registry-pod \
  -e POSTGRES_DB=mcp-registry \
  -e POSTGRES_USER=mcpregistry \
  -e POSTGRES_PASSWORD=mcpregistry \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  --health-cmd "pg_isready -U mcpregistry -d mcp-registry" \
  --health-interval 1s \
  --health-retries 30 \
  --restart unless-stopped \
  postgres:16-alpine 2>/dev/null || echo "PostgreSQL container already exists, continuing..."

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
for i in {1..30}; do
  if podman exec postgres pg_isready -U mcpregistry -d mcp-registry >/dev/null 2>&1; then
    echo -e "${GREEN}PostgreSQL is ready!${NC}"
    break
  fi
  echo -n "."
  sleep 1
done
echo ""

# Build the registry image if needed
echo -e "${YELLOW}Checking if registry image needs to be built...${NC}"
if ! podman image exists ko.local/github.com/modelcontextprotocol/registry/cmd/registry:dev; then
  echo -e "${YELLOW}Building registry image with ko...${NC}"
  cd "$(dirname "$0")"
  export KO_DOCKER_REPO=ko.local
  ko build --preserve-import-paths --tags=dev --sbom=none ./cmd/registry
  echo -e "${GREEN}Image built successfully!${NC}"
fi

# Get absolute path to data and static directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
STATIC_DIR="${SCRIPT_DIR}/static"

# Start registry container
echo -e "${YELLOW}Starting registry container...${NC}"
podman run -d \
  --name registry \
  --pod mcp-registry-pod \
  -e MCP_REGISTRY_DATABASE_URL=postgres://mcpregistry:mcpregistry@localhost:5432/mcp-registry \
  -e MCP_REGISTRY_ENVIRONMENT=test \
  -e MCP_REGISTRY_GITHUB_CLIENT_ID=Iv23licy3GSiM9Km5jtd \
  -e MCP_REGISTRY_GITHUB_CLIENT_SECRET=0e8db54879b02c29adef51795586f3c510a9341d \
  -e MCP_REGISTRY_JWT_PRIVATE_KEY=8103179d8ef955f6d3de6d6217224a909ec4060529dfeb1d4ca5a994537658cd \
  -e MCP_REGISTRY_ENABLE_ANONYMOUS_AUTH=true \
  -e MCP_REGISTRY_SEED_FROM=data/seed.json \
  -e MCP_REGISTRY_OIDC_ENABLED=true \
  -e MCP_REGISTRY_OIDC_ISSUER=https://accounts.google.com \
  -e MCP_REGISTRY_OIDC_CLIENT_ID=32555940559.apps.googleusercontent.com \
  -e "MCP_REGISTRY_OIDC_EXTRA_CLAIMS=[{\"hd\":\"modelcontextprotocol.io\"}]" \
  -e MCP_REGISTRY_OIDC_EDIT_PERMISSIONS='*' \
  -e MCP_REGISTRY_OIDC_PUBLISH_PERMISSIONS='*' \
  -e MCP_REGISTRY_ENABLE_REGISTRY_VALIDATION=false \
  -e MCP_REGISTRY_CUSTOM_REGISTRY_NPM_URL=http://localhost:4873 \
  -e MCP_REGISTRY_CUSTOM_REGISTRY_PYPI_URL=http://localhost:8080 \
  -e MCP_REGISTRY_CUSTOM_REGISTRY_NUGET_URL=http://localhost:5000/v3/index.json \
  -e MCP_REGISTRY_COMPANY_NAME="${MCP_REGISTRY_COMPANY_NAME:-My Company}" \
  -e MCP_REGISTRY_COMPANY_ICON_PATH="${MCP_REGISTRY_COMPANY_ICON_PATH:-/static/company-icon.svg}" \
  -v "${DATA_DIR}:/data:ro,z" \
  -v "${STATIC_DIR}:/static:ro,z" \
  --restart unless-stopped \
  ko.local/github.com/modelcontextprotocol/registry/cmd/registry:dev 2>/dev/null || echo "Registry container already exists, continuing..."

# Wait for registry to be ready
echo -e "${YELLOW}Waiting for registry to be ready...${NC}"
for i in {1..30}; do
  if curl -s http://localhost:8081/v0/health >/dev/null 2>&1; then
    echo -e "${GREEN}Registry is ready!${NC}"
    break
  fi
  echo -n "."
  sleep 1
done
echo ""

# Show status
echo ""
echo -e "${GREEN}✅ MCP Registry is running!${NC}"
echo ""
echo -e "${BLUE}Access points:${NC}"
echo -e "  - Web UI:      ${GREEN}http://localhost:8081${NC}"
echo -e "  - API Docs:    ${GREEN}http://localhost:8081/docs${NC}"
echo -e "  - Health:      ${GREEN}http://localhost:8081/v0/health${NC}"
echo -e "  - PostgreSQL:  ${GREEN}localhost:5434${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  - View logs:       ${YELLOW}podman logs -f registry${NC}"
echo -e "  - Stop registry:   ${YELLOW}./podman-stop.sh${NC}"
echo -e "  - Pod status:      ${YELLOW}podman pod ps${NC}"
echo -e "  - Container list:  ${YELLOW}podman ps --pod${NC}"
echo ""
