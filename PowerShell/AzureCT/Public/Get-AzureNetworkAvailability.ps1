function Get-AzureNetworkAvailability {
    <#
    .SYNOPSIS
        Makes repeated calls to a web site on a private vnet and logs the success/failure and response times.

    .DESCRIPTION
        Generate, collect, and store availability statistics of the network between you and a newly built Windows VM in Azure.
        It is designed to provide an indication, over time, of the link between a Virtual Machine in Azure and an on-premise
        network. While the focus is on network availability, the test is done from a PC client to an IIS server in Azure.
        This provides a view into the availability of an end-to-end scenario, not just a single point or component in the
        complex chain that makes up a VPN or an ExpressRoute network connection. The hope is that this will provide insight
        into the end-to-end network availability.
        
        The resultant data set does not provide rich insight if a problem is encountered during a test, over time this will
        improve but this initial release only reflects the statistics around availability seen while an active test is running.

        Local Host Output of this command will show:
         ! - Successfull Call
         . - Unsuccsefull Call (timeout)
         * - IP was reached but wrong data or error (404) was returned

        At the end of this function a summary block will display summary information of the entire data set collect.
        The data set, stored locally in XML, will be uploaded to the IIS server in Azure.
        At the conslusion of this command a web browser will be initiated to show a web page from the IIS Server to observe
        the collected data.

    .PARAMETER RemoteHost
        This parameter is required and is the Azure VM VNet IP Address.

    .PARAMETER DurationMinutes
        This optional parameter signifies the duration of the Get-AzureNetworkAvailability command in minutes. It is an
        integer value (whole number). The default value is 1.

    .PARAMETER TimeoutSeconds
        This optional parameter signifies how long each call will wait for a response. The default value is 5 seconds.

    .EXAMPLE
        Get-AzureNetworkAvailability -RemoteHost 10.0.0.1

        # Get network availability stats from a web server at 10.0.0.1 for one minute (default duration)

    .EXAMPLE
        Get-AzureNetworkAvailability -RemoteHost 10.0.0.1 -DurationMinutes 600

        # Get network availability stats from a web server at 10.0.0.1 for ten hours (600 minutes)

    .EXAMPLE
        (Get-AzureVM -ServiceName 'myServiceName' -Name 'myVMName').IpAddress | Get-AzureNetworkAvailability

        # Pull local IP address from a VM in Azure and pipe it to the Get-AzureNetworkAvailability cmdlet

    .LINK
        https://github.com/tracsman/AzureCT

    .LINK
        Show-Results

    .LINK
        Clear-History

    .NOTES
        A specially built IIS server running in Azure is required for this cmdlet to work properly.
        More information can be found at https://github.com/tracsman/AzureCT

    #>

    # Evaluate and Set input parameters
    [cmdletBinding()]
    Param(
       [Parameter(ValueFromPipeline=$true,
                  Mandatory=$true,
                  HelpMessage='Enter IP Address of Remote Azure VM')]
       [ipaddress]$RemoteHost,
       [int]$DurationMinutes=1,
       [int]$TimeoutSeconds=5
    )

    # Initialize
    $FilePath = $env:TEMP
    $RunDuration = New-TimeSpan -Minutes $DurationMinutes
    $GoodTraceCaptured = $false
    [int]$MinutesBetweenTracePulls = 1
    $LastTraceTime = (Get-Date) - (New-TimeSpan -Minutes $MinutesBetweenTracePulls)
    [int]$ReferenceTraceID = 0
    [int]$CallCount=0
    [int]$JobGood=0
    [int]$JobBad=0
    [int]$JobMin=2000000000
    [int]$JobMax=0
    [int]$JobMedian=0
    [int]$WrapWidth = $Host.UI.RawUI.BufferSize.Width - 5
    $JobID = [System.Guid]::NewGuid().toString()

    # Check for Header File
    If ((Test-Path "$FilePath\AvailabilityHeader.xml") -eq $false) {
        [string]$JobHeaderFile = "<?xml version=`"1.0`"?><Jobs version=`"$script:XMLSchemaVersion`"><Job><ID/><StartTime/><EndTime/><Target/><TimeoutSeconds/><CallCount/><SuccessRate/><JobMin/><JobMax/><JobMedian/><ReferenceTrace/></Job></Jobs>"
        $JobHeaderFile | Out-File -FilePath "$FilePath\AvailabilityHeader.xml" -Encoding ascii}

    # Check for Detail File
    If ((Test-Path "$FilePath\AvailabilityDetail.xml") -eq $false) {
        [string]$JobDetailFile = "<?xml version=`"1.0`"?><JobRecords version=`"$script:XMLSchemaVersion`"><JobRecord><JobID/><CallID/><TimeStamp/><Return/><Display/><Valid/><Duration/><Tag/></JobRecord></JobRecords>"
        $JobDetailFile | Out-File -FilePath "$FilePath\AvailabilityDetail.xml" -Encoding ascii}

    # Load Files and Get Ready for new run
    # Pull current Header and Detail xml files
    [xml]$JobHeaderFile = Get-Content "$FilePath\AvailabilityHeader.xml"
    [xml]$JobDetailFile = Get-Content "$FilePath\AvailabilityDetail.xml"

    # Create new Job Header xml node (in local file)
    $JobStart = Get-Date -Format 's'
    $JobHeader = ""
    $JobHeader = (@($JobHeaderFile.Jobs.Job)[0]).Clone()
    $JobHeader.ID =[string]$JobID
    $JobHeader.StartTime = [string]$JobStart
    $JobHeader.Target = [string]$RemoteHost.IPAddressToString
    $JobHeader.TimeoutSeconds = [string]$TimeoutSeconds
    $JobHeaderFile.Jobs.AppendChild($JobHeader) | Out-Null
    $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")

    # Job Loop, duration as defined by user input
    Try {
        Write-Host
        Write-Host "Starting Avilability test to $RemoteHost..." -ForegroundColor Cyan
        Write-Host

        # Run an initial call to load ARP tables and IIS caches along the call path
        Try {
            $WebCall = (Invoke-WebRequest -Uri http://$RemoteHost/WebTest.aspx -TimeoutSec 1)}
        Catch {}

        $CallArray = @()
        Do {
            $CallCount+=1
            $CallTime = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
            $ErrorType = "None"
            $CallDisplay = "n" # Null, this should never show
            $CallDisplayDescription = "Null" # This should never show

            # Call WebTest.aspx
             ###########################################
            #  The following line is the magic, it is   #
            #  the actual connectivity test being run.  #
            #  $WebCall holds the results of the test.  #
            #  $CallDuration is the call duration in ms.#
             ###########################################

            Try {
                $CallDuration = Measure-Command {$WebCall = (Invoke-WebRequest -Uri http://$RemoteHost/WebTest.aspx -TimeoutSec $TimeoutSeconds)}

                # Pull server data from the test
                $ServerTime = ($WebCall.AllElements | ? {$_.tagName -eq 'HEAD'}).innerText
                $Result = ($WebCall.AllElements | ? {$_.tagName -eq 'BODY'}).innerText
            }
            Catch {
                if ($error[0].Exception.Status -eq "Timeout") {$ErrorType = "Timeout"} 
                Else {$ErrorType = "Other"} # Other Error, probably 404
                $WebCall = ""
                $CallDuration = ""
                $ServerTime = ""
                Try {$Result = $error[0].Exception.Message.ToString()}
                Catch {$Result = "Unknown Error"}
            }
            # Validate Server Return
            $Valid = [bool]($Result.Trim() -eq '1.0')
    
            If ($Valid) {$CallDisplay="!"; $CallDisplayDescription="Valid Call Response"} 
            Elseif ($ErrorType -eq "None") {$CallDisplay="*"; $CallDisplayDescription="Bad Data Returned"; $Result = "Page Title: " + (($WebCall.AllElements | ? {$_.tagName -eq 'TITLE'}).innerText)}
            Elseif ($ErrorType -eq "Timeout") {$CallDisplay="."; $CallDisplayDescription="Timeout"}
            Else {$CallDisplay="*"; $CallDisplayDescription="Call Response Error"}

            # Do we need to trace?
            If (-Not $GoodTraceCaptured -and $Valid) {
                Start-Job -ScriptBlock {Get-IPTrace -RemoteHost $args[0] -JobID $args[1] -CallID $args[2]} -Name 'AzureCT.Tracing' -ArgumentList $RemoteHost, $JobID, $CallCount | Out-Null
                $GoodTraceCaptured = $true
                $ReferenceTraceID = $CallCount
                $Tagged = $true
            }
            ElseIf (-Not $Valid -and $LastTraceTime -lt (Get-Date) - (New-TimeSpan -Minutes $MinutesBetweenTracePulls)) {
                Start-Job -ScriptBlock {Get-IPTrace -RemoteHost $args[0] -JobID $args[1] -CallID $args[2]} -Name 'AzureCT.Tracing' -ArgumentList $RemoteHost, $JobID, $CallCount | Out-Null
                $LastTraceTime = Get-Date
                $Tagged = $true
            }
            Else {
                $Tagged = $false
            }

            # Update Counters
            If ($Valid) {$JobGood+=1} Else {$JobBad+=1}
            [decimal]$SuccessRate = $JobGood/$CallCount*100
            $SuccessRate = "{0:N2}" -f $SuccessRate
            If ($CallDuration.TotalMilliseconds -lt $JobMin) {$JobMin = $CallDuration.TotalMilliseconds}
            If ($CallDuration.TotalMilliseconds -gt $JobMax) {$JobMax = $CallDuration.TotalMilliseconds}
            If ($Valid) {$CallArray += $CallDuration.TotalMilliseconds}

            # Create Job Details xml
            $JobDetail=""
            $JobDetail = (@($JobDetailFile.JobRecords.JobRecord)[0]).Clone()
            $JobDetail.JobID = [string]$JobID
            $JobDetail.CallID = [string]$CallCount
            $JobDetail.TimeStamp = [string]$CallTime
            $JobDetail.Return = $Result
            $JobDetail.Display = $CallDisplayDescription
            $JobDetail.Valid = [string]$Valid
            $JobDetail.Duration = [string]$CallDuration.TotalMilliseconds
            $JobDetail.Tag = [string]$Tagged

            # Log new results xml to local file
            $JobDetailFile.JobRecords.AppendChild($JobDetail) | Out-Null
            $JobDetailFile.Save("$FilePath\AvailabilityDetail.xml")

            # Log summary results to local file
            ForEach($Node in $JobHeaderFile.Jobs.Job) { 
                If ($Node.ID -eq $JobID) {
                    $UpdatedNode = $Node
                    $UpdatedNode.CallCount = [string]$CallCount
                    $UpdatedNode.SuccessRate = [string]$SuccessRate
                    $UpdatedNode.JobMin = [string]$JobMin
                    $UpdatedNode.JobMax = [string]$JobMax
                    $UpdatedNode.ReferenceTrace = [string]$ReferenceTraceID
                    $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node) | Out-Null
                    }}
            $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")
    
            # Write output
            Write-Host $CallDisplay -NoNewline
            If ($CallCount%$WrapWidth -eq 0) {Write-Host}
    
            # Decide how long to sleep
            $SleepTime = 10000 - ((Get-Date) - [datetime]$CallTime).TotalMilliseconds
            If ($SleepTime -lt 0) {$SleepTime = 0}
            sleep -Milliseconds $SleepTime
        } # Do End
        While (([datetime]$JobStart + $RunDuration) -gt (Get-Date))
    } # Try End

    Finally {
        # Calculate end of job stats
        $JobEnd = Get-Date -Format 's'

        # Get Median Call Latency
        $CallArray = $CallArray | Sort
        If ($CallArray.count -eq 0) {
            $JobMedian = 0
        }
        ElseIf ($CallArray.count%2) {
            $JobMedian = $CallArray[[math]::Floor($CallArray.count/2)]
        }
        Else {
            $JobMedian = ($CallArray[$CallArray.Count/2],$CallArray[$CallArray.count/2-1] | Measure -Average).Average
        }  

        # Write summary host output
        Write-Host
        Write-Host
        Write-Host "Statistics for $RemoteHost"

        Write-Host "    Calls: Sent = " -NoNewline
        Write-Host $CallCount -NoNewline
        Write-Host ", Received = " -NoNewline
        Write-Host $JobGood -NoNewline -ForegroundColor Green
        Write-Host " (" -NoNewline
        Write-Host $SuccessRate"%" -NoNewline -ForegroundColor Green
        Write-Host "), Lost = " -NoNewline
        Write-Host $JobBad -ForegroundColor Red

        Write-Host "Approximate round trip times in milli-seconds:"
        Write-Host "    Minimum = " -NoNewline
        Write-Host $JobMin -NoNewline
        Write-Host "ms, Maximum = " -NoNewline
        Write-Host $JobMax -NoNewline
        Write-Host "ms, Median = " -NoNewline
        Write-Host $JobMedian -NoNewline
        Write-Host "ms"

        Write-Host 

        # Update Job Header xml in local file
        ForEach($node in $JobHeaderFile.Jobs.Job) {
            If ($node.ID -eq $JobID) {
                $UpdatedNode = $Node
                $UpdatedNode.EndTime = [string]$JobEnd
                $UpdatedNode.JobMedian = [string]$JobMedian
                $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node) | Out-Null
                }
        }
        $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")

        # Wait for traces to finish
        While ((Get-Job -Name "AzureCT.Tracing" | Where State -eq 'Running').Count -gt 0) {
            Sleep -Seconds 2
            Write-Host "Waiting for Trace Route jobs to finish..."
        }

        # Upload Header and Detail xml to server
        $uri = "http://$RemoteHost/Upload.aspx"
        $contentType = "multipart/form-data"
        Try {
            $header = @{FileID = "Header"}
            $HeaderUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobHeaderFile.OuterXml -Headers $header -TimeoutSec 10).Content.Trim()

            $header = @{FileID = "Detail"}
            $DetailUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobDetailFile.OuterXml -Headers $header -TimeoutSec 15).Content.Trim()

            $header = @{FileID = "Trace"}
            ForEach ($TraceFileName in (Get-ChildItem -Path $FilePath -Filter "AvailabilityTrace*.xml").Name) {
                [xml]$TraceFile = Get-Content "$FilePath\$TraceFileName"
                $TraceUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $TraceFile.OuterXml -Headers $header -TimeoutSec 10).Content.Trim()
            }
        }
        Catch {
            $HeaderUploadResponse = "Bad"
            $DetailUploadResponse = "Bad"
            $TraceUploadResponse = "Bad"
        }

        Write-Host
        If ($HeaderUploadResponse -eq "Good" -and $DetailUploadResponse -eq "Good" -and $TraceUploadResponse -eq "Good") {
            Write-Host "Data uploaded to remote server sucessfully"

            # Spawn local web browser showing report details from server
            Write-Host "Launching browser to http://$RemoteHost"
            Start-Process -FilePath "http://$RemoteHost"

            # Close and Clean Up
            # Clean up local files 
            Remove-Item "$FilePath\AvailabilityHeader.xml"
            Remove-Item "$FilePath\AvailabilityDetail.xml"
            Remove-Item "$FilePath\AvailabilityTrace*.xml"
        } 
        Else {
            Write-Warning "Data upload to remote server failed."
            Write-Warning "Please check to ensure the remote server has all the files required to run this tool."
            Write-Warning "Also ensure the XML files in the 'c:\inetpub\wwwroot' have 'Full Control' file access for the local IIS_IUSRS account"
        }
        Write-Host
    } # Finally End
} # Function End

