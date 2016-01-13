# Check Header File
If (Test-Path "$FilePath\DiagJobHeader.xml") {
    [xml]$xmlHeader = Get-Content "$FilePath\DiagJobHeader.xml"
    $RemoteHost = [int]($xmlHeader.SelectNodes('//Jobs/Job') | Sort ID -Descending | Select Target -First 1).Target
    Start-Process -FilePath "http://$RemoteHost/index.html"
    }
else {
    Write-Host "No WebPing data found, run WebPing to generate data before running this command" -ForegroundColor Yellow
    }





