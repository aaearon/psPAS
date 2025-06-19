function Get-CredentialUsername {
<#
.SYNOPSIS
    Gets the username from a PSCredential object in a PowerShell version-compatible way.

.DESCRIPTION
    The Get-CredentialUsername function retrieves the username from a PSCredential object
    using the appropriate method based on the PowerShell version. In PowerShell 5.1 and
    earlier, direct access to the UserName property can fail, so this function uses
    GetNetworkCredential().UserName as a fallback.

.PARAMETER Credential
    The PSCredential object from which to extract the username.

.INPUTS
    System.Management.Automation.PSCredential
    You can pipe PSCredential objects to Get-CredentialUsername.

.OUTPUTS
    System.String
    Returns the username as a string, or $null if the credential is invalid.

.EXAMPLE
    $cred = New-Object System.Management.Automation.PSCredential ('testuser', (ConvertTo-SecureString 'password' -AsPlainText -Force))
    Get-CredentialUsername -Credential $cred
    
    Returns "testuser" on both PowerShell 5.1 and 7.x.

.EXAMPLE
    $cred | Get-CredentialUsername
    
    Uses pipeline input to get the username from the credential object.

.NOTES
    This function is designed to handle the PowerShell 5.1 compatibility issue where
    direct access to PSCredential.UserName property can fail with "Property 'UserName' 
    cannot be found" error. The function automatically detects the PowerShell version
    and uses the appropriate method.
    
    PowerShell 6.0+: Uses $Credential.UserName
    PowerShell 5.1 and earlier: Uses $Credential.GetNetworkCredential().UserName

.LINK
    Get-CredentialPassword
    Test-CredentialObject

#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [PSCredential]$Credential
    )
    
    process {
        # Handle null credential
        if ($null -eq $Credential) {
            return $null
        }
        
        try {
            # PowerShell 6.0+ supports direct UserName property access
            if ($PSVersionTable.PSVersion.Major -ge 6) {
                return $Credential.UserName
            } else {
                # PowerShell 5.1 and earlier - use GetNetworkCredential method
                return $Credential.GetNetworkCredential().UserName
            }
        }
        catch {
            Write-Warning "Failed to extract username from credential: $($_.Exception.Message)"
            return $null
        }
    }
}

function Get-CredentialPassword {
<#
.SYNOPSIS
    Gets the plain text password from a PSCredential object safely.

.DESCRIPTION
    The Get-CredentialPassword function retrieves the plain text password from a 
    PSCredential object using GetNetworkCredential().Password. This method works
    consistently across all PowerShell versions and is the recommended approach
    for extracting passwords from credential objects.

.PARAMETER Credential
    The PSCredential object from which to extract the password.

.INPUTS
    System.Management.Automation.PSCredential
    You can pipe PSCredential objects to Get-CredentialPassword.

.OUTPUTS
    System.String
    Returns the password as a plain text string, or $null if the credential is invalid.

.EXAMPLE
    $cred = New-Object System.Management.Automation.PSCredential ('testuser', (ConvertTo-SecureString 'password' -AsPlainText -Force))
    Get-CredentialPassword -Credential $cred
    
    Returns "password" as plain text.

.EXAMPLE
    $cred | Get-CredentialPassword
    
    Uses pipeline input to get the password from the credential object.

.NOTES
    This function uses GetNetworkCredential().Password which is the standard method
    for extracting plain text passwords from PSCredential objects across all
    PowerShell versions. The password is returned as plain text, so handle with care.

.LINK
    Get-CredentialUsername
    Test-CredentialObject

#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [PSCredential]$Credential
    )
    
    process {
        # Handle null credential
        if ($null -eq $Credential) {
            return $null
        }
        
        try {
            return $Credential.GetNetworkCredential().Password
        }
        catch {
            Write-Warning "Failed to extract password from credential: $($_.Exception.Message)"
            return $null
        }
    }
}

function Test-CredentialObject {
<#
.SYNOPSIS
    Tests whether a PSCredential object is valid and properly constructed.

.DESCRIPTION
    The Test-CredentialObject function validates that a PSCredential object is not null,
    has a valid username, and has a password. This is useful for testing scenarios where
    you need to verify credential objects before using them in authentication operations.

.PARAMETER Credential
    The PSCredential object to validate.

.INPUTS
    System.Management.Automation.PSCredential
    You can pipe PSCredential objects to Test-CredentialObject.

.OUTPUTS
    System.Boolean
    Returns $true if the credential is valid, $false otherwise.

.EXAMPLE
    $cred = New-Object System.Management.Automation.PSCredential ('testuser', (ConvertTo-SecureString 'password' -AsPlainText -Force))
    Test-CredentialObject -Credential $cred
    
    Returns $true as the credential is properly constructed.

.EXAMPLE
    Test-CredentialObject -Credential $null
    
    Returns $false as the credential is null.

.EXAMPLE
    $cred | Test-CredentialObject
    
    Uses pipeline input to test the credential object.

.NOTES
    This function performs basic validation to ensure the credential object is usable.
    It checks for null values, empty usernames, and empty passwords using version-safe
    methods that work across PowerShell 5.1 and 7.x.

.LINK
    Get-CredentialUsername
    Get-CredentialPassword

#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowNull()]
        [PSCredential]$Credential
    )
    
    process {
        # Check if credential is null
        if ($null -eq $Credential) {
            return $false
        }
        
        try {
            # Get username using version-safe method
            $username = Get-CredentialUsername -Credential $Credential
            if ([string]::IsNullOrWhiteSpace($username)) {
                return $false
            }
            
            # Check if password exists (not checking if it's empty as empty passwords might be valid)
            $password = Get-CredentialPassword -Credential $Credential
            if ($null -eq $password) {
                return $false
            }
            
            return $true
        }
        catch {
            return $false
        }
    }
}

