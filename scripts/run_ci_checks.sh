#!/usr/bin/env bash
set -euo pipefail

# Runs the same checks as .github/workflows/ci.yml.
# Must be executed from the repository root.

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

# Repository hygiene
forbidden=(Library Temp Obj Build Builds)
found=0
for dir in "${forbidden[@]}"; do
  if [ -d "$dir" ]; then
    echo "Forbidden directory exists: $dir/"
    found=1
  fi
done

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

yamllint_bin=$(command -v yamllint || true)
if [ -z "$yamllint_bin" ]; then
  echo "yamllint is not installed. Install it with 'python -m pip install --upgrade pip yamllint' before running this script."
  exit 1
fi

yamllint .

mapfile -t projects < <(find . -maxdepth 1 -name '*.csproj' -print)
if [ ${#projects[@]} -eq 0 ]; then
  echo "No C# projects found for restore/format."
  exit 0
fi

# Restore packages
DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet restore "${projects[@]}"

# Formatting verification
for project in "${projects[@]}"; do
  echo "Checking formatting for $project"
  dotnet format "$project" --verify-no-changes --verbosity minimal
done

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
