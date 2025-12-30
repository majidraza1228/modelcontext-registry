package v0

import (
	_ "embed"
	"strings"

	"github.com/modelcontextprotocol/registry/internal/config"
)

//go:embed ui_index.html
var embedUI string

// GetUIHTML returns the embedded HTML for the UI with configuration applied
func GetUIHTML(cfg *config.Config) string {
	html := embedUI
	// Replace company name placeholder
	companyName := cfg.CompanyName
	if companyName == "" {
		companyName = "Model Context Protocol"
	}
	html = strings.ReplaceAll(html, "{{COMPANY_NAME}}", companyName)
	return html
}
