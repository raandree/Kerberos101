# Kerberos 101 Labs

## Get familiar with the lab environment

### Virtual Machines

:ballot_box_with_check: Open the console to you virtualization solution, for example the Hyper-V console. You should have these machines available:

Name | Role | Comment
--- | --- | ---
KerbDC0 | Domain Controller | Domain Controller for `test.net`
KerbDC1 | Domain Controller | Domain Controller in `vm.net`
KerbDC2 | Domain Controller | Domain Controller in `a.vm.net`
KerbFile2 | File Server | File Server in `a.vm.net`
KerbSql21 | SQL Server 2019 | SQL Server 1 in `a.vm.net`
KerbSql22 | SQL Server 2019 | SQL Server 2 in `a.vm.net`
KerbWeb0 | Web Server | Web Server in `test.net`
KerbWeb2 | Web Server | Web Server in `a.vm.net`
**KerbClient2** | **Server** | **Workstation in `a.vm.net` that is used for most tasks**

### Credentials

The administrative accounts for the domains are as follows:

Domain | Username | Password
--- | --- | ---
test.net | Install | Somepass0
vm.net | Install | Somepass1
a.vm.net | Install | Somepass2

### Active Directory Domains

Name | Comment
--- | ---
vm.net | Working forest's empty root domain
a.vm.net | Working domain
test.net | Foreign forest

:ballot_box_with_check: Please open 'Active Directory Users and Computers' (`dsa.msc`) and examine the Active Directory of the lab environment.

:ballot_box_with_check: 'Please open 'Active Directory Domains and Trusts' (`domain.msc`) and examine the domain structure and trusts.
