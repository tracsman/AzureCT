# HybridTool
Azure Hybrid Availability Tool

## Overview
This tool displays availability statistics for a newly built Windows VM on a Hybrid connected Network.

## Tool Usage
### Prerequisites
This tool has some perquisites to be in place before using this tool:
- Hybrid Network in Azure (either VPN or ExpressRoute)
- A New Windows VM on the Azure network reachable from the on-prem network
- A client PC running PowerShell 3.0 or greater on the on-prem side

### Installation Instructions
1. Download the Github folders to your local client PC
2. On a newly built Windows VM in Azure:
	1. Copy the IISBuild.ps1 script from the ServerSide folder to the Azure VM.
	2. Open an elevated PowerShell prompt on the Azure VM.
	3. Run the IISBuild.ps1 to turn on ping, install IIS, and create some application files. This step will create seven files on the server:
		- Home.aspx
		- WebTest.aspx
		- Upload.aspx
		- ClearHistory.aspx
		- Web.Config
		- JobHeader.xml
		- JobDetail.xml 
3. Note the local IP address of the Azure VM.
	- From PowerShell run: `(Get-NetIPAddress).IPv4Address`
	- Copy the first IP address, this should be the VNet IP address for your server. Note: it's not the 127.0.0.1 address.
4. On the local Client PC, open a web browser.
5. Goto http://<IP Copied from Step 3>; e.g. http://10.0.0.1
6. You should successful bring up a web page titled "Hybrid Diagnostic Home Page".

### Running the tool
1. On the local Client PC, open a PowerShell prompt.
2. Navigate to the directory where the GitHub files where copied in step 1 of the Installation Instructions above.
3. The main command is WebPing.ps1, this commandlet has four parameters
	- **RemoteHost** - This is required and is the local IP Address copied in step 1 of the Installation Instructions above.
	- **Duration** - This optional parameter signified the duration of the WebPing command. The default value is 10. This can be 10 seconds or 10 minutes depending on the value for the DurationInterval parameter.
	- **DurationInterval** - This optional parameters signifies if your duration value will be in Minutes or Seconds. The valid options for this parameter is "Seconds" or "Minutes". The defualt option is "Minutes".
	- **TimeoutSeconds** - This optional parameter signifies how long each WebPing will wait for a response. The default value is 2 seconds.
4. For the first run, I recommend doing a test run of 10 seconds. In the PowerShell prompt run the following command: `.\WebPing.ps1 -RemoteHost <Azure VM IP> -DurationInterval Seconds`

### Tool Output
The WebPing commandlet will issue a call to a web page on the remote server (WebTest.aspx), based on the response either an error, a timeout, or a successful response, the script will wait one second and try again. Each call will produce command line output of one of the following.

>**Possible Script Output**
>
>! - Successfull WebPing
>
>. - Unsuccsefull WebPing (timeout)
>
> \* - IP was reached but wrong data or error (404) was returned

Each call to the web server is also recorded locally in two xml files.
-JobHeader.xml
-JobDetail.xml

At the end of the commandlet, a summary of the run will be output to the PowerShell prompt similar to ping results.

The xml files are also uploaded to the server and a web browser should open on the local client machine with the details of all WebPing jobs run from that PC.

### Data Presentation and Review
After running WebPing.ps1, a web page should open on the local PC, displaying WebPing data for all script runs.
The page can be opened at any time by opening a browser and navigating to `http://<Azure VM IP>/index.html`.

The drop down on that page, will show all the jobs (by data and time) contained in the XML files.

Selecting a job will display the graph and tabular data for that run as well as the summary information.

### Other Tool Commandlets
There are two other commandlets that can be run:
- Clear-History.ps1 
- Show-Results.ps1

Both commandlets have a single input parameter:
- **RemoteHost** - This is required and is the local IP Address copied in step 1 of the Installation Instructions above.

#### Clear-History.ps1
This commandlet will delete the WebPing xml files on both the local PC and the remote Azure VM.

#### Show-Results.ps1
This commandlet will open a web browser on the local Client PC to display the WebPing xml data saved to the remote Azure VM. 
