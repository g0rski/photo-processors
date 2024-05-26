param (
    [Parameter(Mandatory = $true)]
    [string[]]$SourceDirs,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir
)

function Compare-Files {
    param (
        [string]$Path1,
        [string]$Path2
    )

    $hash1 = Get-FileHash -Path $Path1
    $hash2 = Get-FileHash -Path $Path2

    return $hash1.Hash -eq $hash2.Hash
}


if (-not (Test-Path -Path $OutputDir)) {
    Write-Error "Ścieżka docelowa $OutputDir nie istnieje. Upewnij się, że podałeś poprawną ścieżkę."
    exit
}

foreach ($SourceDir in $SourceDirs) {
    # Sprawdzenie, czy ścieżka źródłowa istnieje
    if (-not (Test-Path -Path $SourceDir)) {
        Write-Error "Ścieżka źródłowa $SourceDir nie istnieje. Upewnij się, że podałeś poprawną ścieżkę."
        exit
    }

    # Wzorce plików do przetwarzania
    $filePatterns = @("*.jpg", "*.jpeg", "*.mp4", "*.mov", "*.wmv", "*.raw", "*.bmp")

    # Pobierz wszystkie pliki zgodne z wzorcami
    $files = Get-ChildItem -Path $SourceDir -Include $filePatterns -Recurse

    if ($files.Count -eq 0) {
        Write-Output "Nie znaleziono plików zgodnych z wzorcami w katalogu $SourceDir."
        exit
    }

    foreach ($file in $files) {
        try {
            # Pobierz datę wykonania zdjęcia lub wideo z metadanych
            $dateTaken = $file.CreationTime #użyj daty utworzenia pliku

            # Uzyskaj rok i miesiąc z daty
            $year = $dateTaken.Year
            $month = $dateTaken.Month

            # Ustal ścieżkę do katalogu docelowego (rok/miesiąc)
            $destinationDir = "$OutputDir\$year\$month"

            # Sprawdź, czy katalog docelowy istnieje, jeśli nie - utwórz go
            if (-not (Test-Path -Path $destinationDir)) {
                New-Item -Path $destinationDir -ItemType Directory
                Write-Output "Utworzono katalog: $destinationDir"
            }

            # Przenieś plik do odpowiedniego katalogu
            $destinationPath = Join-Path -Path $destinationDir -ChildPath $file.Name

            if (Test-Path -Path $destinationPath) {
                # If the file exists, compare contents
                if (Compare-Files -Path1 $file.FullName -Path2 $destinationPath) {
                    # If files are the same, add _duplicate to the file name
                    $destinationPath = Join-Path -Path $destinationDir -ChildPath "$($file.BaseName)_duplicate$($file.Extension)"
                }
                else {
                    # Generate a unique name if files are different
                    $destinationPath = [System.IO.Path]::Combine($destinationDir, [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + "_copy" + [System.IO.Path]::GetExtension($file.Name))
                }
            }

            Move-Item -Path $file.FullName -Destination $destinationPath
            Write-Output "Przeniesiono plik: $file -> $destinationPath"
        }
        catch {
            Write-Warning "Nie udało się przetworzyć pliku $($file.FullName): $_"
        }
    }

    $remainingItems = Get-ChildItem -Path $SourceDir -Recurse
    if ($remainingItems.Count -eq 0) {
        try {
            Remove-Item -Path $SourceDir -Recurse
            Write-Output "Usunięto pusty katalog: $SourceDir"
        }
        catch {
            Write-Warning "Nie udało się usunąć katalogu $SourceDir : $_"
        }
    } 
    else {
        try {
            $newSourceDir = "$SourceDir`_done"
            Rename-Item -Path $SourceDir -NewName $newSourceDir
            Write-Output "Zmieniono nazwę katalogu: $SourceDir -> $newSourceDir"
        }
        catch {
            Write-Warning "Nie udało się zmienić nazwy katalogu $SourceDir : $_"
        }
    }
}

Write-Output "Operacja zakończona."
