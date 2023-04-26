# Kerberos 101 Labs

## Trace accessing a file server

This lab is pretty similar to the previous one. Everything is done from the client.

We are accessing a File Server two times. There should be a big difference visible in the trace.

:ballot_box_with_check: Logoff the current session from the machine `KerbClient2` and logon again. The password for the user `a\Install` is `Somepass2`.

:ballot_box_with_check: Start Wireshark and start the trace.

You might want to set the filter in Wireshark to Kerberos again.

Now want to request data from the file server. There is a prepared PowerShell function for that just needs to be called: `Get-SmbData1`. The function returns the number of files read from the file server.

> :information_source: If PowerShell complains that the execution of scripts is disabled, run the following command first:
> `Set-ExecutionPolicy Unrestricted`

:ballot_box_with_check: Open a PowerShell and call the function `Get-SmbData1`.

:ballot_box_with_check: After the script is finished, stop the network trace.

:question: How many Kerberos packets do you see in the trace?

:question: What was the authentication protocol?


Now we do the same thing again but using the second PowerShell function to read the data from the file server.

:ballot_box_with_check: Re-Logon to the client machine.

:ballot_box_with_check: Start a new trace in the Wireshark.

:ballot_box_with_check: Call the PowerShell function `Get-SmbData2`.

:ballot_box_with_check: Stop the network trace


:question: How many Kerberos packets do you see in the trace this time?

:question: What is the SPN the client asks a ticket for?

:question: What is the difference between `Get-SmbData1` and `Get-SmbData2`?

<details><summary><h2>Lessons Learned</h2></summary>

:bulb: In order to get a ticket from the KDC, a SPN must be defined. If you use the IP address instead of the machine name, the SPN cannot be build, hence the client tries to use a different way of authentication.

:bulb: However this depends on the client as the client is in charge of constructing the SPN. The function `Get-SqlData1` connects to a SQL server by using the IP address AND Kerberos.

</details>
