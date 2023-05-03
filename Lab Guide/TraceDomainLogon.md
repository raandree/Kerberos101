# Kerberos 101 Labs

## Trace a domain logon

In this lab, we take a first look at Kerberos network traffic. All relevant information is available in clear test. This does not compromise security but help understanding how Kerberos works and troubleshooting issues.

:ballot_box_with_check: Logon to machine `KerbDC2`. The password for the user `a\Install` is `Somepass2`.

:ballot_box_with_check: Start the Wireshark and start also a new network trace.

This will cause some network traffic that the network sniffer running on the domain controller will capture.

As there is a lot of communication that is not interesting we can filter the traffic for Kerberos traffic.

:ballot_box_with_check: Type `Kerberos` into the filter textbox and press enter. If the filter text box is not green something is wrong with the filter.

Now everything is setup and we can logon to the client machine.

:ballot_box_with_check: Logon to the client machine using the account `Install` account of the domain `a`.

We see Kerberos packets showing up in Wireshark almost instantly. There are pretty likely also some SMB and LDAP packets showing up.

There are many tools available to make the Kerberos tickets visible. The only one also shipped with the operating system is `klist.exe`. Another one available on the client is [`kerbtray.exe`](/Tools/kerbtray.exe) which is kind of a graphical version of `klist.exe`.

:ballot_box_with_check: Start `klist.exe` on the client machine and take a look at the tickets in the ticket cache.

:question: How many tickets is the client requesting in total?

:question: Why do we see two Authentication Requests (AS-REQ)? Take a look at the 'padata' field
On which accounts are the SPNs registered the client requests tickets for?

:question: Why does Wireshark include LDAP and SMB packets even if the filter should only allow Kerberos?

<details><summary><h2>Lessons Learned</h2></summary>

:bulb: Kerberos communication can be easily read in a network trace.

:bulb: Kerberos Tickets can be made visible using the tools `klist.exe`.

</details>
