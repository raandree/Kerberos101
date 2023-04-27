# Kerberos 101 Labs

## Unconstrained Delegation

This lab demonstrates a typical issue when working remotely on a machine. From the remote machine you want to access a network share or Active Directory and it does not work at all. Kerberos Delegation seems to be the easy solution to this but it comes with security issues.
First we reproduce the remoting problem and then we configure Kerberos Delegation to work around it.
Logon to the client machine and open a PowerShell
Connect to the web server that is in the same forest / domain as the client using PowerShell remoting. This can be done with the following command. The connect does not work you have not invoked Repair-Lab4
Enter-PSSession –ComputerName <web server name>
The prompt should have changed and reflect that you are working on the remote machine.
Get the directory listing of C:\
Get the directory listing of a remote location, for example the c$ share of the domain controllers that is in the clients domain or the file server
You not be able to access the remote share getting the error “Access denied”. 
Why is the server we have connected to not be able to authenticate us against a third machine?
What does the machine require to authenticate us to a third party?
 
We want to enable Kerberos delegation now. This is done on the computer account of the web server.
Open dsa.msc on the client 
Get the properties of the web server’s account and navigate to the delegation tab
Enable the setting “Trust this computer for delegation to any service (Kerberos only)” and click OK
Restart the web server and re-logon to the client
Connect to the web server again using PowerShell Enter-PSSession
Take a look at your tickets using klist
This is it. Delegation is enabled. After the machine has rebooted, do the first steps of this lab again to connect to the web server and access a remote share from there. It works now and you can access all resources from the remote machine – there is no restriction.
6.	Classical Kerberos Delegation is pretty powerful, maybe too powerful.
7.	Unconstrained delegation works by passing a forwarded TGT to the remote machine. In fact, the remote machine can work with the TGT like you can on your local machine.
Is there another way of allowing a second hop from a remote machine?
What are the downsides when enabling Kerberos delegation on a machine?
