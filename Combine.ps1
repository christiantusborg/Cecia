# ================================
# PowerShell Script to Combine .dm Files
# ================================

# Define the source folder containing .dm files
$sourceFolder = "D:\Cecia\Lore\Religion"

# Define the destination file path
$destinationFile = "D:\Cecia\combined_Religion.dm"  # Changed to .dm as per original request

# Function to display messages with timestamp
function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] [$Type] $Message"
}

# Ensure the destination directory exists
$destinationDir = Split-Path -Path $destinationFile
if (!(Test-Path -Path $destinationDir)) {
    try {
        New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
        Write-Log "Created destination directory: $destinationDir" "INFO"
    }
    catch {
        Write-Log "Failed to create destination directory: $_" "ERROR"
        exit 1
    }
}

# Check if the destination file exists; if so, remove it to start fresh
if (Test-Path -Path $destinationFile) {
    try {
        Remove-Item -Path $destinationFile -Force
        Write-Log "Removed existing file: $destinationFile" "INFO"
    }
    catch {
        Write-Log "Failed to remove existing destination file: $_" "ERROR"
        exit 1
    }
}

# Retrieve all .dm files recursively from the source folder
try {
    $dmFiles = Get-ChildItem -Path $sourceFolder -Filter *.md -Recurse -ErrorAction Stop
    if ($dmFiles.Count -eq 0) {
        Write-Log "No .dm files found in the source folder: $sourceFolder" "WARNING"
        exit 0
    }
    else {
        Write-Log "Found $($dmFiles.Count) .dm file(s) to combine." "INFO"
    }
}
catch {
    Write-Log "Error retrieving .dm files: $_" "ERROR"
    exit 1
}

# Combine the contents of all .dm files into the destination file
foreach ($file in $dmFiles) {
    try {
        # Add a separator with the filename
        Add-Content -Path $destinationFile -Value "`n`n----- Content from: $($file.FullName) -----`n" -ErrorAction Stop
        # Append the content of the current .dm file
        Get-Content -Path $file.FullName -ErrorAction Stop | Add-Content -Path $destinationFile -ErrorAction Stop
        Write-Log "Added content from: $($file.FullName)" "INFO"
    }
    catch {
        Write-Log "Failed to add content from $($file.FullName): $_" "ERROR"
    }
}

Write-Log "All .dm files have been combined into $destinationFile" "SUCCESS"
