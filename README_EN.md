## DESCRIPTION

- The script is designed to be used as a pre-commit hook in TortoiseSVN to automatically update the front matter of Markdown files before committing changes.

- It will processes all Markdown (.md) files in the current directory that have been added or modified according to SVN status. It updates or adds a "lastUpdated" field in the front matter of each file with the current date and time in the ISO8601 format "yyyy-MM-ddTHH:mm:ssZ".

- The script assumes that the front matter is enclosed within "---" lines.
  - If a file does not have a front matter, it will be added at the beginning of the file.
  - If a file has a front matter but no "lastUpdated" field, the field will be added.
  - If a file already has a "lastUpdated" field, it will be updated with the current date and time.

### EXAMPLE

- .\update.ps1
- This will update the front matter of all added or modified Markdown files in the current directory with the current date and time.

### EXAMPLE

- Example of how to set up the commit hook in TortoiseSVN:

  1. Open TortoiseSVN settings.
  2. Navigate to "Hook Scripts".
  3. Add a new hook script for the "Commit" hook.
     ```powershell
     powershell -ExecutionPolicy ByPass -File "\path\to\file.ps1"
     ```
  4. Set the path to this script.
  5. Save the settings.

### NOTES

- Ensure that the script has the necessary permissions to execute during the commit process.
- The script uses UTF-8 encoding for reading and writing files.
- The script will check up to the first 32 lines of the file; any front matter beyond this range will be considered invalid.
- If there are multiple lastUpdated fields in the FrontMatter, only the last one will be updated.
- The newly added lastUpdated field will be inserted at the last line of the FrontMatter.
- If there is no newline character at the end of the file, a newline character will be added as the end of the file.
- The script uses the current date and time in the "UTC" timezone format.
- The script is designed to be used with TortoiseSVN, but can be adapted for other version control systems.
- The script is designed to be used with Windows PowerShell, but can be adapted for other shells.
- The script is designed to be used with Markdown files, but can be adapted for other file types.

### EXPLAIN

This PowerShell script is primarily designed to update the front matter (header information) of all `.md` files in an SVN repository, specifically to update or add the `lastUpdated` field.

First, the script uses `Get-Date` to get the current date and time and stores it in the `$dateTime` variable. Then, it uses the `svn status` command to get a list of all `.md` files in the current commit and filters out the newly added or modified `.md` files using `Select-String -Pattern "^[AM] .*\.md$"`.

For each file, the script first removes the SVN status information, leaving only the file path. Then, it reads the file content and stores it in the `$fileContent` variable. For ease of processing, the file content is converted to an [`ArrayList`] type.

Next, the script checks the first 32 lines of the file for front matter. If it finds the start and end markers (`---`) of the front matter, it marks `$frontMatterIndex` as [`true`]. If it finds the `lastUpdated` field, it records the line number where it is located.

Based on the inspection results, the script performs different actions:

1. If the file content is empty, it creates a new front matter and adds the `lastUpdated` field.
2. If the file does not have front matter, it inserts a new front matter at the beginning of the file and adds the `lastUpdated` field.
3. If the file has front matter but does not have the `lastUpdated` field, it inserts the `lastUpdated` field at the appropriate location.
4. If the file already has the `lastUpdated` field, it updates its value to the current date and time.

Finally, the script writes the updated content back to the file and outputs the update results.
