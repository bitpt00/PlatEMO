param(
    [string]$ConfigName = "s10_platemo_screen",
    [int]$TotalTasks = 6160
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..\..")).Path
$resultDir = Join-Path $repoRoot ("research\experiments\cmoea-aop\results\S10_external_comparison\{0}" -f $ConfigName)
$stdoutDir = Join-Path $repoRoot "research\experiments\cmoea-aop\results\S10_external_comparison\worker_stdout"

$done = 0
if (Test-Path -LiteralPath $resultDir) {
    $done = (Get-ChildItem -LiteralPath $resultDir -Filter "*.mat" -ErrorAction SilentlyContinue | Measure-Object).Count
}

$percent = 0
if ($TotalTasks -gt 0) {
    $percent = [math]::Round(100.0 * $done / $TotalTasks, 2)
}

$matlabProcesses = @(Get-Process matlab -ErrorAction SilentlyContinue)

Write-Host ("Result dir: {0}" -f $resultDir)
Write-Host ("Completed MAT files: {0}/{1} ({2}%)" -f $done,$TotalTasks,$percent)
Write-Host ("Running MATLAB processes: {0}" -f $matlabProcesses.Count)

if ($matlabProcesses.Count -gt 0) {
    $matlabProcesses |
        Select-Object Id,CPU,@{Name="MemoryGB";Expression={[math]::Round($_.WorkingSet64/1GB,2)}},StartTime |
        Format-Table -AutoSize
}

if (Test-Path -LiteralPath $resultDir) {
    $logs = Get-ChildItem -LiteralPath $resultDir -Filter "*log_worker*.csv" -ErrorAction SilentlyContinue
    if ($logs.Count -gt 0) {
        $errorLines = Select-String -Path $logs.FullName -Pattern ',"error",' -ErrorAction SilentlyContinue
        Write-Host ("Logged errors: {0}" -f @($errorLines).Count)
        if (@($errorLines).Count -gt 0) {
            @($errorLines) | Select-Object -Last 10 | ForEach-Object { Write-Host $_.Line }
        }
    }
}

if (Test-Path -LiteralPath $stdoutDir) {
    $recent = Get-ChildItem -LiteralPath $stdoutDir -Filter "*.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 6 Name,Length,LastWriteTime
    if ($recent) {
        Write-Host "Recent worker stdout/stderr logs:"
        $recent | Format-Table -AutoSize
    }
}
