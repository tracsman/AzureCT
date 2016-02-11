function Get-IPTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address of Remote Azure VM')]
        [ipaddress] $RemoteHost,
        [System.Guid]$JobID = '00000000-0000-0000-0000-000000000000',
        [int]$CallID=0)

    $FilePath = $env:TEMP
    $XMLSchemaVersion = "1.6"
    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $Payload = [byte[]][char[]]'MyData'
    If ($JobID -eq '00000000-0000-0000-0000-000000000000') {
        $WriteFile = $false
    }
    Else {
        $WriteFile = $true
    }

    # Check for Trace File
    If ($WriteFile) {
        If ((Test-Path "$FilePath\AvailabilityTrace.xml") -eq $false) {
            [string]$TraceFile = "<?xml version=`"1.0`"?><TraceRecords version=`"$JobSchemaVersion`"><TraceRecord><JobID/><CallID/><TimeStamp/><HopID/><Address/><TripTime/><MachineName/></TraceRecord></TraceRecords>"
            $TraceFile | Out-File -FilePath "$FilePath\AvailabilityTrace.xml" -Encoding ascii
        }
        [xml]$TraceFile = Get-Content "$FilePath\AvailabilityTrace.xml"
    }

    $i = 1
    while ($i -le 30) {
        $TraceStart = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
        $PingOptions.Ttl = $i
        $Response = $Ping.Send($RemoteHost, 1500, $Payload, $PingOptions)
        $Trace = New-Object -TypeName PSObject -Property @{
            HopCount      = $PingOptions.Ttl;
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
            $Trace.Address = 'Hop Timeout'
            $Trace.RoundTripTime = '*'
        }
        Write-Output -InputObject $Trace
        
        If ($WriteFile) {
            # Create new Trace xml node (in local file)
            $TraceRecord = ""
            $TraceRecord = (@($TraceFile.TraceRecords.TraceRecord)[0]).Clone()
            $TraceRecord.JobID =[string]$JobID
            $TraceRecord.CallID =[string]$CallID
            $TraceRecord.TimeStamp = [string]$TraceStart
            $TraceRecord.HopID = [string]$Trace.TTL
            $TraceRecord.Address = [string]$Trace.Address
            $TraceRecord.TripTime = [string]$Trace.RoundTripTime
            $TraceRecord.MachineName = [string]$Trace.MachineName
            $TraceFile.TraceRecords.AppendChild($TraceRecord) | Out-Null
            $TraceFile.Save("$FilePath\AvailabilityTrace.xml")
        }
        
        $i++
    } # End While

} # End Function


# Get-IPTrace -RemoteHost 10.249.172.52 -JobID $JobID -CallID 7

# $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
# $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
# $PingOptions.Ttl = 12
# $Payload = [byte[]][char[]]'MyData1'
# $foo = $Ping.Send('10.249.172.52', 1000, $Payload, $PingOptions)