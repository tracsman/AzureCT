# IIS Server Post Build Config Script
# Must be run from an elevated PS prompt!

# Turn On ICMPv4
    Write-Host
    Write-Host "Creating ICMP Rule in Windows Firewall" -ForegroundColor Cyan
    New-NetFirewallRule -Name Allow_ICMPv4 -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -Enabled True -Profile Any -Action Allow -ErrorAction SilentlyContinue

# Install IIS
    Write-Host
    Write-Host "Installing IIS and .Net 4.5, this can take some time, like 15+ minutes..." -ForegroundColor Cyan
    add-windowsfeature Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Health, Web-Http-Logging, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering, Web-App-Dev, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net45, Web-Mgmt-Tools, Web-Mgmt-Console

# Create Web App Pages
    # Create Arrays
    $FileName = @()
    
    # Stuff Arrays with Github URL and local file path
    $FileName += "DisplayPing.html"
    $FileName += "DisplayPing.css"
    $FileName += "DisplayPing.js"
    $FileName += "jquery.js"
    $FileName += "Web.config"
    $FileName += "DiagJobDetail.xml"
    $FileName += "DiagJobHeader.xml"
    $FileName += "UploadHeader.aspx"
    $FileName += "UploadDetail.aspx"
    $FileName += "ClearHistory.aspx"

    # Loop through the arrays and pull files from GitHub to the Server
    Write-Host
    Write-Host "Pulling Web pages from GitHub" -ForegroundColor Cyan
    Write-Host "Coping files from the 'ServerSide' directory on GitHub to the local 'c:\inetpub\wwwroot\' directory."
    $Issues = $false
    $i=0
    $URL | ForEach{
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile( "https://raw.githubusercontent.com/tracsman/HybridTool/master/ServerSide/" + $FileName[$i], "c:\inetpub\wwwroot\" + $FileName[$i] )
            Write-Host "Copied successfully:" $FileName[$i] 
        }
        Catch {
            $Issues = $true
            Write-Host "Download Error:" $FileName[$i] "was not downloaded. Copy this file manually, or rerun this script." -ForegroundColor Red}
        $i++
    }

    Write-Host
    If ($Issues) {Write-Host "Issues encountered, please see statement above in red for details!" -ForegroundColor Red}
    Else {Write-Host "Web App Creation Successfull!" -ForegroundColor Green}
    Write-Host