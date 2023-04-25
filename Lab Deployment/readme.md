# Lab Deployment

## Requirements

Before the deployment can take place, please download and install the following software on the Hyper-V host:

1. Install AutomatedLab either through PowerShell Gallery or the latest.

    The preferred way is using the PowerShell gallery:

    ```powershell
    Install-Module -Name AutomatedLab -AllowClobber -Force
    New-LabSourcesFolder -DriveLetter D -Force #The LabSources folder does not have to be on a fast drive
    ```

    If the Hyper-V host does not have internet connectivity, please use the [MSI installer](https://github.com/AutomatedLab/AutomatedLab/releases) of AutomatedLab.

2. Required ISOs

   - Please copy a Windows Server 2016 ISO to the path `$labSources\ISOs`. Evaluation images can be retrieved from [Windows Server 2016 | Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016)

   - Please copy a SQL Server 2019 ISO to the path `$labSources\ISOs`. Evaluation images can be retrieved from [SQL Server 2019 | Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-sql-server-2019)

3. If the Hyper-V host does not have internet connectivity, please download the software defined in the hashtable of [20 Customizations.ps1](10%20Kerberos%20101%20Lab%20-%20HyperV.ps1) and store it in `$labSources\SoftwarePackages` before starting the lab deployment.

## Deployment

All deployment scripts are in the folder [Lab Deployment](/Lab%20Deployment/). Please execute them in the given sequence.

> :warning: For running the script, please copy the complete folder and not just the script files. The directories are also required.

- ### [10 Kerberos 101 Lab - HyperV.ps1](./10%20Kerberos%20101%20Lab%20-%20HyperV.ps1)

    This script deploys the machines with the given roles.

    > :information_source: The only reference to an ISO file in this script is in line 22. If your SQL ISO file is named differently, please change the path in the script.

- ### [20 Customizations.ps1](./20%20Customizations.ps1)

    All other customizations like software installation of web site configuration is taken care of by this script.
