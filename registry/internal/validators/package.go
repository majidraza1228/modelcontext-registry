package validators

import (
	"context"
	"fmt"

	"github.com/modelcontextprotocol/registry/internal/config"
	"github.com/modelcontextprotocol/registry/internal/validators/registries"
	"github.com/modelcontextprotocol/registry/pkg/model"
)

// ValidatePackage validates that the package referenced in the server configuration is:
// 1. allowed on the official registry (based on registry base url); and
// 2. owned by the publisher, by checking for a matching server name in the package metadata
func ValidatePackage(ctx context.Context, pkg model.Package, serverName string, cfg *config.Config) error {
	switch pkg.RegistryType {
	case model.RegistryTypeNPM:
		return registries.ValidateNPM(ctx, pkg, serverName, cfg)
	case model.RegistryTypePyPI:
		return registries.ValidatePyPI(ctx, pkg, serverName, cfg)
	case model.RegistryTypeNuGet:
		return registries.ValidateNuGet(ctx, pkg, serverName, cfg)
	case model.RegistryTypeOCI:
		return registries.ValidateOCI(ctx, pkg, serverName)
	case model.RegistryTypeMCPB:
		return registries.ValidateMCPB(ctx, pkg, serverName)
	default:
		return fmt.Errorf("unsupported registry type: %s", pkg.RegistryType)
	}
}
