param(
    [int]$WorkerCount = 12,
    [string]$ConfigName = "s10_platemo_screen_config",
    [int]$MaxNewTasks = 0,
    [switch]$MissingOnly,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..\..")).Path
$experimentDir = Join-Path $repoRoot "research\experiments\cmoea-aop"
$logDir = Join-Path $experimentDir "results\S10_external_comparison\worker_stdout"

if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$runner = "run_s01_experiment"
if ($MissingOnly) {
    $runner = "run_missing_experiment"
}

$maxTaskArg = "inf"
if ($MaxNewTasks -gt 0) {
    $maxTaskArg = [string]$MaxNewTasks
}

$escapedRoot = $repoRoot.Replace("'", "''")
$env:OMP_NUM_THREADS = "1"
$env:MKL_NUM_THREADS = "1"

Write-Host "Repo: $repoRoot"
Write-Host "Config: $ConfigName"
Write-Host "Runner: $runner"
Write-Host "Workers: $WorkerCount"
Write-Host "MaxNewTasks per worker: $maxTaskArg"
Write-Host "Logs: $logDir"

for ($i = 1; $i -le $WorkerCount; $i++) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $stdout = Join-Path $logDir ("{0}_worker{1:D2}_of_{2}_{3}.out.log" -f $ConfigName,$i,$WorkerCount,$stamp)
    $stderr = Join-Path $logDir ("{0}_worker{1:D2}_of_{2}_{3}.err.log" -f $ConfigName,$i,$WorkerCount,$stamp)
    $matlabCommand = "cd('$escapedRoot'); maxNumCompThreads(1); addpath(fullfile(pwd,'research','experiments','cmoea-aop','scripts')); addpath(fullfile(pwd,'research','experiments','cmoea-aop','configs')); $runner('$ConfigName',$i,$WorkerCount,$maxTaskArg);"

    if ($DryRun) {
        Write-Host "[dry-run] matlab -batch ""$matlabCommand"""
        continue
    }

    New-Item -ItemType File -Path $stderr -Force | Out-Null
    $batchArgument = '-batch "' + $matlabCommand.Replace('"','\"') + '" -logfile "' + $stdout.Replace('"','\"') + '"'
    $process = Start-Process -FilePath "matlab" `
        -ArgumentList $batchArgument `
        -WindowStyle Hidden `
        -PassThru

    Write-Host ("Started worker {0}/{1}: PID={2}" -f $i,$WorkerCount,$process.Id)
}
