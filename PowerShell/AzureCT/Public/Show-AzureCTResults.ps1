function Show-AzureCTResults {
    # Show-Results
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
} # End Function