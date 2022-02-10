Write-EventLog -LogName "Application" -Source "InstallVM1" -EventID 3001 -EntryType Information -Message (-join("Connection String = ", $args[0])) -Category 1 -RawData 10,20
Write-EventLog -LogName "Application" -Source "InstallVM1" -EventID 3001 -EntryType Information -Message (-join("Account Key = ", $args[1])) -Category 1 -RawData 10,20
Write-EventLog -LogName "Application" -Source "InstallVM1" -EventID 3001 -EntryType Information -Message (-join("License Key = ", $args[2])) -Category 1 -RawData 10,20

(-join("Connection String = ", $args[0])) | Out-File -FilePath "C:\args.txt"
(-join("Account Key = ", $args[1])) | Out-File -FilePath "C:\args.txt"
(-join("License Key = ", $args[2])) | Out-File -FilePath "C:\args.txt"