$sessions = klist sessions
$pattern = '\[(\d+)\] Session \d \d:(?<LowPart>0)x(?<HighPart>[a-f0-9]+)'

$sessions = foreach ($line in $sessions)
{
    if ($line -match $pattern)
    {
        New-Object PSObject -Property @{
            LowPart = $Matches.LowPart
            HighPart = $Matches.HighPart
        }
    }
}

$sessionsTickets = foreach ($session in $sessions)
{
    $result = New-Object PSObject -Property @{
        Session = "$($session.LowPart)x$($session.HighPart)"
        Tickets = klist tickets -lh $session.LowPart -li $session.HighPart
    }

    Write-Host "'klist tickets -lh $($session.LowPart) -li $($session.HighPart)' knows about $($result.Tickets.Count) tickets"

    $result
}

#to view all tickets
$sessionsTickets.Tickets | clip
