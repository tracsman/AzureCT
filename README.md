# Azure Connectivity Toolkit (AzureCT)

# <font color="red">This work is pre-release!<br/>It's close, but still a work in progress!</font>

## Overview
This collection of server side web pages and local PowerShell scripts will generate, collect, store, and display availability statistics of the network between you and a newly built Windows VM in Azure. It will do more in the future, but currently only runs availability tests.

It is designed to provide an indication, over time, of the link between a Virtual Machine in Azure and an on-premise network. While the focus is on network availability, the test is done from a PC client to an IIS server in Azure. This provides a view into the availability of an end-to-end scenario, not just a single point or component in the complex chain that makes up a VPN or an ExpressRoute network connection. The hope is that this will provide insight into the end-to-end network availability.

This tool **does not** provide rich insight if a problem is encountered during a test, over time this tool will improve but this initial release only reflects the statistics around availability seen while an active test is running.
![0]

>**Note**: This tool is not certified by Microsoft, nor is it supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, this tool is provided as my best effort to provide insight into a customer's connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

## Tool Usage
### Prerequisites
This tool has three perquisite resources that must be in place before using:

1. An Azure virtual network with a VPN or ExpressRoute site-to-site connection to another (usually "on-premise") network.
2. A newly created Azure Virtual Machine (VM), running Windows Server 2012 or greater, on the Azure VNet that is reachable from the on-premise network. The files and configuration of the Azure VM will be modified, potentially in disruptive ways. To avoid conflicts and/or errors it is important that the Azure VM used is newly built and is a "clean" build, meaning with no other applications or data installed.
3. A client PC running PowerShell 3.0 or greater on the on-premise network that can reach (via RDP or Remote Desktop) the Azure VM.

### Installation Instructions
1. Download the GitHub folders to your local client PC. The easiest way to this is to clone this repository to the local PC. If you're not familiar with Git or GitHub, there is a "[Download Zip](https://github.com/tracsman/AzureCT/archive/master.zip "Download Files Here")" button that will allow you to download all files and expand them on the local Client PC.
2. Remote Desktop to the newly built Azure VM running Windows Server:
	1. Copy the IISBuild.ps1 script from the ServerSide folder to the Azure VM.
	2. Open an elevated (i.e. "run as administrator") PowerShell prompt on the Azure VM.
	3. Run the IISBuild.ps1, this will turn on ICMP (ping), install IIS, .Net 4.5, and copy some IIS application files from GitHub. If any errors occur with the file copies, or your server doesn't have access to the Internet, the files can be manually copied. Copy all files from the ServerSide directory of this GitHub to the C:\Inetpub\wwwroot folder on the server. **Note**: If needed, this script can be run multiple times on the server until all errors are resolved.
3. Note the local IP address of the Azure VM.
	- From PowerShell on the Azure VM run:

		```powershell
			 (Get-NetIPAddress).IPv4Address
		```
	- Copy the first IP address, this should be the VNet IP address for your server. Note: it's not the 127.0.0.1 address.
4. On the local Client PC, open a web browser.
5. Go to `http://<IP Copied from Step 3>`; e.g. http://10.0.0.1
6. You should successfully bring up a web page titled "Azure Connectivity Toolkit - Availability Home Page". This validates that the web server was successfully set-up and reachable by the local PC. Note: Since the Get-AzureNetworkAvailability script hasn't been run, this web page will just be the framework with no real data in it yet. Don't worry, we're about to generate some data!

### Running the tool
1. On the local Client PC, open a PowerShell prompt.
2. Navigate to the directory where the GitHub files where copied in step 1 of the Installation Instructions above.
3. The main command is Get-AzureNetworkAvailability.ps1. This script will make a web call to the remote server once every 10 seconds for the duration of the test. This script has three parameters:
	- **RemoteHost** - This is required and is the Azure VM local IP Address copied in step 3 of the Installation Instructions above.
	- **DurationMinutes** - This optional parameter signifies the duration of the Get-AzureNetworkAvailability command in minutes. It is an integer value (whole number). The default value is 1.
	- **TimeoutSeconds** - This optional parameter signifies how long each call will wait for a response. The default value is 5 seconds.
4. For the first run, I recommend doing a test run of 1 minute (default option). To do this, in the PowerShell prompt run the following command (where 10.0.0.1 is the private IP address of the Azure VM):

	```powershell
	.\Get-AzureNetworkAvailability.ps1 -RemoteHost 10.0.0.1
	```
5. Future execution of this script should be set for a given set of minutes, for example a 10 hour test:

	```powershell
	.\Get-AzureNetworkAvailability.ps1 -RemoteHost 10.0.0.1 -DurationMinutes 600
	```

>Note: Data from each run of the Get-AzureNetworkAvailability script will uploaded and saved to the Azure VM. If there are errors uploading the data or the command is terminated before uploading, the data is stored locally on the PC until the next successful run of the Get-AzureNetworkAvailability script. Uploaded data accumulates on the Azure VM and is selectable and displayed using the default IIS page on the Azure VM.

