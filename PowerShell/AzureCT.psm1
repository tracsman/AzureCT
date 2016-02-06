
function Get-AzureNetworkAvailabity {
    # Get-AzureNetworkAvailability
    # This script makes repeated calls to a web site on
    # a private vnet and logs the success/failure and
    # response times.
    #
    # Script Output
    # ! - Successfull Call
    # . - Unsuccsefull Call (timeout)
    # * - IP was reached but wrong data or error (404) was returned
    #
    # Execution Plan
    # 1. Evaluate and Set input parameters
    # 2. Initialize
    # 3. Load Files and Get Ready for new run
    # 3.1 Pull current Header and Detail xml files
    # 3.2 Generate JobID
    # 4. Create new Job Header xml node (in local file)
    # 5. Job Loop, duration as defined by user input
    # 5.1 Call WebTest.aspx
    # 5.2 Create Results xml
    # 5.3 Log new results xml to local file
    # 5.4 Log summary results to local file
    # 5.5 Repeat
    # 6. Calculate end of job stats
    # 7. Update Job Header xml in local file
    # 8. Upload Header and Detail xml to server
    # 9. Spawn local web browser showing report details from server
    #10. Close and Clean Up
    #

    # 1. Evaluate and Set input parameters
    Param(
       [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
       [ipaddress]$RemoteHost,
       [int]$DurationMinutes=1,
       [int]$TimeoutSeconds=5
    )

    # 2. Initialize
    $FilePath = $env:TEMP
    $JobSchemaVersion = "1.6"
    $RunDuration = New-TimeSpan -Minutes $DurationMinutes

    # Check for Header File
    If ((Test-Path "$FilePath\AvailabilityHeader.xml") -eq $false) {
        [string]$JobHeaderFile = "<?xml version=`"1.0`"?><Jobs version=`"$JobSchemaVersion`"><Job><ID/><StartTime/><EndTime/><Target/><TimeoutSeconds/><CallCount/><SuccessRate/><JobMin/><JobMax/><JobMedian/></Job></Jobs>"
        $JobHeaderFile | Out-File -FilePath "$FilePath\AvailabilityHeader.xml" -Encoding ascii}

    # Check for Detail File
    If ((Test-Path "$FilePath\AvailabilityDetail.xml") -eq $false) {
        [string]$JobDetailFile = "<?xml version=`"1.0`"?><JobRecords version=`"$JobSchemaVersion`"><JobRecord><JobID/><CallID/><TimeStamp/><Return/><Display/><Valid/><Duration/></JobRecord></JobRecords>"
        $JobDetailFile | Out-File -FilePath "$FilePath\AvailabilityDetail.xml" -Encoding ascii}

    [int]$CallCount=0
    [int]$JobGood=0
    [int]$JobBad=0
    [int]$JobMin=2000000000
    [int]$JobMax=0
    [int]$JobMedian=0
    [int]$WrapWidth = $Host.UI.RawUI.BufferSize.Width - 5

    # 3. Load Files and Get Ready for new run
    # 3.1 Pull current Header and Detail xml files
    [xml]$JobHeaderFile = Get-Content "$FilePath\AvailabilityHeader.xml"
    [xml]$JobDetailFile = Get-Content "$FilePath\AvailabilityDetail.xml"

    # 3.2 Generate JobID
    $JobID = [System.Guid]::NewGuid().toString()

    # 4. Create new Job Header xml node (in local file)
    $JobStart = Get-Date -Format 's'
    $JobHeader = ""
    $JobHeader = (@($JobHeaderFile.Jobs.Job)[0]).Clone()
    $JobHeader.ID =[string]$JobID
    $JobHeader.StartTime = [string]$JobStart
    $JobHeader.Target = [string]$RemoteHost.IPAddressToString
    $JobHeader.TimeoutSeconds = [string]$TimeoutSeconds
    $foo = $JobHeaderFile.Jobs.AppendChild($JobHeader)
    $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")

    # 5. Job Loop, duration as defined by user input
    Write-Host
    Write-Host "Starting Avilability test to $RemoteHost..." -ForegroundColor Cyan
    Write-Host

    $CallArray = @()
    Do {
        $CallCount+=1
        # Get local time to save later in results
        $CallTime = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
        $ErrorType = "None"
        $CallDisplay = "n" # Null, this should never show
        $CallDisplayDescription = "Null" # This should never show

        # Run an initial call to load ARP and IIS caches along the call path
        Try {
            $WebCall = (Invoke-WebRequest -Uri http://$RemoteHost/WebTest.aspx -TimeoutSec 1)}
        Catch {}
    
        # 5.1 Call WebTest.aspx
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
            $Result = $error[0].Exception.Message
            }
        # Validate Server Return
        $Valid = [bool]($Result.Trim() -eq '1.0')
    
        If ($Valid) {$CallDisplay="!"; $CallDisplayDescription="Valid Call Response"} 
        Elseif ($ErrorType -eq "None") {$CallDisplay="*"; $CallDisplayDescription="Bad Data Returned"; $Result = "Page Title: " + (($WebCall.AllElements | ? {$_.tagName -eq 'TITLE'}).innerText)}
        Elseif ($ErrorType -eq "Timeout") {$CallDisplay="."; $CallDisplayDescription="Timeout"}
        Else {$CallDisplay="*"; $CallDisplayDescription="Call Response Error"}

        # Update Counters
        If ($Valid) {$JobGood+=1} Else {$JobBad+=1}
        [decimal]$SuccessRate = $JobGood/$CallCount*100
        $SuccessRate = "{0:N2}" -f $SuccessRate
        If ($CallDuration.TotalMilliseconds -lt $JobMin) {$JobMin = $CallDuration.TotalMilliseconds}
        If ($CallDuration.TotalMilliseconds -gt $JobMax) {$JobMax = $CallDuration.TotalMilliseconds}
        If ($Valid) {$CallArray += $CallDuration.TotalMilliseconds}

        # 5.2 Create Job Details xml
        $JobDetail=""
        $JobDetail = (@($JobDetailFile.JobRecords.JobRecord)[0]).Clone()
        $JobDetail.JobID = [string]$JobID
        $JobDetail.CallID = [string]$CallCount
        $JobDetail.TimeStamp = [string]$CallTime
        $JobDetail.Return = $Result
        $JobDetail.Display = $CallDisplayDescription
        $JobDetail.Valid = [string]$Valid
        $JobDetail.Duration = [string]$CallDuration.TotalMilliseconds

        # 5.3 Log new results xml to local file
        $foo = $JobDetailFile.JobRecords.AppendChild($JobDetail)
        $JobDetailFile.Save("$FilePath\AvailabilityDetail.xml")

        # 5.4 Log summary results to local file
        ForEach($Node in $JobHeaderFile.Jobs.Job) { 
            If ($Node.ID -eq $JobID) {
                $UpdatedNode = $Node
                $UpdatedNode.CallCount = [string]$CallCount
                $UpdatedNode.SuccessRate = [string]$SuccessRate
                $UpdatedNode.JobMin = [string]$JobMin
                $UpdatedNode.JobMax = [string]$JobMax
                $foo = $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node)
                }}
        $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")
    
        # Write output
        Write-Host $CallDisplay -NoNewline
        If ($CallCount%$WrapWidth -eq 0) {Write-Host}
    
        # Decide how long to sleep
        $SleepTime = 10000 - ((Get-Date) - [datetime]$CallTime).TotalMilliseconds
        If ($SleepTime -lt 0) {$SleepTime = 0}
        sleep -Milliseconds $SleepTime
    }
    # 5.5 Repeat
    While (([datetime]$JobStart + $RunDuration) -gt (Get-Date))

    # 6. Calculate end of job stats
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
    Write-Host "   Calls Sent = " -NoNewline
    Write-Host $CallCount -NoNewline
    Write-Host ", Received = " -NoNewline
    Write-Host $JobGood -NoNewline -ForegroundColor Green
    Write-Host " (" -NoNewline
    Write-Host $SuccessRate"%" -NoNewline -ForegroundColor Green
    Write-Host "), Lost = " -NoNewline
    Write-Host $JobBad -ForegroundColor Red
    Write-Host "Call round trip times in milli-seconds:"
    Write-Host "   Minimum = " -NoNewline
    Write-Host $JobMin -NoNewline
    Write-Host "ms, Maximum = " -NoNewline
    Write-Host $JobMax -NoNewline
    Write-Host "ms, Median = " -NoNewline
    Write-Host $JobMedian -NoNewline
    Write-Host "ms"
    Write-Host 

    # 7. Update Job Header xml in local file
    ForEach($node in $JobHeaderFile.Jobs.Job) {
        If ($node.ID -eq $JobID) {
            $UpdatedNode = $Node
            $UpdatedNode.EndTime = [string]$JobEnd
            $UpdatedNode.JobMedian = [string]$JobMedian
            $foo = $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node)}}
    $JobHeaderFile.Save("$FilePath\AvailabilityHeader.xml")

    # 8. Upload Header and Detail xml to server
    $uri = "http://$RemoteHost/Upload.aspx"
    $contentType = "multipart/form-data"
    Try {
        $header = @{FileID = "Header"}
        $HeaderUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobHeaderFile.OuterXml -Headers $header).Content.Trim()

        $header = @{FileID = "Detail"}
        $DetailUploadResponse = (Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobDetailFile.OuterXml -Headers $header).Content.Trim()
    }
    Catch {
        $HeaderUploadResponse = "Bad"
        $DetailUploadResponse = "Bad"
    }

    Write-Host
    If ($HeaderUploadResponse -eq "Good" -and $DetailUploadResponse -eq "Good") {
        Write-Host "Data uploaded to remote server sucessfully"

        # 9. Spawn local web browser showing report details from server
        Write-Host "Launching browser to http://$RemoteHost"
        Start-Process -FilePath "http://$RemoteHost"

        #10. Close and Clean Up
        # Clean up local files 
        Remove-Item "$FilePath\AvailabilityHeader.xml"
        Remove-Item "$FilePath\AvailabilityDetail.xml" 
        } 
    Else {
        Write-Warning "Data upload to remote server failed."
        Write-Warning "Please check to ensure the remote server has all the files required to run this tool."
        Write-Warning "Also ensure the XML files in the 'c:\inetpub\wwwroot' have 'Full Control' file access for the local IIS_IUSRS account"
    }
    Write-Host
    Return
}

