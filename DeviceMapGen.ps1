<#
.SYNOPSIS
  Generate splitted partial C# files mapping Model -> "Marketing Name" from supported_devices.csv.

.DESCRIPTION
  - Downloads CSV (or uses local copy if present).
  - Reads columns: "Marketing Name" and "Model".
  - Builds partial files DeviceLookup_PartNNN.cs with switch expressions.
  - Generates a main DeviceLookup.cs that chains GetMarketingName_PartNNN calls and returns the first non-null.
#>


param(
    [string]$CsvUrl = "http://storage.googleapis.com/play_public/supported_devices.csv",
    [string]$CsvPath = "supported_devices.csv",
    [string]$OutputDir = "DeviceMarketName",
    [string]$BaseName = "DeviceLookup",
    [int]$CasesPerFile = 500,
    [switch]$ForceDownload = $false,
    [switch]$CleanOldParts = $true
)

function Escape-CSharpString([string]$s) {
    if ($null -eq $s) { return "" }
    $s = $s -replace "`r`n", "`n"
    $s = $s.Trim()
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '"', '\"'
    $s = $s -replace "`n", '\n'
    $s = $s -replace "`t", '\t'
    return $s
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

if ($ForceDownload -or -not (Test-Path $CsvPath)) {
    Write-Host "🌐 Downloading CSV from $CsvUrl ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $CsvUrl -OutFile $CsvPath -UseBasicParsing
    Write-Host "✅ Downloaded to $CsvPath" -ForegroundColor Green
} else {
    Write-Host "📁 Using existing CSV at $CsvPath" -ForegroundColor Cyan
}

Write-Host "📂 Importing CSV..." -ForegroundColor Cyan
$rows = Import-Csv -Path $CsvPath
Write-Host "✅ Loaded $($rows.Count) records." -ForegroundColor Green

$map = [System.Collections.Generic.Dictionary[string,string]]::new([System.StringComparer]::Ordinal)
$i = 0
foreach ($r in $rows) {
    $i++
    $marketing = $null
    if ($r.PSObject.Properties.Name -contains 'Marketing Name') { $marketing = $r.'Marketing Name' }
    elseif ($r.PSObject.Properties.Name -contains 'MarketingName') { $marketing = $r.MarketingName }

    $model = $null
    if ($r.PSObject.Properties.Name -contains 'Model') { $model = $r.Model }

    if ($null -eq $model) { continue }

    $model = $model.ToString().Trim()
    if ($null -ne $marketing) { $marketing = $marketing.ToString().Trim() } else { $marketing = "" }

    if (-not $map.ContainsKey($model)) {
        $map.Add($model, $marketing)
    }

    if ($i % 10000 -eq 0) { Write-Host "  processed $i rows..." }
}

Write-Host "🔎 Unique models collected: $($map.Count)" -ForegroundColor Cyan

if ($CleanOldParts) {
    Write-Host "🧹 Cleaning old part files..." -ForegroundColor Cyan
    Get-ChildItem -Path $OutputDir -Filter "$BaseName*_Part*.cs" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    $mainFile = Join-Path $OutputDir "$BaseName.cs"
    if (Test-Path $mainFile) { Remove-Item $mainFile -Force -ErrorAction SilentlyContinue }
}

$lines = New-Object System.Collections.Generic.List[string]
foreach ($kv in $map.GetEnumerator()) {
    $mEsc = Escape-CSharpString $kv.Key
    $nEsc = Escape-CSharpString $kv.Value
    $lines.Add("            `"$($mEsc)`" => `"$($nEsc)`",")
}

$total = [math]::Ceiling($lines.Count / [double]$CasesPerFile)
if ($total -lt 1) { $total = 1 }

Write-Host "✂ Splitting into $total part files (approx $CasesPerFile per file)..." -ForegroundColor Cyan

for ($p = 0; $p -lt $total; $p++) {
    $start = $p * $CasesPerFile
    $end = [math]::Min($start + $CasesPerFile - 1, $lines.Count - 1)
    $slice = $lines[$start..$end]

    $partNumber = ($p + 1).ToString("D3")
    $filePath = Join-Path $OutputDir "$BaseName`_Part$partNumber.cs"

    $partBody = $slice -join "`r`n"

    $partContent = @"
namespace DeviceMarketName
{
    public static partial class DeviceLookup
    {
        internal static string? GetMarketingName_$partNumber(string model) => model switch
        {
$partBody
            _ => null
        };
    }
}
"@

    Set-Content -Path $filePath -Value $partContent -Encoding UTF8
    Write-Host "  ▸ Created $filePath with $($slice.Count) cases"
}

Write-Host "🧩 Generating main $BaseName.cs ..." -ForegroundColor Cyan
$chainLines = @()
for ($p = 1; $p -le $total; $p++) {
    $method = "GetMarketingName_{0}(model)" -f ($p.ToString("D3"))
    if ($p -eq 1) {
        $chainLines += "            return $method"
    } else {
        $chainLines += "                ?? $method"
    }
}
$chain = ($chainLines -join "`r`n") + "`r`n                ?? null;"

$mainContent = @"
namespace DeviceMarketName
{
    public static partial class DeviceLookup
    {
        public static string? GetMarketingName(string model)
        {
$chain
        }
    }
}
"@

$mainFilePath = Join-Path $OutputDir "$BaseName.cs"
Set-Content -Path $mainFilePath -Value $mainContent -Encoding UTF8
Write-Host "✅ Main file created: $mainFilePath" -ForegroundColor Green

Write-Host "🎉 Done. Generated $total part files, total mappings: $($map.Count)." -ForegroundColor Magenta