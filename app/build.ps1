$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  ctetris -- Build Script (SDL3) - Windows"        -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Phien ban emsdk da kiem chung tuong thich tot voi SDL3
$EmsdkVersion = "3.1.72"
$EmsdkDir     = Join-Path $env:USERPROFILE "emsdk"

# --- Tu dong dam bao nanosvg headers ---
function Ensure-NanoSVG {
    $IncludeDir = "src/gameStory/include"
    $BaseUrl    = "https://raw.githubusercontent.com/memononen/nanosvg/master/src"

    if (-not (Test-Path $IncludeDir)) {
        New-Item -ItemType Directory -Path $IncludeDir -Force | Out-Null
    }

    $files = @("nanosvg.h", "nanosvgrast.h")
    foreach ($file in $files) {
        $target = Join-Path $IncludeDir $file
        $needsDownload = $true

        if (Test-Path $target) {
            if ((Get-Item $target).Length -gt 0) { $needsDownload = $false }
        }

        if ($needsDownload) {
            Write-Host "Thieu $file -- dang tai ve $IncludeDir ..." -ForegroundColor Yellow
            try {
                Invoke-WebRequest -Uri "$BaseUrl/$file" -OutFile $target -UseBasicParsing
            } catch {
                Write-Host "[LOI] Khong tai duoc $file." -ForegroundColor Red
                if (Test-Path $target) { Remove-Item $target -Force }
                exit 1
            }
        }
    }
}

Ensure-NanoSVG

# --- Tu dong sinh gameStory_logo_svg.h tu gameStory_logo.svg ---
function Generate-LogoHeader {
    $SvgFile    = "src/gameStory/gameStory_logo.svg"
    $HeaderFile = "src/gameStory/include/gameStory_logo_svg.h"

    if (-not (Test-Path $SvgFile)) {
        Write-Host "[LOI] Khong tim thay $SvgFile" -ForegroundColor Red
        exit 1
    }

    if (Test-Path $HeaderFile) {
        $svgTime    = (Get-Item $SvgFile).LastWriteTime
        $headerTime = (Get-Item $HeaderFile).LastWriteTime
        if ($headerTime -gt $svgTime) { return }
    }

    Write-Host "Sinh $HeaderFile tu $SvgFile ..." -ForegroundColor Yellow

    $svgContent = Get-Content -Path $SvgFile -Raw
    $headerContent = @"
#pragma once
// File nay duoc sinh tu dong tu gameStory_logo.svg boi build.ps1
// KHONG sua tay -- moi thay doi se bi ghi de o lan build tiep theo.
static const char* LOGO_SVG_DATA = R"SVG_RAW_LOGO(
$svgContent
)SVG_RAW_LOGO";
"@

    $absPath = Join-Path (Get-Location) $HeaderFile
    [System.IO.File]::WriteAllText(
        $absPath, $headerContent,
        (New-Object System.Text.UTF8Encoding $false)
    )
}

Generate-LogoHeader
# --- Tu dong sinh app icon (PNG/ICO) tu SVG ---
$IconScript = "icons\gen_icons.ps1"
if (Test-Path $IconScript) {
    try { & powershell -ExecutionPolicy Bypass -File $IconScript } catch {
        Write-Host "[ICON] Sinh icon that bai (bo qua): $_" -ForegroundColor Yellow
    }
}
function Require-Tool($name, $hint) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        Write-Host "[LOI] Thieu cong cu '$name'. $hint" -ForegroundColor Red
        exit 1
    }
}

