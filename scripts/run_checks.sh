#!/usr/bin/env bash
set -euo pipefail

# Runs the same checks as the CI workflow from the repository root.
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

# Validate generated folders are absent
forbidden=(Library Temp Obj Build Builds)
found=0
for dir in "${forbidden[@]}"; do
  if [ -d "$dir" ]; then
    echo "Forbidden directory exists: $dir/"
    found=1
  fi
done

# Validate Unity .meta coverage
meta_bases=(Assets Packages)
meta_errors=0
for base in "${meta_bases[@]}"; do
  [ -d "$base" ] || continue

  while IFS= read -r path; do
    meta_file="${path}.meta"
    if [ ! -e "$meta_file" ]; then
      echo "Missing meta file for: $path"
      meta_errors=1
    fi
  done < <(find "$base" -type f ! -name '*.meta' -print)

  while IFS= read -r meta_file; do
    asset_path="${meta_file%.meta}"
    if [ ! -e "$asset_path" ]; then
      echo "Orphaned meta file: $meta_file"
      meta_errors=1
    fi
  done < <(find "$base" -type f -name '*.meta' -print)
done

if [ $found -ne 0 ] || [ $meta_errors -ne 0 ]; then
  echo "Repository hygiene checks failed."
  exit 1
fi

# Ensure gitleaks is available
if ! command -v gitleaks >/dev/null 2>&1; then
  cat <<'EOF'
gitleaks is not installed. Install it before running this script, for example:
  - macOS:   brew install gitleaks
  - Windows: winget install gitleaks.gitleaks (or download a release from GitHub)
  - Linux:   curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz | sudo tar -C /usr/local/bin -xz gitleaks
EOF
  exit 1
fi

# Secret scan
gitleaks detect --source . --no-banner --redact

# Ensure yamllint is available
if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint is not installed. Install it with 'python -m pip install --upgrade pip yamllint' before running this script."
  exit 1
fi

# YAML lint
yamllint .

# Collect projects
mapfile -t projects < <(find . -maxdepth 1 -name '*.csproj' -print)
if [ ${#projects[@]} -eq 0 ]; then
  echo "No C# projects found for restore/format."
  exit 0
fi

if [ -f PIGPEN.slnx ]; then
  echo "Restoring packages via PIGPEN.slnx"
  DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_PRINT_TELEMETRY_MESSAGE=0 DOTNET_NOLOGO=1 dotnet restore PIGPEN.slnx
  targets=(PIGPEN.slnx)
else
  echo "Restoring packages for ${#projects[@]} project(s)"
  DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_PRINT_TELEMETRY_MESSAGE=0 DOTNET_NOLOGO=1 dotnet restore "${projects[@]}"
  targets=("${projects[@]}")
fi

vulnerable=0
for target in "${targets[@]}"; do
  echo "Checking for vulnerable packages in $target"
  if ! report=$(DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_PRINT_TELEMETRY_MESSAGE=0 DOTNET_NOLOGO=1 dotnet list "$target" package --vulnerable --include-transitive --format json --no-restore); then
    echo "Failed to run vulnerability scan for $target"
    exit 1
  fi
  echo "$report"

  if python - <<'PY' <<<"$report"; then
import json
import sys

data = json.load(sys.stdin)

vulnerable_packages = []
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

if vulnerable_packages:
  print("Vulnerable packages detected:")
  for entry in vulnerable_packages:
    print(
      f"- {entry['project']} ({entry['framework']}): "
      f"{entry['package']}@{entry['version']} ({entry['count']} vulnerability/vulnerabilities)"
    )
  sys.exit(1)

print("No vulnerable packages detected.")
PY
  then
    :
  else
    vulnerable=1
  fi
done

if [ $vulnerable -ne 0 ]; then
  echo "Vulnerable packages detected."
  exit 1
fi

# Formatting verification
if [ -f PIGPEN.slnx ]; then
  echo "Checking formatting via PIGPEN.slnx"
  dotnet format PIGPEN.slnx --verify-no-changes --verbosity minimal --no-restore
elif [ ${#projects[@]} -eq 1 ]; then
  echo "Checking formatting for ${projects[0]}"
  dotnet format "${projects[0]}" --verify-no-changes --verbosity minimal --no-restore
else
  echo "Checking formatting for all projects in workspace"
  dotnet format --folder . --verify-no-changes --verbosity minimal --no-restore
fi

# Validate Git LFS usage
extensions=(png psd jpg jpeg tga tif tiff exr wav mp3 ogg fbx)
problem=0

while IFS= read -r file; do
  if stat --version >/dev/null 2>&1; then
    size=$(stat -c%s "$file")
  else
    size=$(stat -f%z "$file")
  fi

  if [ "$size" -lt 102400 ]; then
    continue
  fi

  if git check-attr filter -- "$file" | grep -q 'filter: lfs'; then
    continue
  fi

  echo "File should be tracked via Git LFS: $file (${size} bytes)"
  problem=1
done < <(git ls-files -- $(printf "*.%s " "${extensions[@]}"))

if [ $problem -ne 0 ]; then
  echo "Large binary assets must be tracked with Git LFS."
  exit 1
fi

echo "All checks passed."
