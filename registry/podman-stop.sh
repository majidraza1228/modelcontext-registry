#!/bin/bash
# Stop MCP Registry (Podman without podman-compose)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Stopping MCP Registry...${NC}"

# Stop and remove containers
echo -e "${YELLOW}Stopping containers...${NC}"
podman stop registry 2>/dev/null || echo "Registry container already stopped"
podman stop postgres 2>/dev/null || echo "PostgreSQL container already stopped"

echo -e "${YELLOW}Removing containers...${NC}"
podman rm registry 2>/dev/null || echo "Registry container already removed"
podman rm postgres 2>/dev/null || echo "PostgreSQL container already removed"

# Remove pod
echo -e "${YELLOW}Removing pod...${NC}"
podman pod rm mcp-registry-pod 2>/dev/null || echo "Pod already removed"

echo -e "${GREEN}✅ MCP Registry stopped!${NC}"
