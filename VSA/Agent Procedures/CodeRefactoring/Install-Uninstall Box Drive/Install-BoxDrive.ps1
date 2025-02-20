## This script downloads and silently installs Box Drive

#Define variables
$AppName = "Box Drive"
$AppNameWithWildCard = "Box"
$URL = ""
$Destination = "$env:TEMP\boxdrive.msi"

#Create VSA Event Source if it doesn't exist
if ( -not [System.Diagnostics.EventLog]::SourceExists("VSA X")) {
    [System.Diagnostics.EventLog]::CreateEventSource("VSA X", "Application")
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
    return Get-RegistryRecords($AppNameWithWildCard);
}

#Start download
function Get-Installer($URL) {

    Write-Host "Downloading $AppName installer."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URL -OutFile "$Destination"

    if (Test-Path -Path $Destination) {

        Start-Install
    } else {

        [System.Diagnostics.EventLog]::WriteEntry("VSA X", "Unable to download $AppName installation file.", "Error", 400)
    }
}

#Execute installer
function Start-Install() {

    Write-Host "Starting $AppName installation."
    Start-Process -FilePath "MsiExec.exe" -ArgumentList "/i $Destination /quiet /qn /norestart /log $env:TEMP\Zoom-Install.log" -Wait
}

#Delete installation file
function Start-Cleanup() {

    Write-Host "Removing installation files."
    Remove-Item -Path $Destination -ErrorAction SilentlyContinue
}

#If application is not installed yet, continue with installation
if (Test-IsInstalled -ne $null) {

    [System.Diagnostics.EventLog]::WriteEntry("VSA X", "$AppName is already installed on the target computer, not proceeding with installation.", "Warning", 300)
    Write-Host "$AppName is already installed on the target computer, not proceeding with installation."

    break

} else {
    
    [System.Diagnostics.EventLog]::WriteEntry("VSA X", "$AppName installation process has been initiated by VSA script", "Information", 200)

    Get-Installer($URL)
    Start-Cleanup
    
    Start-Sleep -s 10

    $Installed = Test-IsInstalled

    #Verify that application has been successfully installed
    if ($null -eq $Installed) {

        [System.Diagnostics.EventLog]::WriteEntry("VSA X", "Couldn't install $AppName on the target computer.", "Error", 400)
        Write-Host "Couldn't install $AppName on the target computer."

    } else {
        [System.Diagnostics.EventLog]::WriteEntry("VSA X", "$AppName has been successfully installed.", "Information", 200)
        Write-Host "$AppName has been successfully installed."
    }
}