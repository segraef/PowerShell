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
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#------------------------------------------------------------[Parameters]---------------------------------------------------------

[CmdletBinding()]
Param
(
    [Parameter()][string]$String,
    [Parameter()][securestring]$SecureString
)

#---------------------------------------------------------[Initialisations]-------------------------------------------------------

# Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Dot Source required Function Libraries
. ..\Write-Log.ps1 > $null

#----------------------------------------------------------[Declarations]---------------------------------------------------------

#-----------------------------------------------------------[Functions]-----------------------------------------------------------

Function FunctionName {
    Param()
  
    Begin {
        Write-Log "Let's start !"
    }
  
    Process {
        Try {
            Write-Output "Hello Template !"
        }
    
        Catch {
            Write-Log "$_.Exception" -Warning
            Break
        }
    }
  
    End {
        If ($?) {
            Write-Log "Completed successfully !"
        }
    }
}

#-----------------------------------------------------------[Execution]----------------------------------------------------------

Write-Log "Executing $($MyInvocation.MyCommand.Name)"

FunctionName

Write-Log "Finished executing $($MyInvocation.MyCommand.Name)"