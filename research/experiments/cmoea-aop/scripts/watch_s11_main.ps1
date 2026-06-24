param(
    [int]$WorkerCount = 20,
    [int]$IntervalSeconds = 600,
    [double]$CpuThreshold = 50,
    [int]$StaleMinutes = 10,
    [int]$MatlabMinCount = 8,
    [int]$TotalTasks = 16800
)

$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..\..")).Path
$configName = "s11_main_30run_config"
$runner = Join-Path $scriptDir "start_s10a_cpu_workers.ps1"
$resultRoot = Join-Path $repoRoot "research\experiments\cmoea-aop\results\S11_main_30run"
$resultDir = Join-Path $resultRoot "s11_main_30run"
$watchLog = Join-Path $resultRoot "s11_watchdog.csv"
$runnerLog = Join-Path $resultRoot "s11_watchdog_runner.log"
$lockFile = Join-Path $resultRoot "s11_watchdog.lock"

if (-not (Test-Path -LiteralPath $resultRoot)) {
    New-Item -ItemType Directory -Path $resultRoot | Out-Null
}

if (Test-Path -LiteralPath $lockFile) {
    $lockAge = ((Get-Date) - (Get-Item -LiteralPath $lockFile).LastWriteTime).TotalSeconds
    if ($lockAge -lt ($IntervalSeconds * 2)) {
        Write-Host "Another recent S11 watchdog appears to be active. Exiting."
        exit 0
    }
}

if (-not (Test-Path -LiteralPath $watchLog)) {
    "timestamp,done,total,percent,cpu_average,matlab_count,latest_result,latest_age_minutes,error_lines,action" |
        Out-File -LiteralPath $watchLog -Encoding utf8
}

function Get-S11Status {
    $now = Get-Date
    $files = @()
    if (Test-Path -LiteralPath $resultDir) {
        $files = @(Get-ChildItem -LiteralPath $resultDir -Filter "*.mat")
    }
    $done = $files.Count
    $latest = $null
    if ($done -gt 0) {
        $latest = ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    }
    $latestAge = $null
    if ($latest -ne $null) {
        $latestAge = [math]::Round(($now - $latest).TotalMinutes, 1)
    }

    $cpu = $null
    try {
        $samples = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 3
        $cpu = [math]::Round(($samples.CounterSamples | Measure-Object CookedValue -Average).Average, 1)
    } catch {
        $cpu = $null
    }

    $matlabCount = (Get-Process matlab -ErrorAction SilentlyContinue | Measure-Object).Count

    $errorLines = 0
    if (Test-Path -LiteralPath $resultDir) {
        $logs = @(Get-ChildItem -LiteralPath $resultDir -Filter "*_log_worker*_of_*.csv")
        if ($logs.Count -gt 0) {
            $hits = $logs | Select-String -Pattern ',"error",|,error,'
            $errorLines = ($hits | Measure-Object).Count
        }
    }

    [pscustomobject]@{
        Now = $now
        Done = $done
        Total = $TotalTasks
        Percent = [math]::Round(100 * $done / $TotalTasks, 2)
        Latest = $latest
        LatestAge = $latestAge
        Cpu = $cpu
        MatlabCount = $matlabCount
        ErrorLines = $errorLines
    }
}

while ($true) {
    Set-Content -LiteralPath $lockFile -Value ("pid={0}; time={1:o}" -f $PID, (Get-Date)) -Encoding utf8

    $s = Get-S11Status
    $action = "monitor"

    if ($s.Done -ge $TotalTasks) {
        $action = "complete"
    } else {
        $lowCpu = ($s.Cpu -eq $null) -or ($s.Cpu -lt $CpuThreshold)
        $stale = ($s.LatestAge -eq $null) -or ($s.LatestAge -ge $StaleMinutes)
        $lowMatlab = $s.MatlabCount -lt $MatlabMinCount

        if (($lowCpu -and $stale) -or $lowMatlab) {
            $action = "restart_missing"
            $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "[$stamp] restarting missing S11 tasks: done=$($s.Done), cpu=$($s.Cpu), matlab=$($s.MatlabCount), latestAge=$($s.LatestAge)" |
                Out-File -LiteralPath $runnerLog -Append -Encoding utf8
            & $runner -WorkerCount $WorkerCount -ConfigName $configName -MissingOnly 2>&1 |
                Out-File -LiteralPath $runnerLog -Append -Encoding utf8
        }
    }

    $latestText = ""
    if ($s.Latest -ne $null) {
        $latestText = $s.Latest.ToString("yyyy-MM-dd HH:mm:ss")
    }
    $line = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}" -f `
        $s.Now.ToString("yyyy-MM-dd HH:mm:ss"), $s.Done, $s.Total, $s.Percent, $s.Cpu, `
        $s.MatlabCount, $latestText, $s.LatestAge, $s.ErrorLines, $action
    Add-Content -LiteralPath $watchLog -Value $line -Encoding utf8

    if ($action -eq "complete") {
        Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
        exit 0
    }

    Start-Sleep -Seconds $IntervalSeconds
}
