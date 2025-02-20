## This script downloads and silently installs latest version of Google Drive installer from the official website
param (
    [parameter(Mandatory=$true)]
    [string] $Path
)
#Define variables
$AppName = "Google Drive"

#Create VSA X Event Source if it doesn't exist
if ( -not [System.Diagnostics.EventLog]::SourceExists("VSA")) {
    [System.Diagnostics.EventLog]::CreateEventSource("VSA", "Application")
}

function Get-RegistryRecords {
    Param($productDisplayNameWithWildcards)

    $machine_key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key6432 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

    return Get-ItemProperty -Path @($machine_key, $machine_key6432) -ErrorAction SilentlyContinue |
           Where-Object {
              $_.DisplayName -like $productDisplayNameWithWildcards
           } | Sort-Object -Property @{Expression = {$_.DisplayVersion}; Descending = $True} | Select-Object -First 1
}


#Lookup related records in Windows Registry to check if application is already installed
function Test-IsInstalled(){
    return Get-RegistryRecords($AppName);
}

#If application is not installed yet, continue with installation
if (Test-IsInstalled -ne $null) {

    [System.Diagnostics.EventLog]::WriteEntry("VSA", "$AppName is already installed on the target computer, not proceeding with installation.", "Warning", 300)
    Write-Output "$AppName is already installed on the target computer, not proceeding with installation."
} else {
    
    [System.Diagnostics.EventLog]::WriteEntry("VSA", "$AppName installation process has been initiated by VSA X script", "Information", 200)

    Start-Process -FilePath $Path -ArgumentList "--silent --desktop_shortcut" -Wait
    
    Start-Sleep -s 10

    $Installed = Test-IsInstalled

    #Verify that application has been successfully installed
    if ($null -eq $Installed) {

        [System.Diagnostics.EventLog]::WriteEntry("VSA", "Couldn't install $AppName on the target computer.", "Error", 400)
        Write-Output "Couldn't install $AppName on the target computer."

    } else {
        [System.Diagnostics.EventLog]::WriteEntry("VSA", "$AppName has been successfully installed.", "Information", 200)
        Write-Output "$AppName has been successfully installed."
    }
}