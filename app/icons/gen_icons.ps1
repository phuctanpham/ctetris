# Sinh app icon (PNG/ICO) tu SVG nguon - bo qua silent neu khong co rasterizer
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceSvg = if ($args[0]) { $args[0] } else { Join-Path $ScriptDir "..\src\gameStory\gameStory_logo.svg" }
$OutDir    = if ($args[1]) { $args[1] } else { $ScriptDir }

if (-not (Test-Path $SourceSvg)) {
    Write-Host "[ICON] SVG nguon khong ton tai: $SourceSvg -- bo qua." -ForegroundColor Yellow
    exit 0
}

$Rasterize = $null
if (Get-Command rsvg-convert -ErrorAction SilentlyContinue) { $Rasterize = "rsvg" }
elseif (Get-Command magick    -ErrorAction SilentlyContinue) { $Rasterize = "magick" }
elseif (Get-Command convert   -ErrorAction SilentlyContinue) { $Rasterize = "convert" }
elseif (Get-Command inkscape  -ErrorAction SilentlyContinue) { $Rasterize = "inkscape" }

if (-not $Rasterize) {
    Write-Host "[ICON] Khong tim thay rsvg-convert / ImageMagick / Inkscape." -ForegroundColor Yellow
    Write-Host "       Cai: choco install rsvg-convert  (hoac choco install imagemagick)"
    Write-Host "       Bo qua sinh icon -- build van se thanh cong."
    exit 0
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

function Svg-To-Png {
    param([string]$Src, [int]$Size, [string]$Dst)
    switch ($Rasterize) {
        "rsvg"     { & rsvg-convert -w $Size -h $Size $Src -o $Dst }
        "magick"   { & magick -background none -size "${Size}x${Size}" $Src -resize "${Size}x${Size}" $Dst }
        "convert"  { & convert -background none -size "${Size}x${Size}" $Src -resize "${Size}x${Size}" $Dst }
        "inkscape" { & inkscape -w $Size -h $Size $Src -o $Dst }
    }
}

Write-Host "[ICON] Generate icons tu $SourceSvg (rasterizer: $Rasterize) ..." -ForegroundColor Cyan

Svg-To-Png $SourceSvg 192  (Join-Path $OutDir "icon-192.png")
Svg-To-Png $SourceSvg 512  (Join-Path $OutDir "icon-512.png")
Svg-To-Png $SourceSvg 1024 (Join-Path $OutDir "icon-1024.png")

if ($Rasterize -eq "magick" -or $Rasterize -eq "convert") {
    $tool = $Rasterize
    $tmpFiles = @()
    foreach ($s in @(16, 32, 48, 64, 128, 256)) {
        $tmp = Join-Path $OutDir "_tmp_$s.png"
        Svg-To-Png $SourceSvg $s $tmp
        $tmpFiles += $tmp
    }
    & $tool ($tmpFiles + (Join-Path $OutDir "icon.ico"))
    foreach ($f in $tmpFiles) { Remove-Item $f -Force }
    Write-Host "[ICON] Da sinh icon.ico"
} else {
    Write-Host "[ICON] Bo qua icon.ico (yeu cau ImageMagick)."
}

Write-Host "[ICON] Hoan tat -- xem $OutDir" -ForegroundColor Green