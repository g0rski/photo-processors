# Table of Contents
- [duplicate_finder](#duplicate_finder)
- [media_sorter](#media_sorter)

#duplicate_finder
=======================================

Description
-----------

This PowerShell script is designed to identify duplicate files within a specified directory. It can either generate a detailed HTML report listing the duplicate files or move the duplicate files to a separate directory within the source directory. The script calculates the hash values of files to determine duplicates.

Parameters
----------

-   SourceDir (string, Mandatory): The directory path where the script will search for duplicate files.
-   MoveDuplicates (bool, Optional): If set to `true`, the script will move the duplicate files to a "duplicates" folder within the source directory. If set to `false` or omitted, the script will generate an HTML report.

Usage
-----

powershell

Copy code

`.\duplicate_finder.ps1 -SourceDir "C:\Path\To\Directory" [-MoveDuplicates $true]`

### Examples

1.  Generate an HTML report of duplicate files in the specified directory:

    powershell

    Copy code

    `.\duplicate_finder.ps1 -SourceDir "C:\Path\To\Directory"`

2.  Move duplicate files to a "duplicates" directory within the specified directory:

    powershell

    Copy code

    `.\duplicate_finder.ps1 -SourceDir "C:\Path\To\Directory" -MoveDuplicates $true`

Functions
---------

### Find-DuplicateFiles

This function scans the specified directory and computes the hash values for all files. It returns an array of groups of duplicate files.

Parameters:

-   `SourceDir` (string): The directory to scan for duplicate files.

Returns:

-   Array of arrays containing paths of duplicate files.

### Move-Duplicates

This function moves the identified duplicate files to a "duplicates" folder within the specified source directory.

Parameters:

-   `DuplicateFiles` (array): An array of groups of duplicate files.
-   `SourceDir` (string): The source directory.

### Generate-Report

This function generates an HTML report listing all duplicate files, including previews for images and videos.

Parameters:

-   `DuplicateFiles` (array): An array of groups of duplicate files.
-   `SourceDir` (string): The source directory.

Detailed Process
----------------

1.  Trim Input Path:

    powershell

    Copy code

    `$SourceDir = $SourceDir.Trim()`

2.  Find Duplicate Files:

    -   Recursively scan all files in the specified directory.
    -   Compute hash values for each file.
    -   Group files by their hash values to identify duplicates.
3.  Move Duplicates or Generate Report:

    -   If `MoveDuplicates` is set to `true`, call `Move-Duplicates` function to move duplicates.
    -   If `MoveDuplicates` is `false` or omitted, call `Generate-Report` function to create an HTML report.

### Progress Indicator

While computing file hashes, a progress bar is displayed to indicate the progress of the operation.

Output
------

-   HTML Report:

    -   Generated in the source directory with the naming format `report_yyyyMMdd_HHmmss.html`.
    -   Includes a table listing original and duplicate files with previews for image and video files.
-   Moved Files:

    -   Duplicate files are moved to a subdirectory named "duplicates" within the source directory.
    -   Console output indicates the source and destination of moved files.

Notes
-----

-   Ensure the script has the necessary permissions to read from and write to the specified directories.
-   The script supports common image and video formats for previews in the HTML report.
-   For non-media files, the content is displayed as plain text in the report.

Example Output
--------------

text

Copy code

`Duplicate files moved successfully to 'duplicates' directory in 'C:\Path\To\Directory'.`

Or, upon generating the report:

text

Copy code

`Report generated at: C:\Path\To\Directory\report_20240526_123456.html`

License
-------

This script is provided "as-is" without warranty of any kind. Use at your own risk.

media_sorter
===========

Purpose
-------

This PowerShell script is designed to organize media files from specified source directories into a structured output directory based on the creation date of the files. It supports various file formats including images and videos, and it handles duplicate files by comparing their contents. The script also cleans up empty source directories after processing.

Features
--------

-   Organizes files by year and month based on the creation date.
-   Supports multiple media file formats: JPG, JPEG, MP4, MOV, WMV, RAW, BMP.
-   Compares file contents to avoid exact duplicates in the destination directory.
-   Renames duplicates by appending `_duplicate` or `_copy` to the filename.
-   Removes empty source directories or renames them after processing.

Parameters
----------

-   `SourceDirs` (string[]): An array of source directories containing the media files to be organized. This parameter is mandatory.
-   `OutputDir` (string): The output directory where the organized files will be stored. This parameter is mandatory.

Usage
-----

powershell

Copy code

`.\media_sorter.ps1 -SourceDirs "C:\SourceDir1", "C:\SourceDir2" -OutputDir "D:\OutputDir"`

Detailed Description
--------------------

1.  Parameter Validation:

    -   Ensures that the `OutputDir` exists. If not, it exits with an error message.
    -   Validates each `SourceDir` exists before processing.
2.  File Processing:

    -   For each source directory:
        -   Checks for supported file formats (`*.jpg`, `*.jpeg`, `*.mp4`, `*.mov`, `*.wmv`, `*.raw`, `*.bmp`).
        -   Extracts the creation date of each file to determine the target year and month directories.
        -   Creates the year/month directory structure in the `OutputDir` if it doesn't exist.
        -   Moves files to the appropriate directory. If a file with the same name exists, it compares the file contents using `Get-FileHash`:
            -   If files are identical, appends `_duplicate` to the filename.
            -   If files differ, appends `_copy` to the filename to create a unique name.
3.  Directory Cleanup:

    -   After processing files in a source directory, checks if the directory is empty:
        -   If empty, removes the directory.
        -   If not empty, renames the directory by appending `_done`.
4.  Logging:

    -   Outputs informative messages during each step, including creation of directories, moving files, handling duplicates, and cleaning up directories.
    -   Logs warnings if any file or directory operations fail.

Example
-------

Given the following command:

powershell

Copy code

`.\OrganizeMedia.ps1 -SourceDirs "C:\Photos", "C:\Videos" -OutputDir "D:\OrganizedMedia"`

The script will:

-   Process files in `C:\Photos` and `C:\Videos`.
-   Organize them into `D:\OrganizedMedia\Year\Month` directories based on their creation dates.
-   Handle duplicates and rename them accordingly.
-   Remove or rename the source directories upon completion.

Notes
-----

-   Ensure that you have the necessary permissions to read from the source directories and write to the output directory.
-   The script handles errors gracefully and provides warnings for any issues encountered during processing.

License
-------

This script is provided as-is without any warranty. Use at your own risk. Modify and distribute as needed.

* * * * *

Replace `media_sorter.ps1` with the actual name of your script file. Adjust the paths in the usage examples to match your environment.