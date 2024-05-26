param (
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $false)]
    [bool] $MoveDuplicates = $false
)
$SourceDir = $SourceDir.Trim()

function Move-Duplicates {
    param (
        [array]$DuplicateFiles,
        [string]$SourceDir
    )

    foreach ($group in $DuplicateFiles) {
        $original = $group[0]
        $duplicatesDir = Join-Path -Path $SourceDir -ChildPath "duplicates"
        if (-not (Test-Path -Path $duplicatesDir)) {
            New-Item -ItemType Directory -Path $duplicatesDir | Out-Null
        }
        foreach ($duplicate in $group[1..($group.Count - 1)]) {
            $filename = Split-Path -Path $duplicate -Leaf
            $destFile = Join-Path -Path $duplicatesDir -ChildPath $filename
            Move-Item -Path "$duplicate" -Destination $destFile -Force
            Write-Output "$duplicate => $destFile"
        }
    }

    Write-Output "Duplicate files moved successfully to 'duplicates' directory in '$SourceDir'."
}


function Generate-Report {
    param (
        [array]$DuplicateFiles,
        [string]$SourceDir
    )
    $dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = "$SourceDir\report_$dateTime.html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Duplicate Files Report</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .details { display: none; }
    </style>
    <script>
        function toggleDetails(id) {
            var element = document.getElementById(id);
            if (element.style.display === "none") {
                element.style.display = "block";
            } else {
                element.style.display = "none";
            }
        }
    </script>
</head>
<body>
    <h1>Duplicate Files Report</h1>
    <table>
        <tr>
            <th>Original File</th>
            <th>Duplicate File</th>
            <th>Action</th>
        </tr>
"@

    $counter = 0
    foreach ($group in $DuplicateFiles) {
        $original = $group[0]
        foreach ($duplicate in $group[1..($group.Count - 1)]) {
            $counter++
            $detailsId = "details$counter"
            
            # Determine file type
            $originalType = [System.IO.Path]::GetExtension($original).ToLower()
            $duplicateType = [System.IO.Path]::GetExtension($duplicate).ToLower()
            
            # Generate appropriate content display
            $originalContent = ""
            $duplicateContent = ""
            
            switch ($originalType) {
                ".jpg" { $originalContent = "<img src='$original' width='300' />" }
                ".jpeg" { $originalContent = "<img src='$original' width='300' />" }
                ".png" { $originalContent = "<img src='$original' width='300' />" }
                ".gif" { $originalContent = "<img src='$original' width='300' />" }
                ".mp4" { $originalContent = "<video src='$original' width='300' controls></video>" }
                ".mov" { $originalContent = "<video src='$original' width='300' controls></video>" }
                default { $originalContent = "<pre>$(Get-Content -Path $original -Raw)</pre>" }
            }
            
            switch ($duplicateType) {
                ".jpg" { $duplicateContent = "<img src='$duplicate' width='300' />" }
                ".jpeg" { $duplicateContent = "<img src='$duplicate' width='300' />" }
                ".png" { $duplicateContent = "<img src='$duplicate' width='300' />" }
                ".gif" { $duplicateContent = "<img src='$duplicate' width='300' />" }
                ".mp4" { $duplicateContent = "<video src='$duplicate' width='300' controls></video>" }
                ".mov" { $duplicateContent = "<video src='$duplicate' width='300' controls></video>" }
                default { $duplicateContent = "<pre>$(Get-Content -Path $duplicate -Raw)</pre>" }
            }
            
            $html += @"
        <tr>
            <td>$original<br/>$originalContent</td>
            <td>$duplicate<br/>$duplicateContent</td>
        </tr>
"@
        }
    }

    $html += @"
    </table>
</body>
</html>
"@

    $html | Out-File -FilePath $reportPath -Encoding utf8
    Write-Output "Report generated at: $reportPath"
    Start-Process $reportPath
}

function Find-DuplicateFiles {
    param (
        [string]$SourceDir
    )
    $fileHashes = @{}
    $duplicateFiles = @()

    $files = Get-ChildItem -Path $SourceDir -Recurse -File
    $totalFiles = $files.Count
    $processedFiles = 0

    foreach ($file in $files) {
        $processedFiles++
        Write-Progress -Activity "Processing Files" -Status "Computing hash for $($file.Name)" -PercentComplete (($processedFiles / $totalFiles) * 100)

        $hash = Get-FileHash -Path $file.FullName

        if ($fileHashes.ContainsKey($hash.Hash)) {
            $fileHashes[$hash.Hash] += , $file.FullName
        }
        else {
            $fileHashes[$hash.Hash] = @($file.FullName)
        }
    }

    foreach ($files in $fileHashes.Values) {
        if ($files.Count -gt 1) {
            $duplicateFiles += , @($files)
        }
    }

    return , $duplicateFiles
}

$duplicates = Find-DuplicateFiles -SourceDir $SourceDir
if ($MoveDuplicates) {
    Move-Duplicates -DuplicateFiles $duplicates -SourceDir $SourceDir
}
else {
    Generate-Report -SourceDir $SourceDir -DuplicateFiles $duplicates
}