function Remove-History {
    # Remove-History
    # This script deletes local xml file
    # if they exist, and calls a web
    # service if an IP address is passed

    Param(
       [Parameter(ValueFromPipeline=$true)]
       [string]$RemoteHost = ''
    )cls
    Write-Host
    Write-Warning "This script will erase all prior Get-AzureNetworkAvailability data on this and the remote server (if a remote address was supplied)"
    $theAnswer = Read-Host -Prompt "Do you wish to continue? [Y], n"
    if ($theAnswer -eq '') {$theAnswer="Y"}
    if ($theAnswer -ne "Y") {
        Write-Host "Clear-History canceled, no data was cleared."
        return
        }

    # Clear remote data if address provided.
    if ($RemoteHost -eq '') {
        Write-Host "No remote address was provided, no remote data was cleared."
        }
    else {
        Write-Host "Clearing data from the remote server." -ForegroundColor Cyan
        $uri = "http://$RemoteHost/ClearHistory.aspx"
        $response = (Invoke-WebRequest -Uri $uri -Method Post -Body "Yes").Content
        if ($response -eq "Good") {
            Write-Host "All Get-AzureNetworkAvailability data was cleared from the remote server." -ForegroundColor Green
            }
         else {
            Write-Warning "An error occured and Get-AzureNetworkAvailability data may not have been cleared from the remote server."
            }
        }

    # Clear local data if files exist.
    Write-Host "Clearing data from local machine..." -ForegroundColor Cyan
    $fileHeader = "$env:TEMP\AvailabilityHeader.xml"
    If (Test-Path $fileHeader) {
        try {
            Remove-Item -Path $fileHeader -Force
            Write-Host "Local Get-AzureNetworkAvailability summary data was cleared from this computer." -ForegroundColor Green
            }
        catch {
            Write-Warning "Local Get-AzureNetworkAvailability summary data was not cleared from this computer."
            }
    }
    else {
        Write-Host "No Get-AzureNetworkAvailability summary data was found on this computer." -ForegroundColor Green
        }

    $fileDetail = "$env:TEMP\AvailabilityDetail.xml"
    If (Test-Path $fileDetail) {
        try {
            Remove-Item -Path $fileDetail -Force
            Write-Host "Local Get-AzureNetworkAvailability detail data was cleared from this computer." -ForegroundColor Green
            }
        catch {
            Write-Warning "Local Get-AzureNetworkAvailability detail data was not cleared from this computer."
            }
    }
    else {
        Write-Host "No Get-AzureNetworkAvailability detail data was found on this computer." -ForegroundColor Green
        }
}

function Get-Results {
    # Get-Results
    # This script opens a web browser and
    # navigates to the passed in IP Address.

    Param(
       [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
       [ipaddress]$RemoteHost
    )
    Write-Host
    Write-Host "Launching browser to http://$RemoteHost"
    Write-Host
    Start-Process -FilePath "http://$RemoteHost"

}

function Get-LocalTrace {}

Export-ModuleMember -Function Get-AzureNetworkAvailabity
Export-ModuleMember -Function Remove-History
Export-ModuleMember -Function Get-Results
Export-ModuleMember -Function Get-LocalTrace
