# IIS Server Post Build Config Script
# To kick me off from a URL run the following:
# (new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/master/ServerSide/IISBuild.ps1") | Invoke-Expression

# Must be run from an elevated PS prompt!
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "This script must be run As Administrator, please open a new PowerShell prompt using the Run As Administrator option and re-run this script."
        Break}

# Turn On ICMPv4
    Write-Host
    Write-Host "Creating ICMP Rule in Windows Firewall" -ForegroundColor Cyan
    New-NetFirewallRule -Name Allow_ICMPv4 -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -Enabled True -Profile Any -Action Allow -ErrorAction SilentlyContinue

# Install IIS
    Write-Host
    Write-Host "Installing IIS and .Net 4.5, this can take some time (up to 15+ minutes)..." -ForegroundColor Cyan
    add-windowsfeature Web-Server, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Health, Web-Http-Logging, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering, Web-App-Dev, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net45, Web-Mgmt-Tools, Web-Mgmt-Console

# Create Web App Pages
    # Create FileName Array
    $FileName = @()
    
    # Stuff Array with FileNames
    $FileName += "AvailabilityDetail.xml"
    $FileName += "AvailabilityHeader.xml"
	$FileName += "AvailabilityTrace.xml"
    $FileName += "ClearHistory.aspx"
    $FileName += "DisplayAvailability.css"
    $FileName += "DisplayAvailability.html"
    $FileName += "DisplayAvailability.js"
    $FileName += "jquery.js"
    $FileName += "TemplateAvailabilityDetail.xml"
    $FileName += "TemplateAvailabilityHeader.xml"
	$FileName += "TemplateAvailabilityTrace.xml"
    $FileName += "Upload.aspx"
    $FileName += "Web.config"
    $FileName += "WebTest.aspx"

    # Loop through the array and pull files from GitHub to the Server
    Write-Host
    Write-Host "Pulling Web pages from GitHub" -ForegroundColor Cyan
    Write-Host "Coping files from the 'ServerSide' directory on GitHub to the local 'c:\inetpub\wwwroot\' directory."
    $Issues = $false
    $i=0
    $FileName | ForEach{
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile( "https://raw.githubusercontent.com/tracsman/AzureCT/master/ServerSide/" + $FileName[$i], "c:\inetpub\wwwroot\" + $FileName[$i] )
            Write-Host "Copied successfully:" $FileName[$i] 
        }
        Catch {
            $Issues = $true
            Write-Warning "Download Error:" $FileName[$i] "was not downloaded. Copy this file manually, or rerun this script."}
        $i++
    }
# Update File Permmisions to Allow writing access on XML files
    # Create Array
    $FileName = @()

    # Stuff Array with XML files
    $FileName += "C:\inetpub\wwwroot\AvailabilityDetail.xml"
    $FileName += "C:\inetpub\wwwroot\AvailabilityHeader.xml"
	$FileName += "C:\inetpub\wwwroot\AvailabilityTrace.xml"
    $FileName += "C:\inetpub\wwwroot\TemplateAvailabilityDetail.xml"
    $FileName += "C:\inetpub\wwwroot\TemplateAvailabilityHeader.xml"
	$FileName += "C:\inetpub\wwwroot\TemplateAvailabilityTrace.xml"

    # Loop through array and set file permissions
    $i=0
    $ar = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "Allow")
    $FileName | ForEach {
        Try {
            $acl = Get-Acl $FileName[$i]
            $acl.SetAccessRule($ar)
            Set-Acl $FileName[$i] $Acl}
        Catch {
            $Issues = $true
            Write-Warning "An error occured applying write ACLs to the $FileName[$i] file."
            Write-Warning "Rerun this command or you can manualy apply 'Full Control' permissions to the IIS_IUSRS account on the xml file in the 'c:\inetpub\www\' directory."}
        $i++
        }
# Say our good-byes and close up shop
    Write-Host
    If ($Issues) {
        Write-Warning "Issues encountered, please see statement(s) above in red for details!"
        }
    Else {Write-Host "Web App Creation Successfull!" -ForegroundColor Green}
    Write-Host
