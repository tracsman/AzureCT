function Get-IPTrace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address of Remote Azure VM')]
        [ipaddress] $RemoteHost,
        [System.Guid]$JobID = '00000000-0000-0000-0000-000000000000',
        [int]$CallID=0)

    $FilePath = $env:TEMP
    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions
    $Payload = [byte[]][char[]]'MyData'
    If ($JobID -eq '00000000-0000-0000-0000-000000000000') {
        $WriteFile = $false
    }
    Else {
        $WriteFile = $true
        $TraceFileName = "$FilePath\AvailabilityTrace_$CallID.xml"
    }

    # Check for Trace File
    If ($WriteFile) {
        If ((Test-Path $TraceFileName) -eq $false) {
            [string]$TraceFile = "<?xml version=`"1.0`"?><TraceRecords version=`"$script:XMLSchemaVersion`"><TraceRecord><JobID/><CallID/><TimeStamp/><HopID/><Address/><TripTime/></TraceRecord></TraceRecords>"
            $TraceFile | Out-File -FilePath $TraceFileName -Encoding ascii
        }
        [xml]$TraceFile = Get-Content $TraceFileName
    }

    $i = 1
    while ($i -le 30) {
        $TraceStart = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
        $PingOptions.Ttl = $i
        $Response = $Ping.Send($RemoteHost, 500, $Payload, $PingOptions)
        $Trace = New-Object -TypeName PSObject -Property @{
            HopCount      = $PingOptions.Ttl;
            Address       = $Response.Address;
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
        
        If ($WriteFile) {
            # Create new Trace xml node (in local file)
            $TraceRecord = ""
            $TraceRecord = (@($TraceFile.TraceRecords.TraceRecord)[0]).Clone()
            $TraceRecord.JobID =[string]$JobID
            $TraceRecord.CallID =[string]$CallID
            $TraceRecord.TimeStamp = [string]$TraceStart
            $TraceRecord.HopID = [string]$Trace.HopCount
            $TraceRecord.Address = [string]$Trace.Address
            $TraceRecord.TripTime = [string]$Trace.RoundTripTime
            $TraceFile.TraceRecords.AppendChild($TraceRecord) | Out-Null
            $TraceFile.Save($TraceFileName)
        }
        
        If ($TraceStatus -eq 'Success') {Break}

        $i++
    } # End While

} # End Function
