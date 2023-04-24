#Requires –Modules DSInternals
Install-WindowsFeature -Name RSAT-AD-Tools, RSAT-DNS-Server

function Add-KerbWebApplications
{
    Write-Host 'Setting up web site and web applications'

    Write-Host "Assuming all directories in this folder ($($pwd.Path)) are web applications to deploy"
    Write-Host "The sub folders are copied as we assume we are working with Visual Studio solutions and the actual web application is in another subfolder with the same name"

    Write-Host "All folders will be copied to '$testSitePath' and a new web site with the name '$testSiteName' will be created"
    Write-Host

    Write-Host "Creating physical directory and copying the content..." -NoNewline
    New-Item -Path $testSitePath -ItemType Directory | Out-Null
    Get-ChildItem -Directory | ForEach-Object {
        $appName = $_.Name
        Copy-Item -Path .\$appName\$appName -Destination $testSitePath -Recurse
    }
    Write-Host 'done'

    Write-Host "Creating web site '$testSiteName' and application pool..." -NoNewline
    $appPool = New-WebAppPool -Name $testSiteName
    $site = New-Website -Name $testSiteName -HostHeader "$testSiteName.$($dc.Domain.Name)" -PhysicalPath $testSitePath -ApplicationPool $appPool.name
    $appPool | Set-ItemProperty -Name "managedPipelineMode" -Value 'Classic'
    Write-Host 'done'

    Write-Host "Converting physical folders to web applications..." -NoNewline
    $webApps = Get-ChildItem -Path $site.PSPath | ConvertTo-WebApplication -ApplicationPool $appPool.name
    Write-Host 'done'

    Write-Host "Enabling Windows Authentication (no Kernel Mode) for all web applications and disabling anonymous access..."  -NoNewline
    $webApps | ForEach-Object {
        Set-WebConfigurationProperty -PSPath IIS:\ -Location "$($site.name)/$($_.name)" -Filter //windowsAuthentication -Name Enabled -Value True
        Set-WebConfigurationProperty -PSPath IIS:\ -Location "$($site.name)/$($_.name)" -Filter //windowsAuthentication -Name useKernelMode -Value False
        Set-WebConfigurationProperty -PSPath IIS:\ -Location "$($site.name)/$($_.name)" -Filter //anonymousAuthentication -Name Enabled -Value False
        Set-WebConfigurationProperty -PSPath $_.PSPath -Filter /system.web/identity -Name Impersonate -Value False
        Write-Host '.' -NoNewline
    }
    Write-Host 'done'
    Write-Host

    Write-Host 'Finished setting up the web applications'
}

