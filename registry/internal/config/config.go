package config

import (
	env "github.com/caarlos0/env/v11"
	"github.com/modelcontextprotocol/registry/pkg/model"
)

// Config holds the application configuration
// See .env.example for more documentation
type Config struct {
	ServerAddress            string `env:"SERVER_ADDRESS" envDefault:":8080"`
	DatabaseURL              string `env:"DATABASE_URL" envDefault:"postgres://localhost:5432/mcp-registry?sslmode=disable"`
	SeedFrom                 string `env:"SEED_FROM" envDefault:""`
	Version                  string `env:"VERSION" envDefault:"dev"`
	GithubClientID           string `env:"GITHUB_CLIENT_ID" envDefault:""`
	GithubClientSecret       string `env:"GITHUB_CLIENT_SECRET" envDefault:""`
	JWTPrivateKey            string `env:"JWT_PRIVATE_KEY" envDefault:""`
	EnableAnonymousAuth      bool   `env:"ENABLE_ANONYMOUS_AUTH" envDefault:"false"`
	EnableRegistryValidation bool   `env:"ENABLE_REGISTRY_VALIDATION" envDefault:"true"`

	// OIDC Configuration
	OIDCEnabled      bool   `env:"OIDC_ENABLED" envDefault:"false"`
	OIDCIssuer       string `env:"OIDC_ISSUER" envDefault:""`
	OIDCClientID     string `env:"OIDC_CLIENT_ID" envDefault:""`
	OIDCExtraClaims  string `env:"OIDC_EXTRA_CLAIMS" envDefault:""`
	OIDCEditPerms    string `env:"OIDC_EDIT_PERMISSIONS" envDefault:""`
	OIDCPublishPerms string `env:"OIDC_PUBLISH_PERMISSIONS" envDefault:""`

	// Custom Registry Base URLs (optional overrides for default registry URLs)
	CustomRegistryNPMURL   string `env:"CUSTOM_REGISTRY_NPM_URL" envDefault:""`
	CustomRegistryPyPIURL  string `env:"CUSTOM_REGISTRY_PYPI_URL" envDefault:""`
	CustomRegistryNuGetURL string `env:"CUSTOM_REGISTRY_NUGET_URL" envDefault:""`

	// Company/Registry Name and Icon
	CompanyName     string `env:"COMPANY_NAME" envDefault:"Model Context Protocol"`
	CompanyIconPath string `env:"COMPANY_ICON_PATH" envDefault:"/static/company-icon.png"`
}

// GetRegistryNPMURL returns the NPM registry URL (custom or default)
func (c *Config) GetRegistryNPMURL() string {
	if c.CustomRegistryNPMURL != "" {
		return c.CustomRegistryNPMURL
	}
	return model.DefaultRegistryURLNPM
}

// GetRegistryPyPIURL returns the PyPI registry URL (custom or default)
func (c *Config) GetRegistryPyPIURL() string {
	if c.CustomRegistryPyPIURL != "" {
		return c.CustomRegistryPyPIURL
	}
	return model.DefaultRegistryURLPyPI
}

// GetRegistryNuGetURL returns the NuGet registry URL (custom or default)
func (c *Config) GetRegistryNuGetURL() string {
	if c.CustomRegistryNuGetURL != "" {
		return c.CustomRegistryNuGetURL
	}
	return model.DefaultRegistryURLNuGet
}

// NewConfig creates a new configuration with default values
func NewConfig() *Config {
	var cfg Config
	err := env.ParseWithOptions(&cfg, env.Options{
		Prefix: "MCP_REGISTRY_",
	})
	if err != nil {
		panic(err)
	}
	return &cfg
}
