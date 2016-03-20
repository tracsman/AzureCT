function Get-ServerSideTrace {
 
    # Evaluate and Set input parameters
    [cmdletBinding()]
    Param(
       [Parameter(ValueFromPipeline=$true,
                  Mandatory=$true,
                  HelpMessage='Enter IP Address of Target Machine')]
       [ipaddress]$RemoteHost,
       [int]$DurationMinutes=1,
       [int]$SecondsBetweenTracePulls=60
    )

    # Initialize
    $ErrorFlag = $true
    $FilePath = "C:\inetpub\wwwroot"
    $HeaderFileName = "$FilePath\ServerSideTraceHeader.xml"
    $DetailFileName = "$FilePath\ServerSideTraceDetail.xml"
    $RunDuration = New-TimeSpan -Minutes $DurationMinutes
    $LastTraceTime = (Get-Date) - (New-TimeSpan -Minutes $SecondsBetweenTracePulls)
    [int]$TraceCount=0
    [int]$WrapWidth = $Host.UI.RawUI.BufferSize.Width - 5
    $JobID = [System.Guid]::NewGuid().toString()

    # Check for Header File
    If ((Test-Path $HeaderFileName) -eq $false) {
        [string]$HeaderFile = "<?xml version=`"1.0`"?><ServerTraces version=`"$script:XMLSchemaVersion`"><ServerTrace><JobID/><StartTime/><EndTime/><Target/><TraceCount/></ServerTrace></ServerTraces>"
        $HeaderFile | Out-File -FilePath $HeaderFileName -Encoding ascii}

    # Check for Detail File
    If ((Test-Path $DetailFileName) -eq $false) {
        [string]$DetailFile = "<?xml version=`"1.0`"?><TraceRecords version=`"$script:XMLSchemaVersion`"><TraceRecord><JobID/><TraceID/><HopID/><TimeStamp/><Address/><TripTime/></TraceRecord></TraceRecords>"
        $DetailFile | Out-File -FilePath $DetailFileName -Encoding ascii}
    
    # Load Files and Get Ready for new run
    # Pull current Header and Detail xml files
    [xml]$HeaderFile = Get-Content $HeaderFileName
    [xml]$DetailFile = Get-Content $DetailFileName

    # Create new Job Header xml node (in local file)
    $JobStart = Get-Date -Format 's'
    $JobHeader = ""
    $JobHeader = (@($HeaderFile.ServerTraces.ServerTrace)[0]).Clone()
    $JobHeader.JobID =[string]$JobID
    $JobHeader.StartTime = [string]$JobStart
    $JobHeader.Target = [string]$RemoteHost.IPAddressToString
    $HeaderFile.ServerTraces.AppendChild($JobHeader) | Out-Null
    $HeaderFile.Save($HeaderFileName)

    # Job Loop, duration as defined by user input
    Try {
        Write-Host
        Write-Host "Starting ServerSideTrace test to $RemoteHost..." -ForegroundColor Cyan
        Write-Host

        # Run an initial call to load ARP tables and IIS caches along the call path
        Try {
            $TraceReturn = Get-IPTrace -RemoteHost $RemoteHost }
        Catch {}

        $TraceArray = @()
        Do {
            $TraceCount+=1
            $TraceTime = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
            $ErrorType = "None"
            $TraceDisplay = "n" # Null, this should never show

            Try {
                $TraceArray += Start-Job -ScriptBlock {Get-IPTrace -RemoteHost $args[0] -JobID $args[1] -CallID $args[2]} -Name 'AzureCT.Tracing' -ArgumentList $RemoteHost, $JobID, $TraceCount
                $TraceDisplay = "!"
            }
            Catch {
                $TraceDisplay ="*"
            }

            # Log summary results to local file
            ForEach($Node in $HeaderFile.ServerTraces.ServerTrace) { 
                If ($Node.ID -eq $JobID) {
                    $UpdatedNode = $Node
                    $UpdatedNode.TraceCount = [string]$TraceCount
                    $HeaderFile.ServerTraces.ReplaceChild($UpdatedNode, $Node) | Out-Null
                    }}
            $HeaderFile.Save($HeaderFileName)
    
            # Write output
            Write-Host $TraceDisplay -NoNewline
            If ($TraceCount%$WrapWidth -eq 0) {Write-Host}
    
            # Decide how long to sleep
            $SleepTime = 10000 - ((Get-Date) - [datetime]$TraceTime).TotalMilliseconds
            If ($SleepTime -lt 0) {$SleepTime = 0}
            sleep -Milliseconds $SleepTime
            
        } # Do End
        While (([datetime]$JobStart + $RunDuration) -gt (Get-Date))
        $ErrorFlag = $false
    } # Try End

    Finally {

        # Calculate end of job stats
        $JobEnd = Get-Date -Format 's'

        # Write summary host output
        Write-Host
        Write-Host
        If ($ErrorFlag) {Write-Warning "ServerSideTrace to $RemoteHost ended due to error or user abort."}
        Else {Write-Host "ServerSideTrace to $RemoteHost completed normally." -ForegroundColor Green} 
        Write-Host 

        # Update Job Header xml in local file
        ForEach($node in $JobHeaderFile.ServerTraces.ServerTrace) {
            If ($node.ID -eq $JobID) {
                $UpdatedNode = $Node
                $UpdatedNode.EndTime = [string]$JobEnd
                $HeaderFile.ServerTraces.ReplaceChild($UpdatedNode, $Node) | Out-Null
                }
        }
        $HeaderFile.Save($HeaderFileName)

        # Wait for traces to finish
        While ((Get-Job -Name "AzureCT.Tracing" | Where State -eq 'Running').Count -gt 0) {
            Sleep -Seconds 2
            Write-Host "Waiting for Trace Route jobs to finish..."
        }
        
        # Build the Trace File
        $PSJobData = Receive-Job -Job $TraceArray[$Node.CallID - 1]
        ForEach ($TraceRow in $PSJobData) {
            $TraceNode =""
            $TraceNode = (@($DetailFile.TraceRecords.TraceRecord)[0]).Clone()
            $TraceNode.JobID = [string]$TraceRow.JobID
            $TraceNode.TraceID = [string]$TraceRow.TraceID
            $TraceNode.HopID = [string]$TraceRow.HopCount
            $TraceNode.TimeStamp = [string]$TraceRow.TimeStamp
            $TraceNode.Address = [string]$TraceRow.Address
            $TraceNode.TripTime = [string]$TraceRow.RoundTripTime
            $DetailFile.TraceRecords.AppendChild($TraceNode) | Out-Null
            $DetailFile.Save($DetailFileName)
        } # End ForEach $TraceRow


        # Be good and clean up after yourself!
        ForEach ($Job in (Get-Job)) {
           Remove-Job $Job
        }

        Write-Host
        If ($HeaderUploadResponse -eq "Good" -and $DetailUploadResponse -eq "Good") {
            Write-Host "Data uploaded to remote server sucessfully"

            # Spawn local web browser showing report details from server
            Write-Host "Launching browser to http://$RemoteHost/DisplayServerSideTrace.html"
            Start-Process -FilePath "http://$RemoteHost/DisplayServerSideTrace.html"

            # Close and Clean Up
            # Clean up local files 
            Remove-Item $HeaderFileName
            Remove-Item $DetailFileName
        } 
        Else {
            Write-Warning "Data upload to remote server failed."
            Write-Warning "Please check to ensure the remote server has all the files required to run this tool."
            Write-Warning "Also ensure the XML files in the 'c:\inetpub\wwwroot' have 'Full Control' file access for the local IIS_IUSRS account"
        }
        Write-Host
    } # Finally End
} # Function End

