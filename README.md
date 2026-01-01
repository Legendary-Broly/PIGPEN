# PIGPEN

## Overview
PIGPEN is a Unity project repository kept lean through Git LFS and automated hygiene checks. CI enforces formatting, YAML quality, Unity asset metadata integrity, and Large File Storage (LFS) coverage so the project stays ready for contributors and automated builds.

## Git LFS requirements
This repository uses [Git LFS](https://git-lfs.com/) for large Unity assets to keep clone sizes manageable and satisfy CI validation. The `.gitattributes` file already tracks common binary assets such as textures (`.png`, `.jpg`, `.psd`, `.tga`, `.tif`), audio (`.wav`, `.mp3`, `.ogg`, `.aif`), 3D assets (`.fbx`, `.glb`, `.gltf`), videos (`.mp4`, `.mov`), prefabs, and Unity packages.

To enable LFS locally:

1. Install Git LFS for your platform (see the [installation guide](https://github.com/git-lfs/git-lfs#installation)).
2. Run `git lfs install` once per machine to activate the hooks.
3. After cloning, run `git lfs pull` (or `git pull`) to download LFS-managed assets.
4. When adding new binary assets covered by `.gitattributes`, commit them normally—LFS will store the binary contents automatically. If you introduce a new binary type, add it to `.gitattributes` before committing.

CI checks expect binary assets to be tracked by LFS. If a large asset is committed without LFS, push validation will fail until the file is added to LFS and recommitted.

## Local check command
Use the helper script to mirror the CI workflow locally:

```bash
bash scripts/run_ci_checks.sh
```

The script performs repository hygiene checks, YAML linting, `.csproj` restore and format verification, and LFS enforcement for common Unity binary asset types. Ensure you have:

- Git LFS installed and initialized.
- .NET 7 SDK available on your `PATH`.
- Python with `yamllint` installed (`python -m pip install --upgrade pip yamllint`).

### Quickstart by platform
- **Windows:** Run the command in Git Bash or Windows Subsystem for Linux (WSL) from the repository root: `bash scripts/run_ci_checks.sh`.
- **macOS:** In Terminal, execute `bash scripts/run_ci_checks.sh`. Install prerequisites via Homebrew (`brew install git-lfs dotnet-sdk python`) and `pip install yamllint`.
- **Linux:** From a shell, run `bash scripts/run_ci_checks.sh`. Install dependencies using your package manager (e.g., `apt` or `dnf`), then `pip install yamllint`.

## CI behavior
The GitHub Actions workflow `.github/workflows/ci.yml` runs on pull requests and executes:

1. Repository hygiene checks to prevent committing `Library/`, `Temp/`, `Obj/`, `Build/`, or `Builds/` directories and to verify Unity `.meta` files are paired with assets.
2. YAML linting with `yamllint`.
3. `dotnet restore` for all `.csproj` files at the repo root.
4. `dotnet format --verify-no-changes` for each project.
5. Git LFS validation for large binary asset extensions.
6. A placeholder step for future Unity static analysis.

## Recommended GitHub branch protection / ruleset settings
To keep the main branch healthy:

- Require pull requests before merging (no direct pushes).
- Block force pushes and branch deletions on protected branches.
- Require the `ci` status check to pass before merging.
- Enforce linear history (merge commits disabled) and signed commits if your organization prefers a stricter audit trail.
- Limit admin bypasses to keep the protections effective.
