<#  

WebPing
 Call ShowResults on End

ShowResults
 Get

ClearHistory
 Post = Yes


 WebTest.aspx
 index.html
 UploadHeader.aspx
 UploadDetail.aspx
 ClearHistory.aspx

 #>
Param(
   # [ipaddress]$RemoteHost = 'localhost:1669'
   [string]$RemoteHost = ''
)
write-host
Write-Host "!! Caution !!" -ForegroundColor Yellow
Write-Host
Write-Host "This script will erase all prior WebPing data on this and the remote server (if a remote address was supplied)"
$theAnswer = Read-Host -Prompt "Do you wish to continue? [Y], n"
if ($theAnswer -eq '') {$theAnswer="Y"}
if ($theAnswer -ne "Y") {
    Write-Host "Clear-History canceled, no data was cleared."
    return
    }

# Clear remote data if address provided.
if ($RemoteHost -eq '') {
    Write-Host "No host address was provided, no remote data was cleared."
    }
else {
    Write-Host "Clearing WebPing history from the remote server." -ForegroundColor Cyan
    $uri = "http://$RemoteHost/ClearHistory.aspx"
    $response = (Invoke-WebRequest -Uri $uri -Method Post -Body "Yes").Content
    if ($response -eq "Good") {
        Write-Host "All WebPing history was cleared from the remote server." -ForegroundColor Green
        }
     else {
        Write-Host "Warning: WebPing history was not cleared from the web server." -ForegroundColor Red
        }
    }

# Clear local data if files exist.
Write-Host "Clearing local WebPing history..." -ForegroundColor Cyan
$fileHeader = "$env:TEMP\DiagJobHeader.xml"
If (Test-Path $fileHeader) {
    try {
        Remove-Item -Path $fileHeader -Force
        Write-Host "Local WebPing summary history was cleared from this computer." -ForegroundColor Green
        }
    catch {
        Write-Host "Warning: Local WebPing summary history was not cleared from this computer." -ForegroundColor Red
        }
}
else {
    Write-Host "No local WebPing summary history was found on this computer." -ForegroundColor Green
    }

$fileDetail = "$env:TEMP\DiagJobDetail.xml"
If (Test-Path $fileDetail) {
    try {
        Remove-Item -Path $fileDetail -Force
        Write-Host "Local WebPing detail history was cleared from this computer." -ForegroundColor Green
        }
    catch {
        Write-Host "Warning: Local WebPing detail history was not cleared from this computer." -ForegroundColor Red
        }
}
else {
    Write-Host "No local WebPing detail history was found on this computer." -ForegroundColor Green
    }