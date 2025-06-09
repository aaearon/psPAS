# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

psPAS is a PowerShell module for the CyberArk Privileged Access Security (PAS) REST API. It provides comprehensive PowerShell cmdlets to interact with CyberArk's PVWA (Password Vault Web Access) through REST API calls. The module supports CyberArk versions up to v14.0 and includes over 250 functions covering accounts, safes, users, platforms, authentication, monitoring, and more.

## Development Commands

### Build and Test
```powershell
# Install dependencies
pwsh.exe -File .\build\install.ps1

# Build the module (updates version, packages, and signs if configured)
pwsh.exe -File .\build\build.ps1

# Run tests
pwsh.exe -File .\build\test.ps1

# Deploy to GitHub (creates release and uploads artifacts)
pwsh.exe -File .\build\deploy-github.ps1

# Deploy to PowerShell Gallery
pwsh.exe -File .\build\deploy-psgallery.ps1
```

### Testing
```powershell
# Run all Pester tests
Invoke-Pester -Path .\Tests -Output Minimal

# Test specific function
Invoke-Pester -Path .\Tests\Add-PASAccount.Tests.ps1
```

### Module Development
```powershell
# Import module for development
Import-Module .\psPAS\psPAS.psd1 -Force

# View all module functions
Get-Command -Module psPAS

# Test module manifest
Test-ModuleManifest .\psPAS\psPAS.psd1
```

## Architecture

### Module Structure
- **Functions/**: Core cmdlet implementations organized by functional area
  - `AccountACL/`, `Accounts/`, `Applications/`, `Authentication/`, etc.
  - Each folder contains related PowerShell functions (.ps1 files)
- **Private/**: Internal utility functions not exposed to users
- **xml/**: Type and format definitions for custom PowerShell objects
- **Tests/**: Pester test files (one per function)

### Key Components

#### Session Management
- `$psPASSession` script variable stores session state (BaseURI, tokens, etc.)
- Session object is typed as `psPAS.CyberArk.Vault.Session`
- Functions `New-PASSession`, `Get-PASSession`, `Use-PASSession`, `Close-PASSession`

#### REST API Wrapper
- `Invoke-PASRestMethod` is the core HTTP client function in `Private/`
- Handles authentication, error processing, and response formatting
- All public functions ultimately call this for API communication

#### Object Type System
- Custom PowerShell types for CyberArk objects (Account, Safe, User, etc.)
- Type definitions in `xml/*.Type.ps1xml` files
- Format definitions in `xml/*.Formats.ps1xml` files
- Objects have methods like `.SafeMembers()` for related queries

#### Version Compatibility
- Functions use `Assert-VersionRequirement` to check CyberArk version compatibility
- Version checks prevent unsupported API calls
- Minimum version requirements documented in function help

### Function Patterns

#### Standard Function Structure
```powershell
function Verb-PASNoun {
    [CmdletBinding()]
    param(
        # Parameters with proper typing and validation
    )
    
    # Build request object
    $Request = @{
        'URI' = "$($psPASSession.BaseURI)/api/endpoint"
        'Method' = 'POST'
        'Body' = $RequestBody | ConvertTo-Json -Depth 4
    }
    
    # Make API call
    $Response = Invoke-PASRestMethod @Request
    
    # Process and return results
    $Response | Add-ObjectDetail -typename psPAS.CyberArk.Vault.ObjectType
}
```

#### Common Patterns
- Parameter validation with `[ValidateScript()]` and `[ValidateSet()]`
- Version requirement assertions using `Assert-VersionRequirement`
- JSON request body construction
- Response processing with custom object types
- Pipeline support via `ValueFromPipelineByPropertyName`

## Testing

### Test Structure
- One test file per function in `Tests/` directory
- Tests use Pester framework with Describe/Context/It blocks
- Mock external dependencies and API calls
- Test parameter validation, version requirements, and output formatting

### Running Tests
Tests are executed via the build system using Pester with NUnit XML output for CI integration.

## Deployment

### Versioning
- Version format: `Major.Minor.Build` (e.g., 6.4.85)
- Build number auto-incremented in CI
- Versions must increase for successful deployments

### Publishing
- **PowerShell Gallery**: Automated publishing for releases ≥ 1.0.0 from master branch
- **GitHub Releases**: Creates releases with ZIP artifacts
- **Code Signing**: Authenticode signing (when configured)

## Development Guidelines

### Development Strategy
- **Test-Driven Development (TDD)**: Write tests first, then implement functionality
  - Create Pester tests before writing the actual function
  - Ensure tests cover all parameters, edge cases, and error conditions
  - Tests should validate both successful operations and error handling
  - Run tests frequently during development to ensure code quality

### Version Control Workflow
- **Feature Branch Workflow**: All development should follow feature branch strategy
  - Create feature branches from master for new functionality
  - Branch naming: `feature/add-new-function` or `fix/issue-description`
  - Make small, focused commits with clear commit messages
  - Submit pull requests for code review before merging to master
  - Only merge to master after tests pass and code review is complete

### Function Development
- Follow PowerShell approved verbs (`Get-Verb`)
- Use proper parameter validation and help documentation
- Include version compatibility checks for new CyberArk features
- Support pipeline input where logical
- Return typed objects with proper formatting

### API Integration
- New endpoints should follow existing REST wrapper patterns
- Handle API versioning and compatibility properly
- Include proper error handling and meaningful error messages
- Test with multiple CyberArk versions when possible

### Module Organization
- Place functions in appropriate functional directories
- Update module manifest export lists for new functions
- Add corresponding Pester tests
- Update help documentation and examples