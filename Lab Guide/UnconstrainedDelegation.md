# Kerberos 101 Labs

## Unconstrained Delegation

This lab demonstrates a typical issue when working remotely on a machine. Accessing remote resources from a remote machine does not work. This scenario is called a "double hop authentication".

In this task you want to access a network share or any other remote resource from a remote machine. This does not work. You will discover that Kerberos Delegation is the easiest solution in the case but it comes with security issues.

First we discover the scenario without delegation. Then we will enable it and examine the differences between an authentication with and without Kerberos Delegation.

:ballot_box_with_check: Logon to the client machine and open a PowerShell
:ballot_box_with_check: Connect to the web server `KerbWeb2` which is in the same forest / domain as the client using PowerShell remoting

:warning: Connecting to the web server does not work you have not yet called invoked `Repair-Lab4`.

:warning: It is always helpful to do a network trace to get more information about what's going on.

```powershell
Enter-PSSession –ComputerName KerbWeb2
```

The prompt should have changed and reflect that you are working on the remote machine.

:information:

:ballot_box_with_check: Get the directory listing of a remote location, for example the `SYSVOL` share of the domain controller `KerbDC2` or the `c$` share if the file server `KerbFile2`.

```powershell
dir \\kerbdc2\SYSVOL\
dir \\kerbfile2\c$
```

You will not be able to access the remote shares and will be seeing the error `Access is denied`.

:ballot_box_with_check: Take a look at the `http` ticket for the target account `KerbFile2` and make a note of the ticket flags.

:question: Why is the server we have connected to not be able to authenticate us against a third machine?
:question: What does a user require to authenticate us to another remote system from a remote system?

Now we want to enable Kerberos delegation. This is done on the computer account of the web server.

:ballot_box_with_check: Open `dsa.msc` (Active Directory Users and Computers) on the client.
:ballot_box_with_check: Open the properties of the web server’s account and navigate to the delegation tab.
:ballot_box_with_check: Enable the setting “Trust this computer for delegation to any service (Kerberos only)” and click OK.
:ballot_box_with_check: Then restart the web server and re-logon to the client

Now it is time to test accessing the remote shares from the remote machine again.

:ballot_box_with_check: Connect to the web server `KerbWeb2` again using PowerShell's `Enter-PSSession`.
:ballot_box_with_check: Try to access access a remote share again. This time it should work.
:ballot_box_with_check: Take a look at your tickets using `klist` on the `KerbCliet2` and compare the ticket options.

:question: What is the difference between the `http` ticket in a delegation and non-delegation scenario?
:question: Which ticket has been forwarded to the remote machine (`KerbWeb2`) so we can do another authentication, the so called "double hop"?
:question: Is there another way of allowing a second hop from a remote machine?
:question: What are the downsides when enabling Kerberos delegation on a machine?

<details><summary><h2>Lessons Learned</h2></summary>

:bulb: In a non-delegation scenario the ticket options of a service ticket are: `forwardable renewable pre_authent name_canonicalize`. If the target is trusted for delegation, the service ticket gets the option `ok_as_delegate` additionally.

:bulb: When receiving a service ticket from the KDC with the option `ok_as_delegate`, the Kerberos clients requests a second TGT with the option `forwarded`. This second TGT is forwarded to the target machine and the target machine can act on the behalf of the sender.

</details>
