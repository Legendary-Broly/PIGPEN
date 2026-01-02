#!/usr/bin/env python3
"""Parse dotnet list --format json output for vulnerabilities."""

from __future__ import annotations

import json
import sys


def _collect_vulnerable_packages(data: dict) -> list[dict]:
    vulnerable_packages: list[dict] = []
    for project in data.get("projects", []):
        for framework in project.get("frameworks", []):
            for package_group in ("topLevelPackages", "transitivePackages"):
                for package in framework.get(package_group, []):
                    vulnerabilities = package.get("vulnerabilities", [])
                    if vulnerabilities:
                        vulnerable_packages.append(
                            {
                                "project": project.get("name"),
                                "framework": framework.get("framework"),
                                "package": package.get("name"),
                                "version": package.get("resolvedVersion"),
                                "count": len(vulnerabilities),
                            }
                        )
    return vulnerable_packages


def main() -> int:
    data = json.load(sys.stdin)

    vulnerable_packages = _collect_vulnerable_packages(data)
    if not vulnerable_packages:
        print("No vulnerable packages detected.")
        return 0

    print("Vulnerable packages detected:")
    for entry in vulnerable_packages:
        message = (
            f"- {entry['project']} ({entry['framework']}): "
            f"{entry['package']}@{entry['version']} "
            f"({entry['count']} vulnerability/vulnerabilities)"
        )
        print(message)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
