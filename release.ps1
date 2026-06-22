# Packt Blinkiis_Portraits in eine Release-Zip
# Name: Blinkiis_Portraits-v<Version>-<TagMonatJahr>.zip  (z.B. Blinkiis_Portraits-v1.52-22062026.zip)
# Version wird aus der TOC gelesen, Datum ist der heutige Tag.

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

# Version aus der TOC lesen (## Version: 1.52)
$toc = Join-Path $root "Blinkiis_Portraits\Blinkiis_Portraits_Mainline.toc"
$match = Select-String -Path $toc -Pattern '^## Version:\s*(.+)$'
if (-not $match) { throw "Version nicht in TOC gefunden: $toc" }
$version = $match.Matches[0].Groups[1].Value.Trim()

$date = Get-Date -Format "ddMMyyyy"
$zipPath = Join-Path $root "Blinkiis_Portraits-v$version-$date.zip"

if (Test-Path $zipPath) { Remove-Item $zipPath }

Compress-Archive -Path (Join-Path $root "Blinkiis_Portraits") -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "Erstellt: $zipPath"
