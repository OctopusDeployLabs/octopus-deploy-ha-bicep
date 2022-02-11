$serverNodeName = $env:computername
$connectionString = $args[0]
$username = $args[1]
$email = $args[2]
$password = $args[3]
$licenseKeySafe = $args[4]

$LicenseKey = $LicenseKeySafe.replace('|', '"')

$licenseKeyBytes = [Text.Encoding]::Unicode.GetBytes($LicenseKey)
$licenseKeyBase64 = [System.Convert]::ToBase64String($licenseKeyBytes)

$LogFileLocation = "C:\log.txt"

# Log Args to File

"Beginning Setup Octopus Script" | Out-File -FilePath $LogFileLocation -append

(-join("Server Node Name = ", $serverNodeName)) | Out-File -FilePath $LogFileLocation -append
(-join("Connection String = ", $connectionString)) | Out-File -FilePath $LogFileLocation -append
(-join("Username = ", $username)) | Out-File -FilePath $LogFileLocation -append
(-join("License Key (Safe) = ", $licenseKeySafe)) | Out-File -FilePath $LogFileLocation -append
(-join("License Key = ", $LicenseKey)) | Out-File -FilePath $LogFileLocation -append

# Create Instance

Write-Output "Creating Instance"
Write-Output (-join("Server Name = ", $serverNodeName))

$octoargs = @("create-instance",
          "--instance",
          '"OctopusServer"',
          "--config",
          '"C:\Octopus\OctopusServer.config"',
          "--serverNodeName",
          $serverNodeName)
          
Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Configure Database

Write-Output "Configuring Database"
Write-Output (-join("Connection String = ", $connectionString))

$octoargs = @("database",
          "--instance",
          '"OctopusServer"',
          "--connectionString",
          (-join('"', $connectionString, '"')),
          "--create")

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Configure Access

Write-Output "Configuring Access"

$octoargs = @("configure",
          "--instance",
          '"OctopusServer"',
          "--webForceSSL",
          "False",
          "--webListenPrefixes",
          '"http://localhost:80/"',
          "--commsListenPort",
          '"10943"',
          "--usernamePasswordIsEnabled",
          "True",
          "--activeDirectoryIsEnabled",
          "False")

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Stop Service

Write-Output "Stopping Service"

$octoargs = @("service",
          "--instance",
          '"OctopusServer"',
          "--stop")

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Set Credentials

Write-Output "Setting Credentials"
Write-Output (-join("Username = ", $username))
Write-Output (-join("Email = ", $email))
Write-Output (-join("Password = ", $password))

$octoargs = @("admin",
          "--instance",
          '"OctopusServer"',
          "--username",
          (-join('"', $username, '"')),
          "--email",
          (-join('"', $email, '"')),
          "--password",
          (-join('"', $password, '"')))

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# License

Write-Output "Adding License"
Write-Output (-join("License (String) = ", $licenseKey))
Write-Output (-join("License (Base64) = ", $licenseKeyBase64))

$octoargs = @("license",
          "--instance",
          '"OctopusServer"',
          "--licenseBase64",
          (-join('"', $licenseKeyBase64, '"')))

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Setup Paths

Write-Output "Setting Up Paths"

$octoargs = @("path",
          "--artifacts",
          '"C:\Octopus\Artifacts"')

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

$octoargs = @("path",
          "--taskLogs",
          '"C:\Octopus\TaskLogs"')

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

$octoargs = @("path",
          "--nugetRepository",
          '"C:\Octopus\Packages"')

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Start Service

Write-Output "Installing and Starting Service"

$octoargs = @("service",
          "--instance",
          '"OctopusServer"',
          "--install",
          "--reconfigure"
          "--start")

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow