# Get Args

$StorageName = $args[0]
$StorageFileShareName = $args[1]
$StorageAccountKey = $args[2]
$ConnectionString = $args[3]
$UserName = $args[4]
$Email = $args[5]
$Password = $args[6]
$LicenseKey = $args[7]

$StorageDirectoryName = "octoha"
$LogFileLocation = "C:\log.txt"

# Log Args to File

"Begin Running Scripts" | Out-File -FilePath $LogFileLocation -append

(-join("Storage Account Name = ", $StorageName)) | Out-File -FilePath $LogFileLocation -append
(-join("Storage File Share Name = ", $StorageFileShareName)) | Out-File -FilePath $LogFileLocation -append
(-join("Account Key = ", $StorageAccountKey)) | Out-File -FilePath $LogFileLocation -append
(-join("Connection String = ", $ConnectionString)) | Out-File -FilePath $LogFileLocation -append
(-join("Username = ", $UserName)) | Out-File -FilePath $LogFileLocation -append
(-join("Email = ", $Email)) | Out-File -FilePath $LogFileLocation -append
(-join("Password = ", $Password)) | Out-File -FilePath $LogFileLocation -append
(-join("License Key = ", $LicenseKey)) | Out-File -FilePath $LogFileLocation -append

# 01 - Add Symbolic Links

"01 - Add Symbolic Links" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/01_addsymboliclinks.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\01_addsymboliclinks.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath, "$storageName", "$StorageAccountKey", "$StorageFileShareName", "$StorageDirectoryName")

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# 02 - Install Octopus

"02 - Install Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/02_installoctopus.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\02_installoctopus.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath)

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# 03 - Setup Octopus

"03 - Setup Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/03_setupOctopus_VM1.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\03_setupOctopus_VM1.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath, """$ConnectionString""", "$UserName", "$Email", "$Password", """$LicenseKey""")

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# 04 - Add Firewall Rules

"04 - Add Firewall Rules" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/04_addFirewallRules.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\04_addFirewallRules.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath)

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# 05 - Get Master Key

"05 - Get Master Key" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/pjgpetecodes/octopusdeploy_ha/main/vm_scripts/05_getMasterKey.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\05_getMasterKey.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath)

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow