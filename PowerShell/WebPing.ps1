# WebPing
# This script makes repeated calls to a web site on
# a private vnet and logs the success/failure and
# response times.
#
# Script Output
# ! - Successfull WebPing
# . - Unsuccsefull WebPing (timeout)
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
# 8. Upload Header and deatails xml to web server
# 9. Spawn local web browser showing report details from server
#10. Close and Clean Up
#

# 1. Evaluate and Set input parameters
Param(
   
   # [ipaddress]$RemoteHost = '192.168.0.215', # Remove default IP address for production
   # [ipaddress]$RemoteHost = '10.249.172.53', # Remove default IP address for production

   [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
   [ipaddress]$RemoteHost,
   [int]$Duration=0,
   [ValidateSet("Seconds","Minutes")] 
   [string]$DurationInterval="Minutes",
   [int]$TimeoutSeconds=2
)

# 2. Initialize
$FilePath = $env:TEMP
$JobSchemaVersion = "1.5"
If ($Duration -eq 0) {$RunDuration = New-TimeSpan -Days 365} 
    Else {
    switch ($DurationInterval)
    {   "Seconds" {$RunDuration = New-TimeSpan -Seconds ([int]$Duration)}
        "Minutes" {$RunDuration = New-TimeSpan -Minutes ([int]$Duration)} } }

# Check for Header File
If ((Test-Path "$FilePath\DiagJobHeader.xml") -eq $false) {
    [string]$JobHeaderFile = "<?xml version=`"1.0`"?><Jobs version=`"$JobSchemaVersion`"><Job><ID></ID><StartTime></StartTime><EndTime></EndTime><Target></Target><TimeoutSeconds></TimeoutSeconds><PingCount>0</PingCount><SuccessRate>0</SuccessRate><PingMin></PingMin><PingMax></PingMax><PingAvg></PingAvg></Job></Jobs>"
    $JobHeaderFile | Out-File -FilePath "$FilePath\DiagJobHeader.xml" -Encoding ascii}

# Check for Detail File
If ((Test-Path "$FilePath\DiagJobDetail.xml") -eq $false) {
    [string]$JobDetailFile = "<?xml version=`"1.0`"?><JobRecords version=`"$JobSchemaVersion`"><JobRecord><JobID></JobID><PingID></PingID><TimeStamp></TimeStamp><Return></Return><Display></Display><Valid></Valid><Duration></Duration></JobRecord></JobRecords>"
    $JobDetailFile | Out-File -FilePath "$FilePath\DiagJobDetail.xml" -Encoding ascii}

[int]$PingCount=0
[int]$PingGood=0
[int]$PingBad=0
[int]$PingMin=2000000000
[int]$PingMax=0
[int]$PingAvg=0
[int64]$PingDurationTotal=0
[int]$WrapWidth = $Host.UI.RawUI.BufferSize.Width - 5

# 3. Load Files and Get Ready for new run
# 3.1 Pull current Header and Detail xml files
[xml]$JobHeaderFile = Get-Content "$FilePath\DiagJobHeader.xml"
[xml]$JobDetailFile = Get-Content "$FilePath\DiagJobDetail.xml"

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
$JobHeaderFile.Save("$FilePath\DiagJobHeader.xml")

# 5. Job Loop, duration as defined by user input
Write-Host
Write-Host "Starting WebPing to $RemoteHost..." -ForegroundColor Cyan
Write-Host

Do {
    $PingCount+=1
    # Get local time to save later in results
    $PingTime = Get-Date -Format 's'
    $ErrorType = "None"
    $PingDisplay = "n" # Null, this should never show
    $PingDisplayDescription = "Null" # This should never show
    # 5.1 Call WebTest.aspx
     ###########################################
    #  The following line is the magic, it is   #
    #  the actual connectivity test being run.  #
    #  $WebPing holds the results of the test.  #
    #  $PingDuration is the ping duration in ms.#
     ###########################################

    Try {
        $PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://$RemoteHost/WebTest.aspx -TimeoutSec $TimeoutSeconds)}
        
        #$PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://192.168.0.215/WebTest.aspx -TimeoutSec $TimeoutSeconds)}           # No Error, Good Data
        #$PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://192.168.0.215 -TimeoutSec $TimeoutSeconds)}                        # No Error, Bad Data (No Data)
        #$PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://tracsman.azurewebsites.net/home.html -TimeoutSec $TimeoutSeconds)} # No Error, Bad Data (With Data)
        #$PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://192.168.0.216/WebTest.aspx -TimeoutSec $TimeoutSeconds)}           # Error, Timeout
        #$PingDuration = Measure-Command {$WebPing = (Invoke-WebRequest -Uri http://192.168.0.215/WebTest2.aspx -TimeoutSec $TimeoutSeconds)}          # Error, 404 (Else)
        
        # Pull server data from the test
        $ServerTime = ($WebPing.AllElements | ? {$_.tagName -eq 'HEAD'}).innerText
        $Result = ($WebPing.AllElements | ? {$_.tagName -eq 'BODY'}).innerText
        }
    Catch {
        if ($error[0].Exception.Status -eq "Timeout") {$ErrorType = "Timeout"} 
        Else {$ErrorType = "Other"} # Other Error, probably 404
        $WebPing = ""
        $PingDuration = ""
        $ServerTime = ""
        $Result = $error[0].Exception.Message
        }
    # Validate Server Return
    $Valid = [bool]($Result.Trim() -eq '1.0')
    
    if ($Valid) {$PingDisplay="!"; $PingDisplayDescription="Valid Ping Response"} 
    elseif ($ErrorType -eq "None") {$PingDisplay="*"; $PingDisplayDescription="Bad Data Returned"; $Result = "Page Title: " + (($WebPing.AllElements | ? {$_.tagName -eq 'TITLE'}).innerText)}
    elseif ($ErrorType -eq "Timeout") {$PingDisplay="."; $PingDisplayDescription="Timeout"}
    else {$PingDisplay="*"; $PingDisplayDescription="Ping Response Error"}

    # Update Counters
    if ($Valid) {$PingGood+=1} Else {$PingBad+=1}
    [decimal]$SuccessRate = $PingGood/$PingCount*100
    $SuccessRate = "{0:N2}" -f $SuccessRate
    $PingDurationTotal+=$PingDuration.TotalMilliseconds
    if ($PingDuration.TotalMilliseconds -lt $PingMin) {$PingMin = $PingDuration.TotalMilliseconds}
    if ($PingDuration.TotalMilliseconds -gt $PingMax) {$PingMax = $PingDuration.TotalMilliseconds}

    # 5.2 Create Job Details xml
    $JobDetail=""
    $JobDetail = (@($JobDetailFile.JobRecords.JobRecord)[0]).Clone()
    $JobDetail.JobID = [string]$JobID
    $JobDetail.PingID = [string]$PingCount
    $JobDetail.TimeStamp = [string]$PingTime
    $JobDetail.Return = $Result
    $JobDetail.Display = $PingDisplayDescription
    $JobDetail.Valid = [string]$Valid
    $JobDetail.Duration = [string]$PingDuration.TotalMilliseconds

    # 5.3 Log new results xml to local file
    $foo = $JobDetailFile.JobRecords.AppendChild($JobDetail)
    $JobDetailFile.Save("$FilePath\DiagJobDetail.xml")

    # 5.4 Log summary results to local file
    foreach($Node in $JobHeaderFile.Jobs.Job) { 
        If ($Node.ID -eq $JobID) {
            $UpdatedNode = $Node
            $UpdatedNode.PingCount = [string]$PingCount
            $UpdatedNode.SuccessRate = [string]$SuccessRate
            $UpdatedNode.PingMin = [string]$PingMin
            $UpdatedNode.PingMax = [string]$PingMax
            $foo = $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node)
            }}
    $JobHeaderFile.Save("$FilePath\DiagJobHeader.xml")
    
    Write-Host $PingDisplay -NoNewline
    if ($PingCount%$WrapWidth -eq 0) {Write-Host}
    sleep -Seconds 1

}
# 5.5 Repeat
While (([datetime]$JobStart + $RunDuration) -gt (Get-Date))

# 6. Calculate end of job stats
$PingAvg = $PingDurationTotal / $PingCount
$JobEnd = Get-Date -Format 's'
Write-Host
Write-Host
Write-Host "WebPing statistics for $RemoteHost"
Write-Host "   WebPings: Sent = " -NoNewline
Write-Host $PingCount -NoNewline
Write-Host ", Received = " -NoNewline
Write-Host $PingGood -NoNewline -ForegroundColor Green
Write-Host " (" -NoNewline
Write-Host $SuccessRate"%" -NoNewline -ForegroundColor Green
Write-Host "), Lost = " -NoNewline
Write-Host $PingBad -ForegroundColor Red
Write-Host "WebPing round trip times in milli-seconds:"
Write-Host "   Minimum = " -NoNewline
Write-Host $PingMin -NoNewline
Write-Host "ms, Maximum = " -NoNewline
Write-Host $PingMax -NoNewline
Write-Host "ms, Average = " -NoNewline
Write-Host $PingAvg -NoNewline
Write-Host "ms"
Write-Host 

# 7. Update Job Header xml in local file
foreach($node in $JobHeaderFile.Jobs.Job) {
    If ($node.ID -eq $JobID) {
        $UpdatedNode = $Node
        $UpdatedNode.EndTime = [string]$JobEnd
        $UpdatedNode.PingAvg = [string]$PingAvg
        $foo = $JobHeaderFile.Jobs.ReplaceChild($UpdatedNode, $Node)}}
$JobHeaderFile.Save("$FilePath\DiagJobHeader.xml")

# 8. Upload Header and deatails xml to web server
$uri = "http://$RemoteHost/Upload.aspx"
$contentType = "multipart/form-data"
Try {
    $header = @{FileID = "Header"}
    $HeaderUploadResponse = Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobHeaderFile.OuterXml -Headers $header
    $header = @{FileID = "Detail"}
    $DetailUploadResponse = Invoke-WebRequest -Uri $uri -ContentType $contentType -Method Post -Body $JobDetailFile.OuterXml -Headers $header
}
Catch {
    $HeaderUploadResponse = "Bad"
}

Write-Host
If ($HeaderUploadResponse -eq "Good" -and $DetailUploadResponse -eq "Good") {
    Write-Host "Data uploaded to remote server sucessfully"} 
Else {
    Write-Host "Data upload to remote server failed. Please check to ensure the remote server has all the files required to run this tool." -ForegroundColor Red
    Return
}

# 9. Spawn local web browser showing report details from server
Write-Host "Launching browser to http://$RemoteHost"
Start-Process -FilePath "http://$RemoteHost"

#10. Close and Clean Up
# Clean up local files 
Remove-Item "$FilePath\DiagJobHeader.xml"
Remove-Item "$FilePath\DiagJobDetail.xml" 

Return

# TO DO
# 1. Check xml schema version, if not current, overwrite
# 2. Add Help switch and help information
# 3. Add ending stats if CRTL-C pressed in middle of job
