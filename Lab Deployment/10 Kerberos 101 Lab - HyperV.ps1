$labName = 'Kerberos101'
$sqlIsoImageName = 'SQLServer2019-x64-ENU.iso' #this file should be stored in '$labSources\ISOs'

#--------------------------------------------------------------------------------------------------------------------
#----------------------- CHANGING ANYTHING BEYOND THIS LINE SHOULD NOT BE REQUIRED ----------------------------------
#----------------------- + EXCEPT FOR THE LINES STARTING WITH: REMOVE THE COMMENT TO --------------------------------
#----------------------- + EXCEPT FOR THE LINES CONTAINING A PATH TO AN ISO OR APP   --------------------------------
#--------------------------------------------------------------------------------------------------------------------

#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.22.0/24

#and the domain definition with the domain admin account
Add-LabDomainDefinition -Name vm.net -AdminUser Install -AdminPassword Somepass1
Add-LabDomainDefinition -Name a.vm.net -AdminUser Install -AdminPassword Somepass2
Add-LabDomainDefinition -Name test.net -AdminUser Install -AdminPassword Somepass0

#these images are used to Install the machines
$sqlIsoPath = "$labSources\ISOs\$sqlIsoImageName"
Add-LabIsoImageDefinition -Name SQLServer2019 -Path $sqlIsoPath

#defining default parameter values, as these ones are the same for all the machines
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:OperatingSystem'= 'Windows Server 2016 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:Memory'= 1GB
}

#========== #these credentials are used for connecting to the machines in the root doamin vm.net. ==========================
Set-LabInstallationCredential -Username Install -Password Somepass1

#The PostInstallationActivity is just creating some users
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
Add-LabMachineDefinition -Name KerbDC1 -IpAddress 192.168.22.10 -DnsServer1 192.168.22.10 -DomainName vm.net -Roles RootDC -PostInstallationActivity $postInstallActivity

#========== #these credentials are used for connecting to the machines in the child doamin a.vm.net. ==========================
Set-LabInstallationCredential -Username Install -Password Somepass2

#this is the first domain controller of the child domain 'a' defined above
#The PostInstallationActivity is filling the domain with some life.
#At the end about 6000 users are available with OU and manager hierarchy as well as a bunch of groups
$role = Get-LabMachineRoleDefinition -Role FirstChildDC -Properties @{ ParentDomain = 'vm.net'; NewDomain = 'a' }
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
Add-LabMachineDefinition -Name KerbDC2 -IpAddress 192.168.22.11 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net -Roles $role -PostInstallationActivity $postInstallActivity

#This is a web server in the child domain
Add-LabMachineDefinition -Name KerbWeb2 -IpAddress 192.168.22.50 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net -Roles WebServer

#A File Server with no special role
Add-LabMachineDefinition -Name KerbFile2 -IpAddress 192.168.22.51 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net -Roles FileServer

#Two SQL servers with the usual demo databases
$role = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{ InstallSampleDatabase = 'true' }
Add-LabMachineDefinition -Name KerbSql21 -Memory 3GB -IpAddress 192.168.22.52 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net -Roles $role
Add-LabMachineDefinition -Name KerbSql22 -Memory 3GB -IpAddress 192.168.22.53 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net -Roles $role

#Server for usage as client
Add-LabMachineDefinition -Name KerbClient2 -Memory 2GB -IpAddress 192.168.22.55 -DnsServer1 192.168.22.11 -DnsServer2 192.168.22.10 -DomainName a.vm.net

#========== Now the 2nd forest gets setup with new credentials ==========================
Set-LabInstallationCredential -Username Install -Password Somepass0

#this will become the root domain controller of the second forest
#The PostInstallationActivity is just creating some users
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
Add-LabMachineDefinition -Name KerbDC0 -IpAddress 192.168.22.100 -DnsServer1 192.168.22.100 -DomainName test.net -Roles RootDC -PostInstallationActivity $postInstallActivity

#This is a web serverin the child domain
Add-LabMachineDefinition -Name KerbWeb0 -IpAddress 192.168.22.110 -DnsServer1 192.168.22.100 -DomainName test.net -Roles WebServer

Install-Lab

Install-LabWindowsFeature -ComputerName (Get-LabVM) -FeatureName RSAT-AD-Tools, RSAT-DNS-Server

Show-LabDeploymentSummary -Detailed

Checkpoint-LabVM -All -SnapshotName AfterDeployment