# Helper: import bien moi truong tu emsdk_env.bat vao process PowerShell hien tai
# PowerShell khong source duoc .bat truc tiep -- ta chay .bat trong cmd, in toan bo
# bien moi truong bang lenh "set", roi parse de cap nhat tung bien vao Process scope
function Import-EmsdkEnv {
    param([string]$EnvBat)
    if (-not (Test-Path $EnvBat)) { return $false }
    $output = & cmd /c "`"$EnvBat`" >nul 2>&1 && set"
    foreach ($line in $output) {
        if ($line -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], "Process")
        }
    }
    return $true
}

# Helper: dam bao emsdk san sang trong process PowerShell hien tai
# Logic giong build.sh: detect emcmake -> thu load env -> prompt cai dat ->
# clone -> install -> activate -> load env -> verify
function Ensure-Emsdk {
    if (Get-Command emcmake -ErrorAction SilentlyContinue) {
        $ver = (& emcc --version 2>$null | Select-Object -First 1)
        Write-Host "[OK] Emscripten da san sang: $ver" -ForegroundColor Green
        return
    }

    $envBat = Join-Path $EmsdkDir "emsdk_env.bat"
    if (Test-Path $envBat) {
        Write-Host "[INFO] Tim thay $EmsdkDir, dang load env..." -ForegroundColor Yellow
        Import-EmsdkEnv -EnvBat $envBat | Out-Null
        if (Get-Command emcmake -ErrorAction SilentlyContinue) {
            $ver = (& emcc --version 2>$null | Select-Object -First 1)
            Write-Host "[OK] Emscripten kich hoat: $ver" -ForegroundColor Green
            return
        }
        Write-Host "[INFO] Load xong nhung van thieu emcmake -- co the chua activate version $EmsdkVersion." -ForegroundColor Yellow
    }

    Write-Host "[INFO] Emscripten chua san sang trong shell hien tai." -ForegroundColor Yellow
    $ans = Read-Host "Cai/kich hoat emsdk $EmsdkVersion vao $EmsdkDir? [y/N]"
    if ($ans -notmatch '^[Yy]') {
        Write-Host ""
        Write-Host "Huy. De cai thu cong:"
        Write-Host "  cd `$HOME"
        Write-Host "  git clone https://github.com/emscripten-core/emsdk.git"
        Write-Host "  cd emsdk"
        Write-Host "  .\emsdk install $EmsdkVersion"
        Write-Host "  .\emsdk activate $EmsdkVersion"
        Write-Host "  & .\emsdk_env.bat"
        exit 1
    }

    if (-not (Test-Path $EmsdkDir)) {
        Require-Tool "git" "Cai Git: https://git-scm.com/download/win"
        Write-Host "Clone emsdk vao $EmsdkDir ..." -ForegroundColor Yellow
        git clone https://github.com/emscripten-core/emsdk.git $EmsdkDir
    }

    Push-Location $EmsdkDir
    Write-Host "Install emsdk $EmsdkVersion ..." -ForegroundColor Yellow
    & ".\emsdk.bat" install  $EmsdkVersion
    Write-Host "Activate emsdk $EmsdkVersion ..." -ForegroundColor Yellow
    & ".\emsdk.bat" activate $EmsdkVersion
    Pop-Location

    Import-EmsdkEnv -EnvBat $envBat | Out-Null

    if (-not (Get-Command emcmake -ErrorAction SilentlyContinue)) {
        Write-Host "[LOI] Khong tim thay emcmake sau khi load $envBat" -ForegroundColor Red
        Write-Host "      Hay kiem tra thu muc $EmsdkDir roi chay lai."
        exit 1
    }
    $ver = (& emcc --version 2>$null | Select-Object -First 1)
    Write-Host "[OK] Emscripten da san sang: $ver" -ForegroundColor Green

    Write-Host ""
    Write-Host "[GOI Y] De lan sau khong phai load thu cong, chay truoc khi build:" -ForegroundColor Yellow
    Write-Host "        & `"$envBat`""                                               -ForegroundColor Yellow
    Write-Host ""
}
# --- Tu dong sinh app icon (PNG/ICO) tu SVG ---
$IconScript = "icons\gen_icons.ps1"
if (Test-Path $IconScript) {
    try { & powershell -ExecutionPolicy Bypass -File $IconScript } catch {
        Write-Host "[ICON] Sinh icon that bai (bo qua): $_" -ForegroundColor Yellow
    }
}
# --- Hoi target ---
$targetChoice = Read-Host "Ban muon build gi? (1: ctetris, 2: gameStory, 3: gameConsole, 4: gameCore)"
switch ($targetChoice) {
    '2' { $Target = "gameStory" }
    '3' { $Target = "gameConsole" }
    '4' { $Target = "gameCore" }
    default { $Target = "ctetris" }
}

# --- Hoi nen tang ---
$platChoice = Read-Host "Chon nen tang (1: Windows, 2: WASM)"

# =========== Nhanh WASM ===========
if ($platChoice -eq '2') {
    Write-Host "Kiem tra moi truong WASM..." -ForegroundColor Yellow
    Require-Tool "ninja" "Cai Ninja: choco install ninja"
    Ensure-Emsdk

    $BuildDir = "build/wasm"
    if (Test-Path $BuildDir) { Remove-Item -Recurse -Force $BuildDir }
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
    Push-Location $BuildDir

    Write-Host ""
    Write-Host "[INFO] Lan build WASM dau tien se tai SDL3 source (~10MB) va" -ForegroundColor Cyan
    Write-Host "       build cung -- mat khoang 1-2 phut. Cac lan sau dung cache." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Cau hinh CMake voi emcmake..." -ForegroundColor Yellow
    emcmake cmake -G Ninja ../..

    Write-Host "Bien dich target: $Target ..." -ForegroundColor Yellow
    cmake --build . --target $Target

    Pop-Location
    Write-Host ""
    Write-Host "Build WASM thanh cong tai $BuildDir." -ForegroundColor Green
    Write-Host "Cach chay tren localhost:"           -ForegroundColor Green
    Write-Host "  cd $BuildDir; python -m http.server 8000" -ForegroundColor Green
    Write-Host "  Mo: http://localhost:8000/$Target.html"   -ForegroundColor Green
    exit
}

# =========== Nhanh Windows native ===========
Require-Tool "cmake" "Cai CMake >=3.16 tu https://cmake.org/download/"

if (-not $env:VCPKG_ROOT -and -not $env:CMAKE_PREFIX_PATH) {
    Write-Host "[CANH BAO] Khong tim thay VCPKG_ROOT hoac CMAKE_PREFIX_PATH cho SDL3." -ForegroundColor Yellow
    Write-Host "Cach 1: vcpkg install sdl3 va set `$env:VCPKG_ROOT"                    -ForegroundColor Yellow
    Write-Host "Cach 2: Tai SDL3 binary va set `$env:CMAKE_PREFIX_PATH chi den thu muc giai nen" -ForegroundColor Yellow
}

$BuildDir = "build/local"
if (-not (Test-Path $BuildDir)) { New-Item -ItemType Directory -Path $BuildDir | Out-Null }
Push-Location $BuildDir

Write-Host "Cau hinh CMake cho Windows..." -ForegroundColor Yellow
if ($env:VCPKG_ROOT) {
    cmake ../.. -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
} else {
    cmake ../..
}

Write-Host "Bien dich..." -ForegroundColor Yellow
cmake --build . --config Release --target $Target

Pop-Location
Write-Host ""
Write-Host "Build thanh cong! File trong $BuildDir/Release/" -ForegroundColor Green