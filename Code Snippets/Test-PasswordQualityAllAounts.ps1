$accounts = Get-ADReplAccount -All -Server kerbdc2
$accounts | Test-ADReplPasswordQuality