function New-TestCredential {
<#
.SYNOPSIS
    Creates a PSCredential object for testing purposes.

.DESCRIPTION
    The New-TestCredential function creates a PSCredential object with specified username
    and password for use in test scenarios. This helper function simplifies credential
    creation in test files and ensures consistent credential object construction.

.PARAMETER Username
    The username for the credential object.

.PARAMETER Password
    The password for the credential object as a plain text string.

.PARAMETER SecurePassword
    The password for the credential object as a SecureString.

.INPUTS
    None
    This function does not accept pipeline input.

.OUTPUTS
    System.Management.Automation.PSCredential
    Returns a PSCredential object with the specified username and password.

.EXAMPLE
    New-TestCredential -Username 'testuser' -Password 'testpassword'
    
    Creates a credential object with username 'testuser' and password 'testpassword'.

.EXAMPLE
    $securePass = ConvertTo-SecureString 'testpassword' -AsPlainText -Force
    New-TestCredential -Username 'testuser' -SecurePassword $securePass
    
    Creates a credential object using a pre-existing SecureString password.

.NOTES
    This function is intended for testing purposes only. In production code, passwords
    should be handled securely and not passed as plain text parameters.

.LINK
    Get-CredentialUsername
    Get-CredentialPassword
    Test-CredentialObject

#>
    [CmdletBinding(DefaultParameterSetName = 'PlainText')]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'PlainText')]
        [AllowEmptyString()]
        [string]$Password,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'SecureString')]
        [System.Security.SecureString]$SecurePassword
    )
    
    try {
        if ($PSCmdlet.ParameterSetName -eq 'PlainText') {
            $securePass = ConvertTo-SecureString $Password -AsPlainText -Force
        } else {
            $securePass = $SecurePassword
        }
        
        return New-Object System.Management.Automation.PSCredential ($Username, $securePass)
    }
    catch {
        throw "Failed to create test credential: $($_.Exception.Message)"
    }
}

function Compare-Credential {
<#
.SYNOPSIS
    Compares two PSCredential objects for equality.

.DESCRIPTION
    The Compare-Credential function compares two PSCredential objects to determine if
    they have the same username and password. This is useful in test scenarios where
    you need to verify that credential objects match expected values.

.PARAMETER ReferenceCredential
    The reference PSCredential object to compare against.

.PARAMETER DifferenceCredential
    The PSCredential object to compare with the reference.

.INPUTS
    None
    This function does not accept pipeline input.

.OUTPUTS
    System.Boolean
    Returns $true if both credentials have the same username and password, $false otherwise.

.EXAMPLE
    $cred1 = New-TestCredential -Username 'user1' -Password 'pass1'
    $cred2 = New-TestCredential -Username 'user1' -Password 'pass1'
    Compare-Credential -ReferenceCredential $cred1 -DifferenceCredential $cred2
    
    Returns $true as both credentials have the same username and password.

.EXAMPLE
    $cred1 = New-TestCredential -Username 'user1' -Password 'pass1'
    $cred2 = New-TestCredential -Username 'user2' -Password 'pass1'
    Compare-Credential -ReferenceCredential $cred1 -DifferenceCredential $cred2
    
    Returns $false as the usernames are different.

.NOTES
    This function uses the version-safe credential helper functions to extract usernames
    and passwords, ensuring compatibility across PowerShell versions.

.LINK
    Get-CredentialUsername
    Get-CredentialPassword
    Test-CredentialObject

#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSCredential]$ReferenceCredential,
        
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSCredential]$DifferenceCredential
    )
    
    # Handle null cases
    if ($null -eq $ReferenceCredential -and $null -eq $DifferenceCredential) {
        return $true
    }
    
    if ($null -eq $ReferenceCredential -or $null -eq $DifferenceCredential) {
        return $false
    }
    
    try {
        # Compare usernames using version-safe method
        $refUsername = Get-CredentialUsername -Credential $ReferenceCredential
        $diffUsername = Get-CredentialUsername -Credential $DifferenceCredential
        
        if ($refUsername -ne $diffUsername) {
            return $false
        }
        
        # Compare passwords using version-safe method
        $refPassword = Get-CredentialPassword -Credential $ReferenceCredential
        $diffPassword = Get-CredentialPassword -Credential $DifferenceCredential
        
        return $refPassword -eq $diffPassword
    }
    catch {
        return $false
    }
}

# Functions are available for dot-sourcing in test files