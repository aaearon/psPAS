function Test-CrossPlatformPath {
<#
.SYNOPSIS
    Tests if a path string is valid across different platforms using .NET path validation.

.DESCRIPTION
    The Test-CrossPlatformPath function validates path strings using .NET's System.IO.Path.GetFullPath() 
    method instead of PowerShell's Test-Path -IsValid, which can fail on Linux with Windows-style paths.
    
    This function provides cross-platform path validation that works consistently across Windows, Linux, 
    and macOS environments, making it suitable for PowerShell tests that need to run on multiple platforms.

.PARAMETER Path
    The path string to validate. Can be a relative or absolute path.

.INPUTS
    System.String
    You can pipe path strings to Test-CrossPlatformPath.

.OUTPUTS
    System.Boolean
    Returns $true if the path is valid, $false otherwise.

.EXAMPLE
    Test-CrossPlatformPath -Path "C:\Users\Documents\file.txt"
    
    Returns $true on Windows and $false on Linux/macOS due to the Windows-style path format.

.EXAMPLE
    Test-CrossPlatformPath -Path "/home/user/documents/file.txt"
    
    Returns $true on Linux/macOS and may return $false on Windows depending on the system configuration.

.EXAMPLE
    Test-CrossPlatformPath -Path ".\relative\path\file.txt"
    
    Tests a relative path and returns $true if it can be resolved to a valid full path.

.EXAMPLE
    "C:\Invalid|Path", "/valid/path", "relative\path" | Test-CrossPlatformPath
    
    Tests multiple paths via pipeline input and returns boolean results for each.

.NOTES
    This function is designed specifically for cross-platform PowerShell testing scenarios where 
    Test-Path -IsValid may not work consistently across different operating systems.
    
    The function uses .NET's path validation which is more permissive than PowerShell's native 
    path validation and works consistently across platforms.

.LINK
    Test-Path
    System.IO.Path

#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string]$Path
    )
    
    process {
        # Handle empty or null paths
        if ([string]::IsNullOrWhiteSpace($Path)) {
            return $false
        }
        
        # Use .NET path validation instead of Test-Path -IsValid
        try {
            [System.IO.Path]::GetFullPath($Path) | Out-Null
            return $true
        }
        catch {
            return $false
        }
    }
}

function Get-CrossPlatformPathSeparator {
<#
.SYNOPSIS
    Returns the appropriate path separator for the current platform.

.DESCRIPTION
    The Get-CrossPlatformPathSeparator function returns the directory separator character 
    appropriate for the current operating system. This is useful when constructing paths 
    that need to work across different platforms.

.INPUTS
    None

.OUTPUTS
    System.String
    Returns '\' on Windows and '/' on Linux/macOS.

.EXAMPLE
    $separator = Get-CrossPlatformPathSeparator
    $path = "folder1{0}folder2{0}file.txt" -f $separator
    
    Creates a path string using the appropriate separator for the current platform.

.EXAMPLE
    $paths = @("folder1", "folder2", "file.txt")
    $fullPath = $paths -join (Get-CrossPlatformPathSeparator)
    
    Joins path components using the platform-appropriate separator.

.NOTES
    This function provides a simple way to get the platform-appropriate path separator 
    without having to check the operating system manually.

.LINK
    System.IO.Path
    Join-Path

#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param()
    
    return [System.IO.Path]::DirectorySeparatorChar.ToString()
}