function Start-LabChanges61
{
    Write-Host 'Doing changes for lab 6.1'

    Write-Host "Creating a new A record named '$testSiteName' in the zone '$($dc.Domain.Name)' on server '$($dc.Name)'..." -NoNewline
    Add-DnsServerResourceRecordA -Name $testSiteName `
        -IPv4Address (Get-NetIPAddress -InterfaceAlias 'Kerberos101 0' -AddressFamily IPv4).IPAddress `
        -ZoneName $dc.Domain.Name `
        -ComputerName $dc.Name
    Write-Host 'done'

    Write-Host 'Finished doing changes for lab 6.1'
}

function Start-LabChanges62
{
    Write-Host 'Doing changes for lab 6.2'

    $ou = Get-ADOrganizationalUnit -Filter "Name -eq '$serviceAccountsOuName'" -ErrorAction SilentlyContinue
    if (-not $ou)
    {
        Write-Host "AD OU '$serviceAccountsOuName' does not exist. Creating it"
        $ou = New-ADOrganizationalUnit -Name $serviceAccountsOuName -Path (Get-ADRootDSE -Server $dc.Name).defaultNamingContext -ProtectedFromAccidentalDeletion:$false -PassThru
    }

    try { $user = Get-ADUser -Identity $testSiteName } catch { }
    if (-not $user)
    {
        Write-Host "AD User account '$testSiteName' does not exist. Creating it"
        $user = New-ADUser -Name $testSiteName -Path $ou.DistinguishedName -AccountPassword $serviceAccountSecurePassword -Enabled $true -PassThru
    }

    $spns = @{ Add = "http/$testSiteName.$($dc.Domain.Name)",  "http/$testSiteName" }
    Write-Host "Registering SPNs '$($spns.Add -join "', '")' on user account '$testSiteName'"
    Set-ADUser -ServicePrincipalNames $spns -Identity $user.SID

    Write-Host 'Finished doing changes for lab 6.2'
}

function Start-LabChanges63
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$WebApplicationName
    )

    Write-Host 'Doing changes for lab 6.3'

    $webapp = Get-WebApplication -Name $WebApplicationName -Site $testSiteName
    if (-not $webapp)
    {
        Write-Error "The web application '$WebApplicationName' could not be found under the site '$testSiteName'"
        return
    }

    Write-Host "Enabling ASP.Net Impersonation for web site '$WebApplicationName'"
    Set-WebConfigurationProperty -PSPath $webapp.PSPath -Filter /system.web/identity -Name Impersonate -Value True

    Write-Host 'Finished doing changes for lab 6.3'
}

function Start-LabChanges64
{
    Write-Host 'Doing changes for lab 6.4'

    try { $user = Get-ADUser -Identity $testSiteName } catch { }
    if (-not $user)
    {
        Write-Error "AD User account '$testSiteName' does not exist. Please run the previous labs"
        return
    }

    Write-Host "Setting the user account '$testSiteName' as trusted for uncontrained Kerberos delegation"
    Set-ADUser -Identity $testSiteName -TrustedForDelegation $true

    Write-Host 'Finished doing changes for lab 6.4'

    Write-Host 'The machine is about to statrt in 15 seconds. Press <CTRL + C> if you do not want the machine to restart' -NoNewline
    1..15 | ForEach-Object { Write-Host '.' -NoNewline; Start-Sleep -Seconds 1 }
    Write-Warning 'Machine is restarting now'
    Start-Sleep -Seconds 2

    Restart-Computer
}

Import-Module -Name WebAdministration #to have the IIS drive

$testSiteName = 'KerbTest'
$iisPath = 'C:\inetpub'
$testSitePath = Join-Path -Path $iisPath -ChildPath $testSiteName
$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::FindOne((New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain')))
$domainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name
$domainShortName = $domainName.Split('.')[0]

$currentIpAddress = (Get-NetIPAddress -InterfaceAlias 'Kerberos101 0' -AddressFamily IPv4).IPAddress

$serviceAccountsOuName = 'Service Accounts'
$serviceAccountPassword = 'Password9'
$serviceAccountSecurePassword = $serviceAccountPassword | ConvertTo-SecureString -AsPlainText -Force

if (-not (Get-WindowsFeature -Name RSAT).Installed)
{
    Install-WindowsFeature -Name RSAT -IncludeAllSubFeature
}

Push-Location

Set-Location -Path $PSScriptRoot
Add-KerbWebApplications

$u = New-ADUser -Name "$($testSiteName)Service" -ServicePrincipalNames "http/$testSiteName.$domainName" -Enabled $true -AccountPassword $serviceAccountSecurePassword -PassThru
$u | Set-ADUser -Replace @{ servicePrincipalName = 'http/KerbTest.a.vm.net', 'http/KerbTest' }

Add-DnsServerResourceRecordA -Name $testSiteName -ZoneName $domainName -IPv4Address $currentIpAddress -ComputerName $dc

$pool = Get-Item -Path IIS:\AppPools\KerbTest
$pool.processModel.userName = "$domainShortName\$($testSiteName)Service"
$pool.processModel.password = $serviceAccountPassword
$pool.processModel.identityType = 3
$pool | Set-Item

Pop-Location

#Write only an RC4 password for the App Pool account
$password = 'Password9' | ConvertTo-SecureString -AsPlainText -Force
$hash = $password | ConvertTo-NTHash
Set-ADAccountPasswordHash -SamAccountName "$($testSiteName)Service" -Domain $domainShortName -NTHash $hash -Server $dc
$u = Get-ADReplAccount -SamAccountName "$($testSiteName)Service" -Domain $domainShortName -Server $dc

klist purge
Add-Type -AssemblyName System.IdentityModel
New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList http/KerbTest.a.vm.net
