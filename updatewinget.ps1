param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [string]$Token,

    [switch]$Submit
)

$packageId = "yetanotherchris.zolam"
$url = "https://github.com/yetanotherchris/zolam/releases/download/v$Version/zolam-windows-amd64.exe"

# Check wingetcreate is installed
if (-not (Get-Command wingetcreate -ErrorAction SilentlyContinue)) {
    Write-Error "wingetcreate not found. Install with: winget install wingetcreate"
    exit 1
}

$args = @("update", $packageId, "-v", $Version, "-u", $url)

if ($Submit) {
    if (-not $Token) {
        Write-Error "A GitHub personal access token is required when using -Submit. Pass it with -Token."
        exit 1
    }
    $args += @("--submit", "--token", $Token)
    Write-Host "Updating and submitting $packageId v$Version to winget-pkgs..."
} else {
    $outputDir = "$PSScriptRoot/winget-output"
    $args += @("-o", $outputDir)
    Write-Host "Updating $packageId v$Version (output to $outputDir)..."
}

& wingetcreate @args

if ($LASTEXITCODE -eq 0) {
    Write-Host "Done."
    if (-not $Submit) {
        Write-Host ""
        Write-Host "To submit, re-run with -Submit -Token <github-pat>"
    }
} else {
    Write-Error "wingetcreate failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
