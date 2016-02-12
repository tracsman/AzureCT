function Get-IPTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address of Remote Azure VM')]
        [ipaddress] $RemoteHost,
        [System.Guid]$JobID = '00000000-0000-0000-0000-000000000000',
        [int]$CallID=0)

    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $Payload = [byte[]][char[]]'MyData'

    $i = 1
    while ($i -le 30) {
        $TraceStart = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
        $PingOptions.Ttl = $i
        $Response = $Ping.Send($RemoteHost, 500, $Payload, $PingOptions)
        $Trace = New-Object -TypeName PSObject -Property @{
            JobID         = $JobID
            CallID        = $CallID
            TimeStamp     = $TraceStart
            HopCount      = $PingOptions.Ttl
            Address       = $Response.Address
            RoundTripTime = $Response.RoundtripTime
            }
        $TraceStatus = $Response.Status
        If ($TraceStatus -eq 'TtlExpired') {
            $PingOptions.Ttl = $i + 2
            $Response = $Ping.Send($Trace.Address, 500, $Payload, $PingOptions)
            If ($Response.Status -eq 'TimedOut') {
                $Trace.RoundTripTime = '*'
            }
            Else {
                $Trace.RoundTripTime = $Response.RoundtripTime
            }
        }
        ElseIf ($TraceStatus -eq 'TimedOut') {
            $Trace.Address = 'Hop Timeout'
            $Trace.RoundTripTime = '*'
        }
        Write-Output -InputObject $Trace
        
        If ($TraceStatus -eq 'Success') {Break}

        $i++
    } # End While

} # End Function