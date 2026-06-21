param(
    [ValidateSet('sync', 'claim', 'complete', 'release', 'status')]
    [string]$Action = 'status',

    [string]$PaperId
)

$ErrorActionPreference = 'Stop'

$indexDir = $PSScriptRoot
$kbRoot = Split-Path -Parent $indexDir
$workspaceRoot = Split-Path -Parent $kbRoot
$mdDir = Join-Path $workspaceRoot 'MD'
$pdfDir = Join-Path $workspaceRoot 'pdfs'
$papersPath = Join-Path $indexDir 'papers.csv'
$lockPath = Join-Path $indexDir '.paper_queue.lock'
$catalogPath = @(
    Get-ChildItem -File -Filter '*.csv' -LiteralPath $workspaceRoot |
        Sort-Object Length -Descending |
        Select-Object -First 1
).FullName

$columns = @(
    'paper_id',
    'source_key',
    'title',
    'doi',
    'year',
    'journal',
    'pdf_path',
    'md_path',
    'status',
    'source_quality',
    'added_at',
    'started_at',
    'completed_at',
    'notes'
)

function Normalize-SourceStem([string]$stem) {
    return $stem -replace '_(CrossrefPage|Crossref|WebVPN|Unpaywall)$', ''
}

function Get-DoiFromStem([string]$stem) {
    $normalized = Normalize-SourceStem $stem
    if ($normalized -match '^(10\.\d{4,9})_(.+)$') {
        return "$($Matches[1])/$($Matches[2])".ToLowerInvariant()
    }
    return ''
}

function Get-DoiFromMarkdown([string]$path, [string]$stem) {
    $stemDoi = Get-DoiFromStem $stem
    if ($stemDoi) {
        return $stemDoi
    }

    if (-not $path -or -not (Test-Path -LiteralPath $path)) {
        return ''
    }

    $reader = [System.IO.StreamReader]::new($path, [System.Text.Encoding]::UTF8, $true)
    try {
        $buffer = New-Object char[] 30000
        $count = $reader.Read($buffer, 0, $buffer.Length)
        $text = -join $buffer[0..([Math]::Max(0, $count - 1))]
    } finally {
        $reader.Dispose()
    }

    $match = [regex]::Match(
        $text,
        '(?i)(?:https?://(?:dx\.)?doi\.org/|(?:^|\s)doi\s*:?\s*|digital\s+object\s+identifier\s+)(10\.\d{4,9}/[^\s<>"\[\]]+)'
    )
    if (-not $match.Success) {
        return ''
    }

    $doi = $match.Groups[1].Value.Trim().TrimEnd('.', ',', ';', ':', ')', '*', '_').ToLowerInvariant()
    $suffix = $doi.Substring($doi.IndexOf('/') + 1)
    if ($suffix.Length -lt 8 -or $suffix -notmatch '\d') {
        return ''
    }
    return $doi
}

function Get-YearFromMarkdown([string]$path, [string]$stem) {
    if (-not $path -or -not (Test-Path -LiteralPath $path)) {
        return ''
    }

    $reader = [System.IO.StreamReader]::new($path, [System.Text.Encoding]::UTF8, $true)
    try {
        $buffer = New-Object char[] 800
        $count = $reader.Read($buffer, 0, $buffer.Length)
        $text = -join $buffer[0..([Math]::Max(0, $count - 1))]
    } finally {
        $reader.Dispose()
    }

    $match = [regex]::Match($text, '\b(?:19|20)\d{2}\b')
    if ($match.Success) {
        return $match.Value
    }

    $normalized = Normalize-SourceStem $stem
    $stemYears = @([regex]::Matches($normalized, '(?:19|20)\d{2}') | ForEach-Object { $_.Value })
    if ($stemYears.Count -gt 0) {
        return $stemYears[-1]
    }
    return ''
}

