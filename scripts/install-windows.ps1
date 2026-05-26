$ErrorActionPreference = 'Stop'

$Repo = 'eldertorres/git-clean-gone'
$App = 'git-clean-gone'
$Version = if ($env:GIT_CLEAN_GONE_VERSION) { $env:GIT_CLEAN_GONE_VERSION } else { 'latest' }
$InstallDir = if ($env:GIT_CLEAN_GONE_INSTALL_DIR) { $env:GIT_CLEAN_GONE_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\git-clean-gone\bin' }
$BaseUrl = "https://github.com/$Repo/releases"

$arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
switch ($arch) {
    'X64' { $Triple = 'x86_64-pc-windows-msvc' }
    default { throw "Unsupported Windows architecture: $arch. Current release publishes x86_64 only." }
}

$Asset = "$App-$Triple.zip"
if ($Version -eq 'latest') {
    $Url = "$BaseUrl/latest/download/$Asset"
} else {
    $Url = "$BaseUrl/download/$Version/$Asset"
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
$ZipPath = Join-Path $TempDir $Asset
New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    Write-Host "Installing $App from $Url"
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath
    Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    $ExtractedExe = Get-ChildItem -Path $TempDir -Filter "$App.exe" -Recurse | Select-Object -First 1
    if (-not $ExtractedExe) { throw "Could not find $App.exe in downloaded archive" }

    Copy-Item -Path $ExtractedExe.FullName -Destination (Join-Path $InstallDir "$App.exe") -Force

    $UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $PathParts = @()
    if ($UserPath) { $PathParts = $UserPath -split ';' }

    if ($PathParts -notcontains $InstallDir) {
        $NewPath = if ($UserPath) { "$UserPath;$InstallDir" } else { $InstallDir }
        [Environment]::SetEnvironmentVariable('Path', $NewPath, 'User')
        $env:Path = "$env:Path;$InstallDir"
        Write-Host "Added $InstallDir to the user PATH. Open a new terminal if the command is not found."
    }

    Write-Host "$App installed to $(Join-Path $InstallDir "$App.exe")"
} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