### Tool Output
The Get-AzureNetworkAvailability script will issue a call to a web page on the remote server (WebTest.aspx), based on the response (either an error, a timeout, or a successful response) the script will then wait ten seconds and try again. Each call will produce command line output to the PowerShell prompt of one of the following.

>**Possible Script Output**
>
>! - Successful Call
>
>. - Unsuccessful Call (timeout)
>
>\* - IP was reached and a web server responded, but with unexpected data or an error (e.g. 404)

Each call to the web server is also recorded locally, in the %temp% directory, in two XML files.
-AvailabilityHeader.xml
-AvailabilityDetail.xml

At the end of the script, a summary of the run will be output to the PowerShell prompt similar to ping results.

The XML files are also uploaded to the server and a web browser should open on the local client machine with the details of all Get-AzureNetworkAvailability jobs run against that server. If the Get-AzureNetworkAvailability run was successful, and the data successfully uploaded to the server, the local XML files will be deleted from the local Client PC. If any errors with the job or the data upload, the XML will remain on the local Client PC until a successful Get-AzureNetworkAvailability run at which point all previous data sets will be uploaded and the XML files deleted locally.

Example screen shots can be seen for these conditions:

 - [A Successful one minute run][One Minute]
 - [A successful ten hour run][Ten Hour]
 - [A successful run with errors][Errors]
 - [An unsuccessful run][Timeout]

### Data Presentation and Review
After running Get-AzureNetworkAvailability.ps1, a web page should open on the local PC, displaying the data for all script runs.
The page can be opened at any time by opening a browser and navigating to `http://<Azure VM IP>` e.g. http://10.0.0.1.

The drop down on that page will show all the data sets (by data and time) contained in the servers XML files.

Selecting a specific data set will display the graph and detailed tabular data for that run, as well as the summary information.

### Other Tool Scripts
There are two other scripts that can be run:
- Clear-History.ps1 
- Show-Results.ps1

Both scripts have a single input parameter:
- **RemoteHost** - This parameter is required for Show-Results and optional for Clear-History, for both scripts this parameter is the IP Address of the Azure VM copied in step 3 of the Installation Instructions above.

#### Clear-History.ps1
This script will delete any Get-AzureNetworkAvailability data on both the local PC and the remote Azure VM (if the remote server IP is provided). This script is never required to be run, but can be helpful if there are many entries in the drop-down box, a new series of tests is about to be run, or if the XML file size becomes slow rendering in the browser.

#### Show-Results.ps1
This script will open a web browser on the local Client PC to display the Get-AzureNetworkAvailability data saved to the remote Azure VM.

### Removing the Azure Connectivity Toolkit
Once testing is complete the Azure VM should be deleted to avoid unnecessary Azure usage (and associated charges) and all local files can be deleted. There is nothing permanently installed, only files copied from GitHub and potentially the two XML files in the Local Client PC %temp% directory. 

To ensure 100% removal of all artifacts from this tool perform the following steps:

1. Run the Clear-History.ps1 command from PowerShell (the Remote-Host parameter is optional and not required) to delete any temporary files created.
2. Delete all files on the local Client PC copied from GitHub
3. Delete the Azure VM

## History
2016-02-03 - Initial beta release, version 0.5.

## To Do (Backlog) In Priority Order

1. (Get-LocalTrace.ps1) Net new script, if Get-AzureNetworkAvailability fails, a simple information collector to provide troubleshooting information.
2. (Get-ServerTrace.ps1) Net new server side script that works with Get-LocalTrace.ps1 to inspect the network from the Azure side back towards the on-premise network. These two data sets will hopefully provide information to detect in which component the fault lies.
3. (Get-AzureNetworkAvailability.ps1) Check XML schema version, if not current, overwrite local XML.
4. (Get-AzureNetworkAvailability.ps1) Add more help information, add Verbose output (Write-Verbose), and Debug Output (Write-Debug)
5. (Get-AzureNetworkAvailability.ps1) Add ending stats if CRTL-C pressed in middle of job
6. (DisplayAvailability.html) Make it prettier
7. (AzureCT.psm1) Wrap the client side scripts into a module for ease of installation

## Incorporated Licenses
This tool incorporates [JQuery](https://jquery.org/license/ "JQuery License") for XML manipulation and is included in the ServerSide files. JQuery.js is included and used under the requirements of the MIT License, and in compliance with the main JQuery license proviso "*You are free to use any jQuery Foundation project in any other project (even commercial projects) as long as the copyright header is left intact.*"

## Support and Legal Disclaimers
Microsoft provides no support for this software. All support, assistance, and information is on this site alone.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; INCREMENTAL AZURE COSTS INCURRED THROUGH USE OF THIS SOFTWARE; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!--Image References-->
[0]: ./media/AzureCTAvailability.png "AzureCT Availability Test Diagram"

<!--Link References-->
[One Minute]: ./media/RunOneMinute.md
[Ten Hour]: ./media/RunOneMinute.md
[Errors]: ./media/RunOneMinute.md
[Timeout]: ./media/RunOneMinute.md