function Get-CatalogMap {
    $map = @{}
    if (-not (Test-Path -LiteralPath $catalogPath)) {
        return $map
    }

    foreach ($row in Import-Csv -Encoding UTF8 -LiteralPath $catalogPath) {
        $properties = @($row.PSObject.Properties)
        if ($properties.Count -lt 7) {
            continue
        }
        $doi = ([string]$properties[1].Value).Trim().ToLowerInvariant()
        if (-not $doi) {
            continue
        }
        $yearMatch = [regex]::Match([string]$properties[6].Value, '\b(?:19|20)\d{2}\b')
        $map[$doi] = [PSCustomObject]@{
            title = $properties[0].Value
            doi = $doi
            year = if ($yearMatch.Success) { $yearMatch.Value } else { '' }
            journal = $properties[2].Value
        }
    }
    return $map
}

function Get-SourceRank([string]$stem) {
    if ($stem -match '_Crossref$') { return 0 }
    if ($stem -notmatch '_(CrossrefPage|WebVPN|Unpaywall)$') { return 1 }
    if ($stem -match '_CrossrefPage$') { return 2 }
    if ($stem -match '_Unpaywall$') { return 3 }
    return 4
}

function Get-RelativePath([string]$path) {
    $root = $workspaceRoot.TrimEnd('\') + '\'
    if ($path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $path.Substring($root.Length).Replace('\', '/')
    }
    return $path.Replace('\', '/')
}

function New-EmptyRow {
    $row = [ordered]@{}
    foreach ($column in $columns) {
        $row[$column] = ''
    }
    return [PSCustomObject]$row
}

function Convert-ToCurrentRow($source) {
    $row = New-EmptyRow
    foreach ($column in $columns) {
        if ($source.PSObject.Properties.Name -contains $column) {
            $row.$column = $source.$column
        }
    }
    return $row
}

function Read-Papers {
    if (-not (Test-Path -LiteralPath $papersPath)) {
        return @()
    }
    return @(Import-Csv -Encoding UTF8 -LiteralPath $papersPath | ForEach-Object { Convert-ToCurrentRow $_ })
}

function Write-Papers($rows) {
    @($rows) |
        Select-Object $columns |
        Export-Csv -Encoding UTF8 -NoTypeInformation -LiteralPath $papersPath
}

function Get-NextPaperId([string]$year, $rows) {
    if ([string]::IsNullOrWhiteSpace($year)) {
        $year = '0000'
    }

    $max = 0
    foreach ($row in $rows) {
        if ($row.paper_id -match "^P$year-(\d{4})$") {
            $number = [int]$Matches[1]
            if ($number -gt $max) {
                $max = $number
            }
        }
    }
    return "P$year-{0:D4}" -f ($max + 1)
}

function Get-DiscoveredPapers {
    $catalog = Get-CatalogMap
    $mdFiles = @{}
    if (Test-Path -LiteralPath $mdDir) {
        foreach ($file in Get-ChildItem -File -Filter '*.md' -LiteralPath $mdDir) {
            $mdFiles[$file.BaseName] = $file
        }
    }

    $pdfFiles = @{}
    if (Test-Path -LiteralPath $pdfDir) {
        foreach ($file in Get-ChildItem -File -Filter '*.pdf' -LiteralPath $pdfDir) {
            $pdfFiles[$file.BaseName] = $file
        }
    }

    $stems = @($mdFiles.Keys + $pdfFiles.Keys | Sort-Object -Unique)
    $assets = foreach ($stem in $stems) {
        $mdFile = if ($mdFiles.ContainsKey($stem)) { $mdFiles[$stem] } else { $null }
        $pdfFile = if ($pdfFiles.ContainsKey($stem)) { $pdfFiles[$stem] } else { $null }
        $doi = if ($mdFile) { Get-DoiFromMarkdown $mdFile.FullName $stem } else { Get-DoiFromStem $stem }
        $normalizedStem = Normalize-SourceStem $stem
        $sourceKey = if ($doi) { "doi:$doi" } else { "stem:$($normalizedStem.ToLowerInvariant())" }
        $catalogRow = if ($doi -and $catalog.ContainsKey($doi)) { $catalog[$doi] } else { $null }
        $year = if ($catalogRow -and $catalogRow.year) { $catalogRow.year } elseif ($mdFile) { Get-YearFromMarkdown $mdFile.FullName $stem } else { '' }
        if (-not $year -and $doi) {
            $doiYear = [regex]::Match($doi, '(?:19|20)\d{2}')
            if ($doiYear.Success) {
                $year = $doiYear.Value
            }
        }

        [PSCustomObject]@{
            source_key = $sourceKey
            doi = $doi
            year = $year
            title = if ($catalogRow) { $catalogRow.title } else { '' }
            journal = if ($catalogRow) { $catalogRow.journal } else { '' }
            stem = $stem
            rank = Get-SourceRank $stem
            md_path = if ($mdFile) { Get-RelativePath $mdFile.FullName } else { '' }
            pdf_path = if ($pdfFile) { Get-RelativePath $pdfFile.FullName } else { '' }
        }
    }

    return @(
        $assets |
            Group-Object source_key |
            ForEach-Object {
                $_.Group |
                    Sort-Object @{ Expression = 'rank'; Ascending = $true }, @{ Expression = 'stem'; Ascending = $true } |
                    Select-Object -First 1
            } |
            Sort-Object source_key
    )
}

function Sync-Papers($rows) {
    $now = (Get-Date).ToString('s')
    $discovered = @(Get-DiscoveredPapers)
    $byKey = @{}
    $byStem = @{}

    foreach ($row in $rows) {
        if (-not $row.source_key) {
            if ($row.doi) {
                $row.source_key = "doi:$($row.doi.ToLowerInvariant())"
            } elseif ($row.md_path) {
                $stem = [System.IO.Path]::GetFileNameWithoutExtension($row.md_path)
                $row.source_key = "stem:$((Normalize-SourceStem $stem).ToLowerInvariant())"
            }
        }
        if ($row.source_key) {
            $byKey[$row.source_key] = $row
        }
        $assetPath = if ($row.md_path) { $row.md_path } else { $row.pdf_path }
        if ($assetPath) {
            $assetStem = [System.IO.Path]::GetFileNameWithoutExtension($assetPath)
            $byStem[(Normalize-SourceStem $assetStem).ToLowerInvariant()] = $row
        }
    }

    $added = 0
    foreach ($paper in $discovered) {
        $paperStem = (Normalize-SourceStem $paper.stem).ToLowerInvariant()
        $row = if ($byKey.ContainsKey($paper.source_key)) {
            $byKey[$paper.source_key]
        } elseif ($byStem.ContainsKey($paperStem)) {
            $byStem[$paperStem]
        } else {
            $null
        }

        if ($row) {
            if ($row.source_key -ne $paper.source_key) {
                if ($row.source_key) {
                    [void]$byKey.Remove($row.source_key)
                }
                $row.source_key = $paper.source_key
                $byKey[$paper.source_key] = $row
            }
            if (-not $row.md_path -and $paper.md_path) { $row.md_path = $paper.md_path }
            if (-not $row.pdf_path -and $paper.pdf_path) { $row.pdf_path = $paper.pdf_path }
            if (-not $row.doi -and $paper.doi) { $row.doi = $paper.doi }
            if (-not $row.year -and $paper.year) { $row.year = $paper.year }
            if (-not $row.title -and $paper.title) { $row.title = $paper.title }
            if (-not $row.journal -and $paper.journal) { $row.journal = $paper.journal }
            if ($row.md_path -and $row.pdf_path -and $row.status -in @('missing-md', 'missing-pdf')) {
                $row.status = 'unprocessed'
            }
            continue
        }

        $row = New-EmptyRow
        $row.paper_id = Get-NextPaperId $paper.year $rows
        $row.source_key = $paper.source_key
        $row.title = $paper.title
        $row.doi = $paper.doi
        $row.year = $paper.year
        $row.journal = $paper.journal
        $row.pdf_path = $paper.pdf_path
        $row.md_path = $paper.md_path
        $row.status = if ($paper.md_path -and $paper.pdf_path) { 'unprocessed' } elseif (-not $paper.md_path) { 'missing-md' } else { 'missing-pdf' }
        $row.source_quality = 'not-reviewed'
        $row.added_at = $now
        $rows += $row
        $byKey[$row.source_key] = $row
        $added++
    }

    return [PSCustomObject]@{
        rows = @($rows)
        discovered = $discovered.Count
        added = $added
    }
}

function Show-Paper($row) {
    Write-Output "paper_id=$($row.paper_id)"
    Write-Output "status=$($row.status)"
    Write-Output "md_path=$($row.md_path)"
    Write-Output "pdf_path=$($row.pdf_path)"
    Write-Output "doi=$($row.doi)"
    Write-Output "year=$($row.year)"
}

$lockStream = [System.IO.File]::Open($lockPath, 'OpenOrCreate', 'ReadWrite', 'None')
try {
    $rows = @(Read-Papers)
    $sync = Sync-Papers $rows
    $rows = @($sync.rows)

    switch ($Action) {
        'sync' {
            Write-Papers $rows
            Write-Output "discovered=$($sync.discovered)"
            Write-Output "added=$($sync.added)"
            Write-Output "total=$($rows.Count)"
        }
        'claim' {
            $candidate = $null
            if ($PaperId) {
                $candidate = $rows | Where-Object { $_.paper_id -eq $PaperId -and $_.status -eq 'unprocessed' } | Select-Object -First 1
            } else {
                $candidate = $rows |
                    Where-Object { $_.status -eq 'unprocessed' } |
                    Sort-Object @{ Expression = 'added_at'; Ascending = $true }, @{ Expression = 'md_path'; Ascending = $true } |
                    Select-Object -First 1
            }

            if (-not $candidate) {
                Write-Papers $rows
                Write-Output 'no_unprocessed_paper=true'
                exit 0
            }

            $candidate.status = 'in_progress'
            $candidate.started_at = (Get-Date).ToString('s')
            $candidate.notes = ''
            Write-Papers $rows
            Show-Paper $candidate
        }
        'complete' {
            if (-not $PaperId) {
                throw 'complete requires -PaperId'
            }
            $row = $rows | Where-Object { $_.paper_id -eq $PaperId } | Select-Object -First 1
            if (-not $row) {
                throw "Unknown paper ID: $PaperId"
            }
            if ($row.status -ne 'in_progress') {
                throw "Paper must be in_progress before completion: $PaperId is $($row.status)"
            }
            $cardPath = Join-Path (Join-Path $kbRoot '01_papers') "$PaperId.md"
            if (-not (Test-Path -LiteralPath $cardPath)) {
                throw "Paper card does not exist: $cardPath"
            }
            $row.status = 'extracted'
            $row.completed_at = (Get-Date).ToString('s')
            $row.notes = ''
            Write-Papers $rows
            Show-Paper $row
        }
        'release' {
            if (-not $PaperId) {
                throw 'release requires -PaperId'
            }
            $row = $rows | Where-Object { $_.paper_id -eq $PaperId } | Select-Object -First 1
            if (-not $row) {
                throw "Unknown paper ID: $PaperId"
            }
            if ($row.status -eq 'in_progress') {
                $row.status = 'unprocessed'
                $row.started_at = ''
                $row.notes = 'released for future processing'
            }
            Write-Papers $rows
            Show-Paper $row
        }
        'status' {
            Write-Papers $rows
            Write-Output "discovered=$($sync.discovered)"
            Write-Output "added=$($sync.added)"
            foreach ($group in $rows | Group-Object status | Sort-Object Name) {
                Write-Output "$($group.Name)=$($group.Count)"
            }
            Write-Output "total=$($rows.Count)"
            $next = $rows |
                Where-Object { $_.status -eq 'unprocessed' } |
                Sort-Object @{ Expression = 'added_at'; Ascending = $true }, @{ Expression = 'md_path'; Ascending = $true } |
                Select-Object -First 1
            if ($next) {
                Write-Output "next_paper_id=$($next.paper_id)"
                Write-Output "next_md_path=$($next.md_path)"
            }
            $activeIds = @($rows | Where-Object { $_.status -eq 'in_progress' } | Select-Object -ExpandProperty paper_id)
            Write-Output "in_progress_ids=$($activeIds -join ',')"
        }
    }
} finally {
    $lockStream.Dispose()
}
