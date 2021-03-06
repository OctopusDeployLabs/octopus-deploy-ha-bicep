$storageName=$args[0]
$storagePass=$args[1]
$storageShare=$args[2]
$storageDirectory=$args[3]

$LogFileLocation = "C:\log.txt"

# Log Args to File

"Beginning Add Symbolic Links Script" | Out-File -FilePath $LogFileLocation -append

(-join("Storage Account Name = ", $StorageName)) | Out-File -FilePath $LogFileLocation -append
(-join("Account Key = ", $storagePass)) | Out-File -FilePath $LogFileLocation -append
(-join("Storage File Share Name = ", $storageShare)) | Out-File -FilePath $LogFileLocation -append
(-join("Storage File Share Directory = ", $storageDirectory)) | Out-File -FilePath $LogFileLocation -append

# Add the Authentication for the symbolic links. You can get this from the Azure Portal.

try {
    cmdkey /add:$storageName.file.core.windows.net /user:Azure\$storageName /pass:$storagePass
}
catch {
    (-join("Error Adding Authentication = ", $_.ScriptStackTrace)) | Out-File -FilePath $LogFileLocation -append
}

# Add Octopus folder to add symbolic links

New-Item -ItemType directory -Path C:\Octopus

# Add the Symbolic Links. Do this before installing Octopus.

New-Item -ItemType SymbolicLink -Path "C:\Octopus\TaskLogs" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\TaskLogs"
New-Item -ItemType SymbolicLink -Path "C:\Octopus\Artifacts" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\Artifacts"
New-Item -ItemType SymbolicLink -Path "C:\Octopus\Packages" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\Packages"