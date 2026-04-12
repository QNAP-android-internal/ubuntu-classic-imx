#!/usr/bin/env python3
"""
Merge Syft-generated SBOM with proprietary components manifest.
Produces a single CycloneDX JSON containing all components.

Usage:
    python3 merge_sbom.py <syft_cdx.json> <proprietary_cdx.json> -o <merged_cdx.json>
"""

import argparse
import json
import sys
import uuid
from datetime import datetime, timezone


def load_json(path):
    with open(path, "r") as f:
        return json.load(f)


def merge(syft_sbom, proprietary_sbom):
    """Merge proprietary components into the Syft-generated SBOM."""
    merged = dict(syft_sbom)

    # Ensure components list exists
    if "components" not in merged:
        merged["components"] = []

    # Build a set of existing component keys for dedup
    existing = set()
    for comp in merged["components"]:
        key = (comp.get("name", ""), comp.get("version", ""))
        existing.add(key)

    # Add proprietary components that don't already exist
    added = 0
    for comp in proprietary_sbom.get("components", []):
        key = (comp.get("name", ""), comp.get("version", ""))
        if key not in existing:
            merged["components"].append(comp)
            existing.add(key)
            added += 1

    # Update metadata
    if "metadata" not in merged:
        merged["metadata"] = {}
    merged["metadata"]["timestamp"] = datetime.now(timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%SZ"
    )

    # Add a note about the merge
    if "properties" not in merged["metadata"]:
        merged["metadata"]["properties"] = []
    merged["metadata"]["properties"].append(
        {
            "name": "sbom:merge-info",
            "value": f"Merged {added} proprietary components from {proprietary_sbom.get('metadata', {}).get('component', {}).get('name', 'unknown')}",
        }
    )

    # Update serial number
    merged["serialNumber"] = f"urn:uuid:{uuid.uuid4()}"

    return merged


def main():
    parser = argparse.ArgumentParser(
        description="Merge Syft SBOM with proprietary components"
    )
    parser.add_argument("syft_sbom", help="Syft-generated CycloneDX JSON")
    parser.add_argument("proprietary_sbom", help="Proprietary components CycloneDX JSON")
    parser.add_argument(
        "-o", "--output", required=True, help="Output merged CycloneDX JSON"
    )
    args = parser.parse_args()

    syft = load_json(args.syft_sbom)
    proprietary = load_json(args.proprietary_sbom)
    merged = merge(syft, proprietary)

    with open(args.output, "w") as f:
        json.dump(merged, f, indent=2)

    total = len(merged.get("components", []))
    print(f"Merged SBOM written to {args.output} ({total} total components)")


if __name__ == "__main__":
    main()
