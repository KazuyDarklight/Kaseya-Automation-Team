#This script imports Wi-Fi profile, which is embedded into the body of script.
#Please make sure to edit settings in it, to align with real configuration.

$Path = "$env:TEMP\WiFiProfile.xml"

$Profile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<!-- Enter SSID name here -->
	<name>SSID_NAME</name>
	<SSIDConfig>
		<SSID>
			<!-- Enter SSID name here -->
			<name>SSID_NAME</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<!-- Enter connection mode: auto or manual -->
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<!-- Change encryption mode if required -->
				<authentication>WPA2PSK</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<!-- Enter Wi-Fi password here -->
				<keyMaterial>Password</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
	<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
		<enableRandomization>false</enableRandomization>
		<randomizationSeed>617551118</randomizationSeed>
	</MacRandomization>
</WLANProfile>
"@
function RemoveExistingFile() {
    if (Test-Path -Path $Path) {
        Remove-Item -Path $Path
    }
}

RemoveExistingFile

$Profile | Out-File -FilePath $Path

netsh wlan add profile filename=$Path

RemoveExistingFile