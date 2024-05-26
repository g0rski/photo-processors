Script Name
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