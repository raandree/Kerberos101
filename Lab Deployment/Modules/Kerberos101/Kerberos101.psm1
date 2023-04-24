#region Internals
function Get-ADComputerSPNs
{
	param(
		[string]$ComputerName
	)
	
	$computer = Get-ADComputer -Identity $ComputerName -Properties ServicePrincipalName
	$computer.ServicePrincipalName
}
#endregion

$computers = @{
	FileServer = "KerbFile1.a.vm.net";
	SqlServer = "KerbSql1.a.vm.net";
	DC1 = "KerbDC2.a.vm.net";
	Client = "KerbClient2.a.vm.net";
}

#region Lab2
function Start-Lab4
{
	<#
	.SYNOPSIS
		Does the changes required for lab 4
		
	.DESCRIPTION
		Removes the host SPN from the file server and adds them to the SQL server
	
	.INPUTS
		System.String
	
	.OUTPUTS
		Null
	#>

	$computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.FileServer))" -Properties ServicePrincipalName	
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }
	
	$computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.SqlServer))" -Properties ServicePrincipalName	
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }

    Write-Host "Machine account $($computers.FileServer) prepared for lab 4"
}

function Repair-Lab4
{
	<#
	.SYNOPSIS
		Repairs the changes made for lab 4
		
	.DESCRIPTION
		Removes the file server's SPNs from the SQL server account and adds them to the file server computer account.
	
	.INPUTS
		System.String
	
	.OUTPUTS
		Null
	#>

    $computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.SqlServer))" -Properties ServicePrincipalName
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }	

    $computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.FileServer))" -Properties ServicePrincipalName	
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }

    Write-Host "Undone changes mode to machine account $($computers.FileServer) for lab 4"
}
#endregion

function Get-SqlData1
{
	$connection = New-Object System.Data.SqlClient.SqlConnection("Data Source=$((Test-Connection -ComputerName $computers.SqlServer -Count 1).IPV4Address.IPAddressToString);Initial Catalog=pubs;Integrated Security=SSPI;")
	$connection.Open()

	$command = New-Object System.Data.SqlClient.SqlCommand
	$command.Connection = $connection
	$command.CommandText = "SELECT * FROM authors"
	$command.CommandType = "Text"

	$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$dataAdapter.SelectCommand = $command
	$dataSet = New-Object System.Data.DataSet
	$numberOfRecords = $dataAdapter.Fill($dataSet)

	$connection.Close()
	
	Write-Host ("Read {0} records from the pubs database" -f $numberOfRecords)
}

function Get-SqlData2
{
	$connection = New-Object System.Data.SqlClient.SqlConnection("Data Source=$($computers.SqlServer);Initial Catalog=pubs;Integrated Security=SSPI;")
	$connection.Open()

	$command = New-Object System.Data.SqlClient.SqlCommand
	$command.Connection = $connection
	$command.CommandText = "SELECT * FROM authors"
	$command.CommandType = "Text"

	$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$dataAdapter.SelectCommand = $command
	$dataSet = New-Object System.Data.DataSet
	$numberOfRecords = $dataAdapter.Fill($dataSet)

	$connection.Close()
	
	Write-Host ("Read {0} records from the pubs database" -f $numberOfRecords)
}

#region Lab1
function Start-Lab3
{
	<#
	.SYNOPSIS
		Does the changes required for lab 3
		
	.DESCRIPTION
		Adds the file server's SPNs on the client computer account for the client machine.
	
	.INPUTS
		System.String
	
	.OUTPUTS
		Null
	#>

	$computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.FileServer))" -Properties ServicePrincipalName	
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Remove = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }

    Write-Host "Machine account $($computers.FileServer) prepared for lab 3"
}

function Repair-Lab3
{
	<#
	.SYNOPSIS
		Repairs the changes made for lab 3
		
	.DESCRIPTION
		Removes the file server's SPNs from the computer account for the client machine.
	
	.INPUTS
		System.String
	
	.OUTPUTS
		Null
	#>

	$computer = Get-ADComputer -LDAPFilter "(dNSHostName=$($computers.FileServer))" -Properties ServicePrincipalName
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($Computers.FileServer)" }
	Set-ADComputer -Identity $computer -ServicePrincipalNames @{ Add = "HOST/$($computers.FileServer.Substring(0, $computers.FileServer.IndexOf('.')))" }

    Write-Host "Undone changes mode to machine account $($computers.FileServer) for lab 3"
}
#endregion
