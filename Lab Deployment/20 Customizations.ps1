if ((Get-Lab -ErrorAction SilentlyContinue).Name -ne 'Kerberos101') {
    Import-Lab -Name Kerberos101 -NoValidation -ErrorAction Stop
}

$devMachine = Get-LabVM -ComputerName KerbClient2
$sqlServers = Get-LabVM -Role SQLServer
$fileServer = Get-LabVM -Role FileServer
$webServer = Get-LabVM -ComputerName KerbWeb2
$allMachines = Get-LabVM

$softwarePackages = @{
    VsCode                    = @{
        Url         = 'https://go.microsoft.com/fwlink/?Linkid=852157'
        CommandLine = '/VERYSILENT /MERGETASKS=!runcode'
        Machines    = $devMachine
    }
    Git                       = @{
        Url         = 'https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe'
        CommandLine = '/SILENT'
        Machines    = $devMachine
    }
    NotepadPlusPlus           = @{
        Url         = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.1/npp.8.5.1.Installer.x64.exe'
        CommandLine = '/S'
        Machines    = 'All'
    }
    Npcap                     = @{
        Url         = 'https://npcap.com/dist/npcap-0.96.exe'
        CommandLine = '/S'
        Machines    = 'All'
    }
    PowerShell7               = @{
        Url         = 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/PowerShell-7.3.3-win-x64.msi'
        CommandLine = '/quiet'
        Machines    = $devMachine
    }
    Dotnet7Sdk                = @{
        Url         = 'https://download.visualstudio.microsoft.com/download/pr/89a2923a-18df-4dce-b069-51e687b04a53/9db4348b561703e622de7f03b1f11e93/dotnet-sdk-7.0.203-win-x64.exe'
        CommandLine = '/install /quiet /norestart'
        Machines    = $devMachine
    }
    DotNetCoreRuntime         = @{
        Url         = 'https://download.visualstudio.microsoft.com/download/pr/b92958c6-ae36-4efa-aafe-569fced953a5/1654639ef3b20eb576174c1cc200f33a/windowsdesktop-runtime-3.1.32-win-x64.exe'
        CommandLine = '/install /quiet /norestart'
        Machines    = $devMachine
    }
    Edge                      = @{
        Url         = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/07e65991-04aa-4d97-b6d0-22de7d04fb81/MicrosoftEdgeEnterpriseX64.msi'
        CommandLine = '/Q'
        Machines    = 'All'
    }
    WireShark                 = @{
        Url         = 'https://2.na.dl.wireshark.org/win64/Wireshark-win64-4.0.5.exe'
        CommandLine = '/S'
        Machines    = 'All'
    }
    VsCodePowerShellExtension = @{
        Url               = 'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/PowerShell/2023.3.3/vspackage'
        DestinationFolder = 'VSCodeExtensions'
    }
}

foreach ($softwarePackage in $softwarePackages.GetEnumerator()) {
    $destinationFolder = if ($softwarePackage.Value.DestinationFolder) {
        "$labSources\$($softwarePackage.Value.DestinationFolder)"
    }
    else {
        "$labSources\SoftwarePackages"
    }
    Write-Host "Downloading '$($softwarePackage.Name)' ($($softwarePackage.Value.Url)) to '$destinationFolder'" -NoNewline
    $softwarePackage.Value.Installer = Get-LabInternetFile -Uri $softwarePackage.Value.Url -Path $labSources\SoftwarePackages -PassThru
    Write-Host done.

    if ($softwarePackage.Value.Machines) {
        $machines = if ($softwarePackage.Value.Machines -eq 'All') {
            Get-LabVM
        }
        else {
            Get-LabVM -ComputerName $softwarePackage.Value.Machines
        }
        Write-Host "Installing '$($softwarePackage.Name)' to machines '$($machines)'" -NoNewline
        Install-LabSoftwarePackage -ComputerName $machines -Path $softwarePackage.Value.Installer.FullName -CommandLine $softwarePackage.Value.CommandLine
        Write-Host done.
    }

}

Remove-LabPSSession

Copy-LabFileItem -Path $labSources\SoftwarePackages\VSCodeExtensions -ComputerName $devMachine
Invoke-LabCommand -ActivityName 'Install VSCode Extensions' -ComputerName $devMachine -ScriptBlock {
    dir -Path C:\VSCodeExtensions | ForEach-Object {
        code --install-extension $_.FullName 2>$null #suppressing errors
    }
} -NoDisplay

#Create SMB share and test file on the file server
Invoke-LabCommand -ActivityName 'Create SMB Share' -ComputerName $fileServer -ScriptBlock {

    New-Item -ItemType Directory C:\Test -ErrorAction SilentlyContinue
    New-SmbShare -Name Test -Path C:\Test -FullAccess Everyone
    New-Item -Path C:\Test\TestFile.txt -ItemType File

}

Invoke-LabCommand -ActivityName 'Enabling RDP Restricted Mode' -ComputerName $allMachines -ScriptBlock {

    Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\Lsa -Name DisableRestrictedAdmin -Value 0 -Type DWord
}

Save-Module -Name DSInternals -Path $PSScriptRoot\Modules
Save-Module -Name NTFSSecurity -Path $PSScriptRoot\Modules
Copy-LabFileItem -Path "$PSScriptRoot\Modules\DsInternals" -ComputerName $allMachines -DestinationFolderPath 'C:\Program Files\WindowsPowerShell\Modules'
Copy-LabFileItem -Path "$PSScriptRoot\Modules\NTFSSecurity" -ComputerName $allMachines -DestinationFolderPath 'C:\Program Files\WindowsPowerShell\Modules'
Copy-LabFileItem -Path $PSScriptRoot\Modules\Kerberos101 -ComputerName $allMachines -DestinationFolderPath 'C:\Program Files\WindowsPowerShell\Modules'
Copy-LabFileItem -Path $PSScriptRoot\SqlScripts -ComputerName $sqlServers
Copy-LabFileItem -Path "$PSScriptRoot\Setup Web Sites" -ComputerName $webServer -DestinationFolderPath C:\Kerberos101

Invoke-LabCommand -ActivityName 'Setup Websites' -ComputerName $webServer -ScriptBlock {
    . 'C:\Kerberos101\Setup Web Sites\Add-KerbWebApplications.ps1'
}

Invoke-LabCommand -ActivityName 'Setup SQL Databases and Permissions' -ComputerName $sqlServers -ScriptBlock {
    SQLCMD.EXE -i C:\SqlScripts\instpubs.sql
    SQLCMD.EXE -i C:\SqlScripts\instnwnd.sql
    SQLCMD.EXE -i C:\SqlScripts\dbpermissions.sql
}

Add-VMNetworkAdapter -VMName $devMachine -Name Internet -SwitchName 'Default Switch'

if (Test-LabMachineInternetConnectivity -ComputerName $devMachine) {
    Invoke-LabCommand -ActivityName 'Installing Bruce' -ComputerName $devMachine -ScriptBlock {
        dotnet tool install -g bruce
    }
}

Uninstall-LabWindowsFeature -Name Windows-Defender-Features -ComputerName $devMachine

Checkpoint-LabVM -All -SnapshotName AfterCustomizations
