# Kerberos 101 Labs

## Troubleshooting SPNs Part 1

This lab covers another well-known issue: Missing SPNs. What happens if there is no SPN registered for the requested service?

:ballot_box_with_check: Restart the client machine and the file server.

:ballot_box_with_check: Then logon to the client machine.

:ballot_box_with_check: Open a PowerShell and invoke the function `Start-Lab4`. Please note the computer name returned by the function.

:ballot_box_with_check: Open Wireshark and start a network trace again.

:ballot_box_with_check: Browse to the `c$` share of the machine returned by `Start-Lab4`.

:ballot_box_with_check: Stop the network trace.

Accessing the share works so we do not expect anything wrong with the Kerberos configuration. 

Analyze the network trace. A closer look on the communication shows that there is something wrong.

:question: What was the authentication protocol this time?

:question: What is the Kerberos error in the trace?

:question: Is there anything interesting about the requested SPN?

<details><summary><h2>Lessons Learned</h2></summary>

:bulb: If an SPN cannot be found, authentication may still work as the operating system falls back to NTLM.

:bulb: When accessing a SMB share, Windows asks for a `cifs` ticket. There is no `cifs` SPN anywhere in Active Directory. The `sPNMappings` attribute on the Active Directory object `CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=vm,DC=net` maps a list of services to the host SPN, meaning that each computer has 53 more SPNs than it looks like.

This command can be used to get the list of SPNs mapped to the SPN `host`.

```powershell
(Get-ADObject -Identity 'CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=vm,DC=net' -Properties sPNMappings).sPNMappings -split ','
```

The output looks like this and this list contains the SPN `cifs`. This is the reason why even if there is no `cifs` SPN registered we could get a `cifs` ticket in the previous task.

```text
host=alerter
appmgmt
cisvc
clipsrv
browser
dhcp
dnscache
replicator
eventlog
eventsystem
policyagent
oakley
dmserver
dns
mcsvc
fax
msiserver
ias
messenger
netlogon
netman
netdde
netddedsm
nmagent
plugplay
protectedstorage
rasman
rpclocator
rpc
rpcss
remoteaccess
rsvp
samss
scardsvr
scesrv
seclogon
scm
dcom
cifs
spooler
snmp
schedule
tapisrv
trksvr
trkwks
ups
time
wins
www
http
w3svc
iisadmin
msdtc
```

</details>
