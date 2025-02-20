<#
.Synopsis
   Deletes named vpn connection
.DESCRIPTION
   This script is dedicated to delete VPN connection with a given name from the target system
.NOTES
   Version 0.1
   Author: Proserv Team - VS
#>

[string]$Name = "test"

#Create VSA X Event Source if it doesn't exist
if ( -not [System.Diagnostics.EventLog]::SourceExists("VSA X")) {
    [System.Diagnostics.EventLog]::CreateEventSource("VSA X", "Application")
}

$Exists = Get-VpnConnection -AllUserConnection| Select-Object -Property Name|Where-Object {$_.Name -eq $Name}

if ($Exists) {
    try {
        Remove-VpnConnection -AllUserConnection -Name $Name -Force -ErrorAction Stop
        Write-Output "VPN connection $Name has been successfully removed."
        [System.Diagnostics.EventLog]::WriteEntry("VSA X", "VPN connection $Name has been successfully removed.", "Information", 200)
    } catch {
        Write-Output "Unable to delete:"$_.Exception.Message
        [System.Diagnostics.EventLog]::WriteEntry("VSA X", "Unable to delete VPN connection.", "Error", 400)
    }

} else {
    Write-Output "VPN connection $Name doesn't exist on this computer."
    [System.Diagnostics.EventLog]::WriteEntry("VSA X", "VPN connection $Name doesn't exist on this computer.", "Error", 400)
}