$serverNodeName = $env:computername
$connectionString = $args[0]
$masterKey = $args[1]

if(!$masterKey)
{
    $masterKey = Get-Content -Path "C:\Octopus\Artifacts\MasterKey.txt" 
}

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
Write-Output (-join("Master Key = ", $masterKey))
Write-Output (-join("Connection String = ", $connectionString))

$octoargs = @("database",
          "--instance",
          '"OctopusServer"',
          "--masterKey",
          (-join('"', $masterKey, '"')),
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
          '"10943"')

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Stop Service

Write-Output "Stopping Service"

$octoargs = @("service",
          "--instance",
          '"OctopusServer"',
          "--stop")

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