function Convert-PathToCurrentPlatform {
<#
.SYNOPSIS
    Converts a path string to use the appropriate separators for the current platform.

.DESCRIPTION
    The Convert-PathToCurrentPlatform function takes a path string and converts it to use 
    the directory separators appropriate for the current operating system. This is useful 
    when working with paths that may have been created on different platforms.

.PARAMETER Path
    The path string to convert.

.INPUTS
    System.String
    You can pipe path strings to Convert-PathToCurrentPlatform.

.OUTPUTS
    System.String
    Returns the path string with platform-appropriate separators.

.EXAMPLE
    Convert-PathToCurrentPlatform -Path "C:\Users\Documents\file.txt"
    
    On Windows: Returns "C:\Users\Documents\file.txt"
    On Linux/macOS: Returns "C:/Users/Documents/file.txt"

.EXAMPLE
    Convert-PathToCurrentPlatform -Path "/home/user/documents/file.txt"
    
    On Windows: Returns "\home\user\documents\file.txt"
    On Linux/macOS: Returns "/home/user/documents/file.txt"

.EXAMPLE
    "mixed/path\separators", "another\mixed/path" | Convert-PathToCurrentPlatform
    
    Converts multiple paths via pipeline input to use consistent separators.

.NOTES
    This function is useful for normalizing paths in cross-platform scenarios, but note 
    that it only changes separators and doesn't validate that the resulting path is 
    actually valid on the target platform.

.LINK
    Get-CrossPlatformPathSeparator
    Test-CrossPlatformPath

#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string]$Path
    )
    
    process {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            return $Path
        }
        
        $currentSeparator = [System.IO.Path]::DirectorySeparatorChar
        $alternateSeparator = [System.IO.Path]::AltDirectorySeparatorChar
        
        # Replace alternate separators with current platform separator
        if ($alternateSeparator -and $alternateSeparator -ne $currentSeparator) {
            $Path = $Path.Replace($alternateSeparator, $currentSeparator)
        }
        
        # Also handle the opposite case (replace the other common separator)
        if ($currentSeparator -eq '\') {
            $Path = $Path.Replace('/', '\')
        }
        else {
            $Path = $Path.Replace('\', '/')
        }
        
        return $Path
    }
}

function Test-PathFormat {
<#
.SYNOPSIS
    Tests whether a path string follows Windows or Unix/Linux format conventions.

.DESCRIPTION
    The Test-PathFormat function analyzes a path string to determine whether it follows 
    Windows-style (backslash separators, drive letters) or Unix/Linux-style (forward slash 
    separators, root-relative) formatting conventions.

.PARAMETER Path
    The path string to analyze.

.INPUTS
    System.String
    You can pipe path strings to Test-PathFormat.

.OUTPUTS
    System.String
    Returns "Windows", "Unix", or "Indeterminate" based on the path format.

.EXAMPLE
    Test-PathFormat -Path "C:\Users\Documents\file.txt"
    
    Returns "Windows" due to the drive letter and backslash separators.

.EXAMPLE
    Test-PathFormat -Path "/home/user/documents/file.txt"
    
    Returns "Unix" due to the root-relative path and forward slash separators.

.EXAMPLE
    Test-PathFormat -Path "relative/path"
    
    Returns "Indeterminate" as it could be valid on either platform.

.EXAMPLE
    "C:\Windows\Path", "/usr/bin/path", "relative\path", "another/relative" | Test-PathFormat
    
    Analyzes multiple paths and returns format classification for each.

.NOTES
    This function is useful for determining the likely origin platform of a path string, 
    which can be helpful in cross-platform testing scenarios.

.LINK
    Test-CrossPlatformPath
    Convert-PathToCurrentPlatform

#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [string]$Path
    )
    
    process {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            return "Indeterminate"
        }
        
        # Check for Windows-style characteristics
        $hasWindowsDrive = $Path -match '^[A-Za-z]:'
        $hasBackslashes = $Path.Contains('\')
        $hasForwardSlashes = $Path.Contains('/')
        $startsWithRoot = $Path.StartsWith('/')
        
        # Windows path indicators
        if ($hasWindowsDrive -or ($hasBackslashes -and -not $hasForwardSlashes)) {
            return "Windows"
        }
        
        # Unix/Linux path indicators
        if ($startsWithRoot -or ($hasForwardSlashes -and -not $hasBackslashes)) {
            return "Unix"
        }
        
        # Mixed or unclear
        if ($hasBackslashes -and $hasForwardSlashes) {
            return "Mixed"
        }
        
        # Relative path without clear indicators
        return "Indeterminate"
    }
}

# Functions are available for dot-sourcing in test files