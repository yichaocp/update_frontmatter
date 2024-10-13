<#
.SYNOPSIS
- Updates the front matter of Markdown (.md) files with the current date and time.

.DESCRIPTION
- The script is designed to be used as a pre-commit hook in TortoiseSVN to automatically update the front matter of Markdown files before committing changes.
- It will processes all Markdown (.md) files in the current directory that have been added or modified according to SVN status. It updates or adds a "lastUpdated" field in the front matter of each file with the current date and time in the format "yyyy-MM-ddTHH:mm:ssZ".
- This script does not take any parameters.
- The script assumes that the front matter is enclosed within "---" lines.
  - If a file does not have a front matter, it will be added at the beginning of the file.
  - If a file has a front matter but no "lastUpdated" field, the field will be added.
  - If a file already has a "lastUpdated" field, it will be updated with the current date and time.

.EXAMPLE
- .\update.ps1
- This will update the front matter of all added or modified Markdown files in the current directory with the current date and time.

.EXAMPLE
- Example of how to set up the commit hook in TortoiseSVN:
  1. Open TortoiseSVN settings.
  2. Navigate to "Hook Scripts".
  3. Add a new hook script for the "Commit" hook.
    - Command: powershell -ExecutionPolicy ByPass -File "\path\to\file.ps1"
  4. Set the path to this script.
  5. Save the settings.

.NOTES
- Ensure that the script has the necessary permissions to execute during the commit process.
- The script uses UTF-8 encoding for reading and writing files.
- If there are multiple lastUpdated fields in the FrontMatter, only the last one will be updated.
- The newly added lastUpdated field will be inserted at the last line of the FrontMatter.
- If there is no newline character at the end of the file, a newline character will be added as the end of the file.
- The script uses the current date and time in the "UTC" timezone format.
- The script is designed to be used with TortoiseSVN, but can be adapted for other version control systems.
- The script is designed to be used with Windows PowerShell, but can be adapted for other shells.
- The script is designed to be used with Markdown files, but can be adapted for other file types.

#>

# Get the current date and time
$dateTime = $(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Get the list of .md files for this commit
svn status | Select-String -Pattern "^[AM] .*\.md$" | ForEach-Object {
    # Remove svn status from list
    $filePath = $_.Line -replace "^[AM]\s+", ""
    $fileContent = Get-Content -Path $filePath -Encoding UTF8
    $frontMatterIndex = $null
    $lastUpdatedIndex = $null

    # Process non-empty file
    if ($fileContent -ne $null) {
        # Convert to ArrayList for processing
        $fileContent = [System.Collections.ArrayList]::new($fileContent)

        # Read the first 32 lines of the file to check for front matter
        for ($i = 0; $i -lt $fileContent.Count -and $i -lt 32; $i++) {
            if ($fileContent[$i] -match "^---$") {
                if ($frontMatterIndex -eq $false) {
                    # If there is a front matter end line, mark success
                    $frontMatterIndex = $true
                    break
                } else {
                    # If there is a front matter start line, mark pending
                    $frontMatterIndex = $false
                }
            } elseif ($frontMatterIndex -eq $null) {
                # If there is no front matter start line, mark failure
                break
            } elseif ($fileContent[$i].StartsWith("lastUpdated:")) {
                # If there is a lastUpdated field, mark the line
                $lastUpdatedIndex = $i
            }
        }
    }

    # Check the result
    if ($fileContent -eq $null) {
        $fileContent = [System.Collections.ArrayList]::new(@("---`r`n" + "lastUpdated: $dateTime`r`n" + "---`r`n"))
    } elseif ($frontMatterIndex -ne $true) {
        # If there is no front matter, add it
        $fileContent.Insert(0, "---`r`n" + "lastUpdated: $dateTime`r`n" + "---`r`n")
    } else {
        if ($lastUpdatedIndex -eq $null) {
            # If there is no lastUpdated field, add it
            $fileContent.Insert($i, "lastUpdated: $dateTime")
        } else {
            # If there is a lastUpdated field, update it
            $fileContent[$lastUpdatedIndex] = "lastUpdated: $dateTime"
        }
    }

    # Update file content
    $fileContent | Set-Content -Path $filePath -Encoding UTF8

    # Print result
    Write-Host "[$dateTime] Updated FrontMatter: $filePath"
}
# End of script