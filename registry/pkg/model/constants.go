package model

// Registry Types - supported package registry types
const (
	RegistryTypeNPM   = "npm"
	RegistryTypePyPI  = "pypi"
	RegistryTypeOCI   = "oci"
	RegistryTypeNuGet = "nuget"
	RegistryTypeMCPB  = "mcpb"
)

// Registry Base URLs - default package registry base URLs
const (
	DefaultRegistryURLNPM    = "https://registry.npmjs.org"
	DefaultRegistryURLPyPI   = "https://pypi.org"
	DefaultRegistryURLNuGet  = "https://api.nuget.org/v3/index.json"
	DefaultRegistryURLGitHub = "https://github.com"
	DefaultRegistryURLGitLab = "https://gitlab.com"
)

// Deprecated: Use DefaultRegistryURLNPM instead
const RegistryURLNPM = DefaultRegistryURLNPM

// Deprecated: Use DefaultRegistryURLPyPI instead
const RegistryURLPyPI = DefaultRegistryURLPyPI

// Deprecated: Use DefaultRegistryURLNuGet instead
const RegistryURLNuGet = DefaultRegistryURLNuGet

// Deprecated: Use DefaultRegistryURLGitHub instead
const RegistryURLGitHub = DefaultRegistryURLGitHub

// Deprecated: Use DefaultRegistryURLGitLab instead
const RegistryURLGitLab = DefaultRegistryURLGitLab

// Transport Types - supported remote transport protocols
const (
	TransportTypeStreamableHTTP = "streamable-http"
	TransportTypeSSE            = "sse"
	TransportTypeStdio          = "stdio"
)

// Runtime Hints - supported package runtime hints
const (
	RuntimeHintNPX    = "npx"
	RuntimeHintUVX    = "uvx"
	RuntimeHintDocker = "docker"
	RuntimeHintDNX    = "dnx"
)

// Schema versions
const (
	// CurrentSchemaVersion is the current supported schema version date
	CurrentSchemaVersion = "2025-12-11"
	// CurrentSchemaURL is the full URL to the current schema
	CurrentSchemaURL = "https://static.modelcontextprotocol.io/schemas/" + CurrentSchemaVersion + "/server.schema.json"
)
