(-join("Connection String = ", $args[0])) | Out-File -FilePath "$PSScriptRoot\args.txt"
(-join("Account Key = ", $args[1])) | Out-File -FilePath "$PSScriptRoot\args.txt"
(-join("License Key = ", $args[2])) | Out-File -FilePath "$PSScriptRoot\args.txt"