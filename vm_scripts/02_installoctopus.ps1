$url = "https://download.octopusdeploy.com/octopus/Octopus.2021.3.12155-x64.msi"
$outpath = "$PSScriptRoot\octopusdeploy.msi"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("/I",$outpath,"/quiet", "RUNMANAGERONEXIT=no")
Write-Output $args[0]
Write-Output $args[1]
Write-Output $args[2]
Write-Output $args[3]

Start-Process "msiexec.exe" -ArgumentList $octoargs -Wait -NoNewWindow