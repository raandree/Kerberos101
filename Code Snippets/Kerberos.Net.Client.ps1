using namespace Kerberos.NET
using namespace Kerberos.NET.Credentials
using namespace Kerberos.NET.Configuration
using namespace Kerberos.NET.Client

$path = Split-Path -Path (where.exe bruce.exe) -Parent
$path = (dir -Path $path -Recurse -Filter Kerberos.NET.dll).FullName

Add-Type -Path $path

$config = @'
[libdefaults]
  allow_weak_crypto = true
  default_tgs_enctypes = RC4-HMAC-NT AES128-CTS-HMAC-SHA256-128 AES256-CTS-HMAC-SHA384-192 AES256-CTS-HMAC-SHA1-96 AES128-CTS-HMAC-SHA1-96
  default_tkt_enctypes = RC4-HMAC-NT AES128-CTS-HMAC-SHA256-128 AES256-CTS-HMAC-SHA384-192 AES256-CTS-HMAC-SHA1-96 AES128-CTS-HMAC-SHA1-96
  permitted_enctypes = RC4-HMAC-NT AES128-CTS-HMAC-SHA256-128 AES256-CTS-HMAC-SHA384-192 AES256-CTS-HMAC-SHA1-96 AES128-CTS-HMAC-SHA1-96
'@

$cred = [KerberosPasswordCredential]::new('Install', 'Somepass2', 'a.vm.net')

$config = [Krb5Config]::Parse($config)
$client = [KerberosClient]::new($config)
$r = $client.Authenticate($cred)
while ($r.Status -eq 'WaitingForActivation')
{
    Start-Sleep -Milliseconds 5
}

$r = $client.GetServiceTicket('http/KerbTest.a.vm.net')
while ($r.Status -eq 'WaitingForActivation')
{
    Start-Sleep -Milliseconds 5
}

$tickets = $client.Cache.GetAll().ToArray()

$tickets | Format-Table -Property @{ Name = 'SName'; Expression = { $_.SName.FullyQualifiedName } },
@{ Name = 'CName'; Expression = { $_.KdcResponse.CName.FullyQualifiedName } },
@{ Name = 'SessionKeyEncType'; Expression = { $_.SessionKey.EType } },
@{ Name = 'TicketKeyEncType'; Expression = { $_.KdcResponse.EncPart.EType } }
