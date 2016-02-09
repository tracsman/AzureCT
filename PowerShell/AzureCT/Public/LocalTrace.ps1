function LocalTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address of Remote Azure VM')]
        [ipaddress] $RemoteHost)

    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $Payload = [byte[]][char[]]'MyData1'
    $i = 1

    while ($i -lt 30) {
        $PingOptions.Ttl = $i
        $Response = $Ping.Send($RemoteHost, 1000, $Payload, $PingOptions)
        $Trace = New-Object -TypeName PSObject -Property @{
            TTL           = $PingOptions.Ttl;
            Status        = $Response.Status;
            Address       = $Response.Address;
            RoundTripTime = $Response.RoundtripTime;
            }
        If ($Trace.Status -eq 'Success') {break}
        Write-Output -InputObject $Trace
        
        $i++
    } # End While
    $Trace
}

LocalTrace -RemoteHost 10.249.172.52