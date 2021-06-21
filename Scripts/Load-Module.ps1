#Requires -Version 5.1

<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         Sebastian Gräf
  Creation Date:  21/06/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#------------------------------------------------------------[Parameters]---------------------------------------------------------

[CmdletBinding()]
Param
(
    [Parameter()][string]$Module
)

#---------------------------------------------------------[Initialisations]-------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
$VerbosePreference = "Continue"

# Dot Source required Function Libraries
. ..\Write-Log.ps1

#----------------------------------------------------------[Declarations]---------------------------------------------------------

#-----------------------------------------------------------[Functions]-----------------------------------------------------------

#-----------------------------------------------------------[Execution]-----------------------------------------------------------

Write-Log "Executing $($MyInvocation.MyCommand.Name)"

if (Get-Module | Where-Object { $_.Name -eq $Module }) {
    Write-Output "Module $Module is already imported."
}
else {
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $Module }) {
        Import-Module $Module -Verbose
    }
    else {
        if (Find-Module -Name $Module | Where-Object { $_.Name -eq $Module }) {
            Install-Module -Name $Module -Force -Verbose -Scope CurrentUser
            Import-Module $Module -Verbose
        }
        else {
            Write-Output "Module $Module not imported, not available and not in online gallery, exiting."
            EXIT 1
        }
    }
}

Write-Log "Finished executing $($MyInvocation.MyCommand.Name)"
