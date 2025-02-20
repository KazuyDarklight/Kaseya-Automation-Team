#The script installs Slack on the target machine
param (
    [parameter(Mandatory=$true)]
    [string] $Path
)

Function Get-InstallStatus {
    Return  (Get-Package | Where-Object {$_.Name -eq "Slack"} | Select-Object -Property Status).Status
}

$status = Get-InstallStatus

if ($Status -ne "Installed") {
     
     Write-Output "Slack is not installed on this computer and proceeding with the insallation steps!"

     #Run the install command
     Start-Process -FilePath $Path -ArgumentList '-S'
     Start-Sleep -Seconds 20

     #Check the install status again
     $status = Get-InstallStatus


    if ($Status -eq "Installed") {
        Write-Output "Installation has been successully completed"
    } else {
        Write-Output "Installation could not be completed"
    }

 }

# If Slack is already installed, show the message and do nothing.
 else {
     Write-Output "Slack is already installed on this computer"
 }