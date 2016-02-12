﻿function Clear-AzureCTHistory {
    # Clear-History
    # This script deletes local xml file
    # if they exist, and calls a web
    # service if an IP address is passed

    Param(
       [Parameter(ValueFromPipeline=$true)]
       [string]$RemoteHost = ''
    )

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
    $FileList = @()
    $FileList += "$env:TEMP\AvailabilityHeader.xml"
    $FileList += "$env:TEMP\AvailabilityDetail.xml"
    $FileList += "$env:TEMP\AvailabilityTrace.xml"

    ForEach ($File in $FileList) {
        If (Test-Path "$env:TEMP\$File") {
            try {
                Remove-Item -Path "$env:TEMP\$File" -Force
                Write-Host "$File was cleared from this computer." -ForegroundColor Green
            }
            catch {
                Write-Warning "$env:TEMP\$File was not cleared from this computer."
            }
        }
        else {
            Write-Host "$File was not found on this computer." -ForegroundColor Green
        } # End If
    } # End ForEach
} # End Function