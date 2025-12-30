#!/bin/bash
# View logs for MCP Registry containers

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ "$1" = "postgres" ]; then
    echo -e "${BLUE}PostgreSQL logs:${NC}"
    podman logs -f postgres
elif [ "$1" = "registry" ]; then
    echo -e "${BLUE}Registry logs:${NC}"
    podman logs -f registry
else
    echo "Usage: $0 [registry|postgres]"
    echo ""
    echo "Examples:"
    echo "  $0 registry   # View registry logs"
    echo "  $0 postgres   # View PostgreSQL logs"
    exit 1
fi
