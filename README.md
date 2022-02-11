# Octopus Deploy HA Bicep and Powershell Scripts

This repo contains a Bicep Script and a set of Powershell scripts that will stand up all of the architecture needed for Octopus Deploy HA.

Currently this stands up two VMs and configures Octopus on each for HA.

## Usage

From `provision_azure_scripts`, run the following

``` powershell
.\01_create_infra.ps1 "<RESOURCE GROUP NAME>" `
"<RESOURCE PREFIX>" `
"<REGION>" `
"<ADMIN USRENAME>" `
"<ADMIN EMAIL ADDRESS>" `
"<ADMIN PASSWORD>" `
"<SQL SERVER USERNAME>" `
"<SQL SERVER PASSWORD>" `
'<OCTOPUS DEPLOY LICENSE KEY>'
```

Leave the quotes as they are..

## Example;

``` powershell
.\01_create_infra.ps1 "my-resource-group" `
"oct-octo1" `
"northeurope" `
"petecodes" `
"peter.gallagher@octopus.com" `
"Octopus_1234" `
"petecodes" `
"OctopusDeploy_1234" `
'<License Signature="JHGiuygYUgjhBYGkjbYYUI6786YIUhjkg986ghk"><LicensedTo>Octopus</LicensedTo><LicenseKey>12345-54321-11223-34455</LicenseKey><Version>2.0<!-- License Schema Version --></Version><ValidFrom>2022-02-03</ValidFrom><MaintenanceExpires>2024-02-03</MaintenanceExpires><ProjectLimit>Unlimited</ProjectLimit><MachineLimit>Unlimited</MachineLimit><UserLimit>Unlimited</UserLimit><NodeLimit>Unlimited</NodeLimit></License>'
```

## Resources Provisioned in Azure

An example deployment looks like this;

![Example resources](/images/resources.png)

## Bicep Scripts

### `storage.bicep`

This Bicep Script will provision the following resources;

- 1x Storage Account
- 1x File Service
- 1x FileShare

### `main.bicep`

This Bicep Script will provision the following resources;

- 1x SQL Server
- 1x SQL Database
- 2x VM
    - Windows Server 2022 Azure Edition 
    - Standard D2s v3 (2 vcpus, 8 GiB memory)
- 2x Disk
- 2x NIC
- 2x Network Security Group
- 1x VNET
- 1x SubNet
- 1x NAT Gateway
- 1x NAT Gateway IP Address
- 1x Load Balancer
- 1x Load Balancer IP Address

## Provisioning Powershell Scripts

### `01_create_infra.ps1`

This script will provision the Storage Account and File Share as well as the main Azure Services. It also provisions the various parts that the Bicep Script can't.

#### Parameters

1) Resource Group
2) Prefix
3) Location
4) Admin Username
5) Admin Email
6) Admin Password
7) SQL Server Admin Username
8) SQL Server Admin Password
9) Octopus Deploy License Key (Single Line)

#### Operations

- Capture command line parameters
- Replace Quotes in License with holding character
- Replace "-" character in prefix for storage account resource name
- Deploy the Storage Bicep Script
- Create Ocotpus directories in the File Share
- Retrieve the Storage Account Access Key
- Begin the "main" Bicep Provisioning Script, passing in;
    - Prefix
    - Location
    - Admin Username
    - Admin Email
    - Admin Password
    - SQL Server Admin Username
    - SQL Server Password
    - Storage Account Access Key
    - Octopus Deploy License Key
- Create Backebd Address Pools for the two VM IP Addresses
- Attach Inbound NAT Rules for RDP Access

## VM Powershell Scripts

### `01_addsymboliclinks.ps1`

This script will add a Windows Credential to allow Octopus to access the shared storage File Share, create a local storage directory and create symbolic links to the File Share directories.

#### Parameters

1) Storage Account Name
2) Storage Account Access Key
3) Storage Account Share Name
4) Storage Account Directory Name

#### Operations

- Capture command line parameters
- Add Windows Credential for Storage Account
- Create "Octopus" local storage directory
- Create Symbolic links for;
    - TaskLogs
    - Artifacts
    - Packages

### `02_installoctopus.ps1`

This script downloads the Octopus Windows Installer MSI and installs it silently.

#### Parameters

None

#### Operations

- Download Octopus MSI
- Install MSI using msiexec.exe

### `03_setupOctopus.ps1`

This script runs on the First VM and setups up Octopus Deploy and the Database.

#### Parameters

1) SQL Server Connection String
2) Admin Username
3) Admin Email
4) Admin Password
5) Octopus Deploy License Key

#### Operations

- Capture command line parameters
- Convert License Key to Base64
- Create Octopus Deploy Instance
- Congiure Database
- Configure User Access
- Stop Octopus Service
- Set User Credentials
- Add the Octopus Deploy License
- Add Octopus Deploy Paths
- Start the Octopus Service

### `04_addFirewallRules.ps1`

This script adds Windows firewall rules to allow remote access to the Octopus instance.

#### Parameters

None

#### Operations

- Add Inbound and Outbound Port 80 and 443 Firewall Rules

### `05_getMasterKey.ps1`

This script will retrieve the Octopus Deploy Master Key and save it to the shared storage for the other VMs to add to their installation.

#### Parameters

None

#### Operations

- Retrieve Master Key from Octopus Deploy
- Pipe to `C:\Octopus\Artifacts\MasterKey.txt`

### `06_setupOctoput_VMX.ps1`

This script runs on all subsquent nodes and configures the node with the database, storage and Master Key.

#### Paramaters

1) Connection String
2) Master Key (Optional - Will read from `C:\Octopus\Artifacts\MasterKey.txt`)

#### Operations

- Capture Command Line Parameters
- Create Octopus Instance
- Configure Database along with Master Key from the first Server
- Configure Access
- Stop Octopus Service
- Add Octopus Deploy Paths
- Start Octopus Service

## ToDo

- Seperate Bicep and Install Scripts into smaller chunks
- Allow for setting how many VMs to stand up
- Use Out parameters in Bicep and Powershell to spit out Load Balancer IP address etc
- Tidy up secure parameters
- General Tidying
- Error Handling
- Better Logging