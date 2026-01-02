#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# Runs the same checks as the CI workflow from the repository root.
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

function Resolve-RelativePath([string]$path) {
    return (Resolve-Path -LiteralPath $path).MakeRelative($repoRoot)
}

$forbidden = @('Library', 'Temp', 'Obj', 'Build', 'Builds')
$found = $false
foreach ($dir in $forbidden) {
    if (Test-Path $dir) {
        Write-Output "Forbidden directory exists: $dir/"
        $found = $true
    }
}

$metaBases = @('Assets', 'Packages')
$metaErrors = $false
foreach ($base in $metaBases) {
    if (-not (Test-Path $base)) { continue }

    Get-ChildItem -Path $base -Recurse -File | Where-Object { $_.Extension -ne '.meta' } | ForEach-Object {
        $metaFile = "$($_.FullName).meta"
        if (-not (Test-Path -LiteralPath $metaFile)) {
            Write-Output "Missing meta file for: $(Resolve-RelativePath $_.FullName)"
            $metaErrors = $true
        }
    }

    Get-ChildItem -Path $base -Recurse -File -Filter '*.meta' | ForEach-Object {
        $assetPath = $_.FullName.Substring(0, $_.FullName.Length - 5)
        if (-not (Test-Path -LiteralPath $assetPath)) {
            Write-Output "Orphaned meta file: $(Resolve-RelativePath $_.FullName)"
            $metaErrors = $true
        }
    }
}

if ($found -or $metaErrors) {
    throw 'Repository hygiene checks failed.'
}

if (-not (Get-Command yamllint -ErrorAction SilentlyContinue)) {
    throw "yamllint is not installed. Install it with 'python -m pip install --upgrade pip yamllint' before running this script."
}

yamllint .

$projects = Get-ChildItem -Path . -File -Filter '*.csproj'
if ($projects.Count -eq 0) {
    Write-Output 'No C# projects found for restore/format.'
    exit 0
}

$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
dotnet restore @($projects.FullName)

foreach ($project in $projects) {
    Write-Output "Checking formatting for $($project.FullName)"
    dotnet format $project.FullName --verify-no-changes --verbosity minimal
}

$extensions = @('png','psd','jpg','jpeg','tga','tif','tiff','exr','wav','mp3','ogg','fbx')
$problem = $false

$patterns = $extensions | ForEach-Object { "*.${_}" }
$files = (& git ls-files -- $patterns) -split "`n" | Where-Object { $_ }
foreach ($file in $files) {
    $size = (Get-Item -LiteralPath $file).Length
    if ($size -lt 102400) { continue }

    $attr = & git check-attr filter -- $file
    if ($attr -match 'filter: lfs') { continue }

    Write-Output "File should be tracked via Git LFS: $file (${size} bytes)"
    $problem = $true
}

if ($problem) {
    throw 'Large binary assets must be tracked with Git LFS.'
}

Write-Output 'All checks passed.'
