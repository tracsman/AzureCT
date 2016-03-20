function Get-ServerTrace {
 
    # Evaluate and Set input parameters
    [cmdletBinding()]
    Param(
       [Parameter(ValueFromPipeline=$true,
                  Mandatory=$true,
                  HelpMessage='Enter IP Address of Target Machine')]
       [ipaddress]$RemoteHost,
       [int]$DurationMinutes=1,
       [int]$TimeoutSeconds=5
    )

    # Initialize
    $FilePath = $env:TEMP
    $HeaderFileName = "$FilePath\ServerTraceHeader.xml"
    $DetailFileName = "$FilePath\ServerTraceDetail.xml"

    $RunDuration = New-TimeSpan -Minutes $DurationMinutes
    $GoodTraceCaptured = $false
    [int]$MinutesBetweenTracePulls = 1
    $LastTraceTime = (Get-Date) - (New-TimeSpan -Minutes $MinutesBetweenTracePulls)
    [int]$ReferenceTraceID = 0
    [int]$CallCount=0
    [int]$WrapWidth = $Host.UI.RawUI.BufferSize.Width - 5
    $JobID = [System.Guid]::NewGuid().toString()
    $ErrorFlag = $false

    # Check for Header File
    If ((Test-Path $HeaderFileName) -eq $false) {
        [string]$JobHeaderFile = "<?xml version=`"1.0`"?><ServerTraces version=`"$script:XMLSchemaVersion`"><ServerTrace><ID/><StartTime/><EndTime/><Target/><TimeoutSeconds/><CallCount/></ServerTrace></ServerTraces>"
        $JobHeaderFile | Out-File -FilePath $HeaderFileName -Encoding ascii}

    # Check for Detail File
    If ((Test-Path $DetailFileName) -eq $false) {
        [string]$JobDetailFile = "<?xml version=`"1.0`"?><TraceRecords version=`"$script:XMLSchemaVersion`"><TraceRecord><JobID/><CallID/><TimeStamp/><HopID/><Address/><TripTime/></TraceRecord></TraceRecords>"
        $JobDetailFile | Out-File -FilePath $DetailFileName -Encoding ascii}
    
    # Load Files and Get Ready for new run
    # Pull current Header and Detail xml files
    [xml]$JobHeaderFile = Get-Content $HeaderFileName
    [xml]$JobDetailFile = Get-Content $DetailFileName

    # Create new Job Header xml node (in local file)
    $JobStart = Get-Date -Format 's'
    $JobHeader = ""
    $JobHeader = (@($JobHeaderFile.Jobs.Job)[0]).Clone()
    $JobHeader.ID =[string]$JobID
    $JobHeader.StartTime = [string]$JobStart
    $JobHeader.Target = [string]$RemoteHost.IPAddressToString
    $JobHeader.TimeoutSeconds = [string]$TimeoutSeconds
    $JobHeaderFile.Jobs.AppendChild($JobHeader) | Out-Null
    $JobHeaderFile.Save($HeaderFileName)

    # Job Loop, duration as defined by user input
    Try {
        Write-Host
        Write-Host "Starting ServerTrace test to $RemoteHost..." -ForegroundColor Cyan
        Write-Host

        # Run an initial call to load ARP tables and IIS caches along the call path
        Try {
            $TraceReturn = Get-IPTrace -RemoteHost $RemoteHost }
        Catch {}

        $CallArray = @()
        $TraceArray = @()
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
                $TraceArray += Start-Job -ScriptBlock {Get-IPTrace -RemoteHost $args[0] -JobID $args[1] -CallID $args[2]} -Name 'AzureCT.Tracing' -ArgumentList $RemoteHost, $JobID, $CallCount
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

            # Do we need to keep the associated trace?
            # Note: the Tag field is matched at the end of this script
            #       and the trace data for those called tagged "true"
            #       are uploaded to the server.
            If (-Not $GoodTraceCaptured -and $Valid) {
                $GoodTraceCaptured = $true
                $ReferenceTraceID = $CallCount
                $LastTraceTime = Get-Date
                $Tagged = $true
            }
            ElseIf (-Not $Valid -and -Not $ErrorFlag) {
                $ErrorFlag = $true
                $LastTraceTime = Get-Date
                $Tagged = $true
            }
            ElseIf ($LastTraceTime -lt (Get-Date) - (New-TimeSpan -Minutes $MinutesBetweenTracePulls)) {
                $LastTraceTime = Get-Date
                $Tagged = $true
            }
            ElseIf ($Valid) {
                $Tagged = $false
                $ErrorFlag = $false
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
            $JobDetailFile.Save($DetailFileName)

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
            $JobHeaderFile.Save($HeaderFileName)
    
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
        $JobHeaderFile.Save($HeaderFileName)

        # Wait for traces to finish
        While ((Get-Job -Name "AzureCT.Tracing" | Where State -eq 'Running').Count -gt 0) {
            Sleep -Seconds 2
            Write-Host "Waiting for Trace Route jobs to finish..."
        }
        
        # Build the Trace File for Upload
        ForEach ($Node in $JobDetailFile.JobRecords.JobRecord) {
            If ($Node.JobID -eq $JobID -and $Node.Tag -eq "True") {
                $PSJobData = Receive-Job -Job $TraceArray[$Node.CallID - 1]
                ForEach ($TraceRow in $PSJobData) {
                    $TraceNode =""
                    $TraceNode = (@($TraceFile.TraceRecords.TraceRecord)[0]).Clone()
                    $TraceNode.JobID = [string]$TraceRow.JobID
                    $TraceNode.CallID = [string]$TraceRow.CallID
                    $TraceNode.TimeStamp = [string]$TraceRow.TimeStamp
                    $TraceNode.HopID = [string]$TraceRow.HopCount
                    $TraceNode.Address = [string]$TraceRow.Address
                    $TraceNode.TripTime = [string]$TraceRow.RoundTripTime
                    $TraceFile.TraceRecords.AppendChild($TraceNode) | Out-Null
                    $TraceFile.Save($TraceFileName)
                } # End ForEach $TraceRow
            } # End If
        } # End ForEach $Node

        ForEach ($Job in (Get-Job)) {
           Remove-Job $Job
        }

        # Upload Header, Detail, and Trace xml to server
        $uri = "http://$RemoteHost/Upload.aspx"
        $contentType = "multipart/form-data"
        Try {
            $header = @{FileID = "Header"}
            $HeaderUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobHeaderFile.OuterXml -Headers $header -TimeoutSec 10).Content.Trim()

            $header = @{FileID = "Detail"}
            $DetailUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobDetailFile.OuterXml -Headers $header -TimeoutSec 15).Content.Trim()

            $header = @{FileID = "Trace"}
            $TraceUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $TraceFile.OuterXml -Headers $header -TimeoutSec 10).Content.Trim()
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
            Remove-Item $HeaderFileName
            Remove-Item $DetailFileName
            Remove-Item $TraceFileName
        } 
        Else {
            Write-Warning "Data upload to remote server failed."
            Write-Warning "Please check to ensure the remote server has all the files required to run this tool."
            Write-Warning "Also ensure the XML files in the 'c:\inetpub\wwwroot' have 'Full Control' file access for the local IIS_IUSRS account"
        }
        Write-Host
    } # Finally End
} # Function End

