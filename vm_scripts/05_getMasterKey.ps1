
$octoargs = @("show-master-key")

Start-Process "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" -ArgumentList $octoargs -Wait -NoNewWindow -RedirectStandardOutput "C:\Octopus\Artifacts\MasterKey.txt"

$masterKey = Get-Content -Path "C:\Octopus\Artifacts\MasterKey.txt" 

Write-Output $masterKey

#Remove-Item "$PSScriptRoot\MasterKey.txt"