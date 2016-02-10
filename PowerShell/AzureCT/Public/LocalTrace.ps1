function Get-IPTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address of Remote Azure VM')]
        [ipaddress] $RemoteHost)

    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $Payload = [byte[]][char[]]'MyData'
    $i = 1

    while ($i -le 30) {
        $PingOptions.Ttl = $i
        $Response = $Ping.Send($RemoteHost, 1500, $Payload, $PingOptions)
        $Trace = New-Object -TypeName PSObject -Property @{
            TTL           = $PingOptions.Ttl;
            Address       = $Response.Address;
            RoundTripTime = $Response.RoundtripTime;
            MachineName   = ''
            }
        $TraceStatus = $Response.Status
        If ($TraceStatus -eq 'Success') {
            $Trace.MachineName   = Get-HostName $Trace.Address
            Write-Output -InputObject $Trace
            Break
        }
        ElseIf ($TraceStatus -eq 'TtlExpired') {
            $PingOptions.Ttl = $i + 2
            $Response = $Ping.Send($Trace.Address, 1500, $Payload, $PingOptions)
            If ($Response.Status -eq 'TimedOut') {
                $Trace.MachineName   = Get-HostName $Trace.Address
                $Trace.RoundTripTime = '*'
            }
            Else {
                $Trace.RoundTripTime = $Response.RoundtripTime
                $Trace.MachineName   = Get-HostName $Trace.Address
            }
        }
        ElseIf ($TraceStatus -eq 'TimedOut') {
            #$Trace.MachineName   = Get-HostName $Trace.Address
            $Trace.Address = 'Hop Timeout'
            $Trace.RoundTripTime = '*'
        }
        Write-Output -InputObject $Trace
        
        $i++
    } # End While

}

function Get-HostName {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address')]
        [ipaddress] $HostIP)
    Try {
        Return [System.Net.Dns]::GetHostEntry($HostIP).HostName
    }
    Catch {
        Return ''
    }
}

Get-IPTrace -RemoteHost 10.249.172.52

# $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
# $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
# $PingOptions.Ttl = 12
# $Payload = [byte[]][char[]]'MyData1'
# $foo = $Ping.Send('10.249.172.52', 1000, $Payload, $PingOptions)