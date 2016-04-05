# Azure Connectivity Toolkit (AzureCT)

## Overview
This collection of server side web pages and local PowerShell that will generate, collect, store, and display availability statistics of the network between you and a newly built Windows VM in Azure. It will do more in the future, but currently only provides availability information.

It is designed to provide an indication, over time, of the link between a Virtual Machine in Azure and an on-premise network. While the focus is on network availability, the test is done from a PC client to an IIS server in Azure. This provides a view into the availability of an end-to-end scenario, not just a single point or component in the complex chain that makes up a VPN or an ExpressRoute network connection. The hope is that this will provide insight into the end-to-end network availability.

![0]

>**Note**: This tool is not certified by Microsoft, nor is it supported by Microsoft support. Download and use at your own risk. While the author is an employee of Microsoft, this tool is provided as my best effort to provide insight into a customer's connectivity between an on-premise network and an Azure endpoint. See the [Support and Legal Disclaimers](#support-and-legal-disclaimers) below for more info.

## Fast Start
If you just want to install the toolkit, this is a the place to start:

1. Create a new Windows Server Azure VM on an ExpressRoute connected VNet
2. On the new Azure VM, in an elevated PowerShell Prompt, run the following command:  **(new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/master/ServerSide/IISBuild.ps1") | Invoke-Expression**
3. On your local PC run the following command from PowerShell: **(new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/master/PowerShell/Install-AzureCT.ps1") | Invoke-Expression**
4. On your local PC you now have the Get-AzureNetworkAvailability command to run availability tests!


## Tool Usage
### Prerequisites
This tool has three perquisite resources that must be in place before using:

1. An Azure virtual network with a VPN or ExpressRoute site-to-site connection to another (usually "on-premise") network.
2. A newly created Azure Virtual Machine (VM), running Windows Server 2012 or greater, on the Azure VNet that is reachable from the on-premise network. The files and configuration of the Azure VM will be modified, potentially in disruptive ways. To avoid conflicts and/or errors it is important that the Azure VM used is newly built and is a "clean" build, meaning with no other applications or data installed.
3. A client PC (or server) running PowerShell 3.0 or greater on the on-premise network that can reach (via RDP or Remote Desktop) the Azure VM.

### Installation Instructions
1. Local PC Instructions:
	- Install the AzureCT PowerShell module by running the following command in a PowerShell prompt:

		```powershell
		(new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/master/PowerShell/Install-AzureCT.ps1") | Invoke-Expression
		```
	- This will install a new PowerShell module with six PowerShell cmdlets; Get-AzureNetworkAvailability, Clear-AzureCTHistory, Show-AzureCTResults, Get-HostName, Get-IPTrace, and Remove-AzureCT.
2. Azure VM Instructions:
	- Note the IP Address for this Azure VM that was assigned by the VNet, this will be used many times.
	- Install the web application by running the following command in an elevated PowerShell prompt (ie "Run as Administrator") on the Azure VM.

		```powershell
		(new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/master/ServerSide/IISBuild.ps1") | Invoke-Expression
		```

	- This script will turn on ICMP (ping), install IIS, .Net 4.5, and copy some IIS application files from GitHub. If any errors occur with the file copies, or your server doesn't have access to the Internet, the files can be manually copied. Copy all files from the ServerSide directory of this GitHub to the C:\Inetpub\wwwroot folder on the server. **Note**: If needed, this script can be run multiple times on the server until all errors are resolved. If you manually copy the files, please run the script again to ensure proper file permissions are set on the files.
4. Validate Installation:
	- Go to `http://<IP Copied from Step 2>`; e.g. http://10.0.0.1
	- You should successfully bring up a web page titled "Azure Connectivity Toolkit - Availability Home Page". This validates that the web server was successfully set-up and reachable by the local PC. **Note:** Since the Get-AzureNetworkAvailability script hasn't been run, this web page will just be the framework with no real data in it yet. Don't worry, we're about to generate some data!

> **IMPORTANT**: If warnings are received on either the server or the client regarding ExecutionPolicy in PowerShell, you may need to update your PowerShell settings to allow remote scripts to be run. In PowerShell more information can be found by running "Get-Help about_Execution_Policies" or at this web site: [MSDN][MSDN]
>
> I usually opt for the RemoteSigned setting, but security for your organization should be considered when selecting a new ExecutionPolicy. This can be done by running "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" from an admin PowerShell prompt. You will only need to change this setting once as it is a persistent global PowerShell setting on each machine.


### Running the tool
1. On the local Client PC, open a PowerShell prompt.
2. The main cmdlet is Get-AzureNetworkAvailability. This function will make a web call to the remote server once every 10 seconds for the duration of the test. This function has three input parameters:
	- **RemoteHost** - This is required and is the Azure VM IP Address copied in step 2 of the Installation Instructions above.
	- **DurationMinutes** - This optional parameter signifies the duration of the Get-AzureNetworkAvailability command in minutes. It is an integer value (whole number). The default value is 1.
	- **TimeoutSeconds** - This optional parameter signifies how long each call will wait for a response. The default value is 5 seconds.
4. For the first run, I recommend doing a test run of 1 minute (default option). To do this, in the PowerShell prompt run the following command (where 10.0.0.1 is the private IP address of the Azure VM):

	```powershell
	Get-AzureNetworkAvailability -RemoteHost 10.0.0.1
	```
5. Future execution of this script should be set for a given set of minutes, for example a 10 hour test:

	```powershell
	Get-AzureNetworkAvailability -RemoteHost 10.0.0.1 -DurationMinutes 600
	```

>Note: Data from each run of the Get-AzureNetworkAvailability command will uploaded and saved to the Azure VM. If there are errors uploading the data or the command is terminated before uploading, the data is stored locally on the PC until the next successful run of Get-AzureNetworkAvailability. Uploaded data accumulates on the Azure VM and is selectable and displayed using the default IIS page on the Azure VM.

### Tool Output
Get-AzureNetworkAvailability will issue a call to a web page on the remote server (WebTest.aspx), based on the response (either an error, a timeout, or a successful response) the script will then wait ten seconds and try again. Each call will produce command line output to the PowerShell prompt of one of the following.

>**Possible Script Output**
>
>! (exclamation point) - Successful Call
>
>. (period) - Unsuccessful Call (timeout)
>
>\* (asterisk) - IP was reached and a web server responded, but with unexpected data or an error (e.g. 404)

Each call to the web server is also recorded locally, in the %temp% directory, in two XML files.
-AvailabilityHeader.xml
-AvailabilityDetail.xml

When this command finishes, a summary of the run will be output to the PowerShell prompt similar to ping results.

The XML files are also uploaded to the server and a web browser should open on the local client machine with the details of all Get-AzureNetworkAvailability jobs run against that server. If the Get-AzureNetworkAvailability command was successful, and the data successfully uploaded to the server, the local XML files will be deleted from the local Client PC. If any errors with the job or the data upload, the XML will remain on the local Client PC until a successful Get-AzureNetworkAvailability run at which point all previous data sets will be uploaded and the XML files deleted locally.

Example screen shots can be seen for these conditions:

 - [A Successful one minute run][One Minute]
 - [A successful ten hour run][Ten Hour]
 - [A successful run with errors][Errors]
 - [An unsuccessful run][Timeout]

### Data Presentation and Review
After running Get-AzureNetworkAvailability, a web page should open on the local PC, displaying the data for all script runs.
The page can be opened at any time by opening a browser and navigating to `http://<Azure VM IP>` e.g. http://10.0.0.1.

The drop down on that page will show all the data sets (by data and time) contained in the servers XML files.

Selecting a specific data set will display the graph and detailed tabular data for that run, as well as the summary information.

### Other Tool Cmdlets
There are five other commands that can be run:
- Clear-AzureCTHistory
- Show-AzureCTResults
- Get-HostName
- Get-IPTrace
- Remove-AzureCT

Both the Clear-AzureCTHistory and Show-AzureCTResults cmdlets have a single input parameter:
- **RemoteHost** - This parameter is required for Show-AzureCTResults and optional for Clear-AzureCTHistory, for both scripts this parameter is the IP Address of the Azure VM copied in step 2 of the Installation Instructions above.

#### Clear-AzureCTHistory
This function will delete any Get-AzureNetworkAvailability data on both the local PC and the remote Azure VM (if the remote server IP is provided). This command is never required to be run, but can be helpful if there are many entries in the web page drop-down box, a new series of tests is about to be run, or if the XML file size becomes slow rendering in the browser.

#### Show-AzureCTResults
This function will open a web browser on the local Client PC to display the Get-AzureNetworkAvailability data saved to the remote Azure VM.

#### Get-HomeName
This function uses a passed in IP address and does a DNS Host Name look-up using the default DNS look-up setting of the machine it's run on.

#### Get-IPTrace
This function uses a passed in IP address and performs a Trace Route like function. It's output is for the main Get-AzureNetworkAvailability function. To make this more human readable, use the Format-Table option.

```powershell
Get-IPTrace 10.0.0.1 | Format-Table
```

### Removing the Azure Connectivity Toolkit
Once testing is complete the Azure VM should be deleted to avoid unnecessary Azure usage (and associated charges) and all local files can be deleted. There is nothing permanently installed, only the PowerShell module files copied from GitHub and potentially the two XML files in the Local Client PC %temp% directory. 

To ensure 100% removal of all artifacts from this tool perform the following step:

1. Run the Remove-AzureCT command from PowerShell. This will remove the PowerShell module and any local data files.

	```powershell
	Remove-AzureCT
	```

## History

 - 2016-02-03 - Initial beta release 1.6.0.1
 - 2016-02-07 - Updated beta release 1.6.0.2
 - 2016-02-22 - Added more funcitons and client side trace 1.9.0.1

## Incorporated Licenses
This tool incorporates [JQuery](https://jquery.org/license/ "JQuery License") for XML manipulation and is included in the ServerSide files. JQuery.js is included and used under the requirements of the MIT License, and in compliance with the main JQuery license proviso "*You are free to use any jQuery Foundation project in any other project (even commercial projects) as long as the copyright header is left intact.*"

## Support and Legal Disclaimers
Microsoft provides no support for this software. All support, assistance, and information is on this site alone.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; INCREMENTAL AZURE COSTS INCURRED THROUGH USE OF THIS SOFTWARE; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<!--Image References-->
[0]: ./media/AzureCTAvailability.png "AzureCT Availability Test Diagram"

<!--Link References-->
[Download]: https://github.com/tracsman/AzureCT/archive/master.zip "Download Zip File Here"
[One Minute]: ./media/RunOneMinute.md
[Ten Hour]: ./media/RunTenHour.md
[Errors]: ./media/RunErrors.md
[Timeout]: ./media/RunTimeout.md
[MSDN]: https://technet.microsoft.com/en-us/library/hh849812.aspx
