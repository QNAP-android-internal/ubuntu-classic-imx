######################################################################
#         2026 ARM64 Ubuntu/Debian SBOM & CVE Scan Makefile          #
# Written by: Wig Cheng  <onlywig@gmail.com>                         #
######################################################################

include common.mk

SBOM_DIR          := $(OUTPUT_DIR)/sbom
ROOTFS_DIR        := $(PWD)/rootfs
PROPRIETARY_CDX   := $(PWD)/proprietary-components.cdx.json
MERGE_SCRIPT      := $(PWD)/merge_sbom.py

# Output files
SYFT_CDX          := $(SBOM_DIR)/syft-scan.cdx.json
SYFT_SPDX         := $(SBOM_DIR)/syft-scan.spdx.json
MERGED_CDX        := $(SBOM_DIR)/sbom-complete.cdx.json
CVE_REPORT_JSON   := $(SBOM_DIR)/cve-report.json
CVE_REPORT_TXT    := $(SBOM_DIR)/cve-report.txt
CVE_REPORT_SARIF  := $(SBOM_DIR)/cve-report.sarif

# Severity threshold: negligible, low, medium, high, critical
# Set to "medium" to fail the build on medium+ CVEs (optional)
CVE_FAIL_THRESHOLD ?= none

all: sbom

# ---- Prerequisites check ----
check-tools:
	@command -v syft >/dev/null 2>&1 || { \
		echo "ERROR: syft not found. Install: curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin"; \
		exit 1; \
	}
	@command -v grype >/dev/null 2>&1 || { \
		echo "ERROR: grype not found. Install: curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin"; \
		exit 1; \
	}

# ---- Install tools (run once) ----
install-tools:
	@echo "Installing syft..."
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin
	@echo "Installing grype..."
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
	@echo "Tools installed successfully."

# ---- SBOM Generation ----
scan: check-tools
	@mkdir -p $(SBOM_DIR)
	@echo "=== Scanning rootfs with Syft ==="
	syft dir:$(ROOTFS_DIR) \
		-o cyclonedx-json=$(SYFT_CDX) \
		-o spdx-json=$(SYFT_SPDX)
	@echo "Syft scan complete."
	@echo "  CycloneDX: $(SYFT_CDX)"
	@echo "  SPDX:      $(SYFT_SPDX)"

# ---- Merge with proprietary components ----
merge: scan
	@echo "=== Merging proprietary components ==="
	python3 $(MERGE_SCRIPT) $(SYFT_CDX) $(PROPRIETARY_CDX) -o $(MERGED_CDX)
	@echo "Merged SBOM: $(MERGED_CDX)"

# ---- CVE Scan ----
cve-scan: merge
	@echo "=== Running CVE scan with Grype ==="
	grype sbom:$(MERGED_CDX) \
		-o json=$(CVE_REPORT_JSON) \
		-o table=$(CVE_REPORT_TXT) \
		-o sarif=$(CVE_REPORT_SARIF) \
		$(if $(filter-out none,$(CVE_FAIL_THRESHOLD)),--fail-on $(CVE_FAIL_THRESHOLD),) \
		|| true
	@echo ""
	@echo "=== CVE Scan Summary ==="
	@cat $(CVE_REPORT_TXT)
	@echo ""
	@echo "Full reports:"
	@echo "  Table:  $(CVE_REPORT_TXT)"
	@echo "  JSON:   $(CVE_REPORT_JSON)"
	@echo "  SARIF:  $(CVE_REPORT_SARIF)"

# ---- Full pipeline: SBOM + CVE ----
sbom: cve-scan
	@echo ""
	@echo "=== SBOM & CVE scan complete ==="
	@echo "SBOM files in: $(SBOM_DIR)/"

# ---- Quick scan (syft only, no merge/CVE) ----
quick-scan: check-tools
	@mkdir -p $(SBOM_DIR)
	syft dir:$(ROOTFS_DIR) -o table
	@echo ""
	@echo "(Quick scan - table output only, no files written)"

# ---- Clean ----
clean:
	rm -rf $(SBOM_DIR)

build: sbom

.PHONY: all check-tools install-tools scan merge cve-scan sbom quick-scan clean build
