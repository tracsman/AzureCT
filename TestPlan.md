#Test Plan

## Overview
This is an internal document for use by the author to build and test the Azure Hybrid Availability Tool

## Introduction
This test plan will define the initial environment to start testing, deployment steps of the tool, and the tests required to validate the tool. 

The testing is currently only testing on an ExpressRoute connected subscription. VPN will be added in a future release.

## References
None

## Test Items
- Azure Subscription
- Azure VNet
- Azure VPN Gateway
- Azure ExpressRoute circuit
- Azure VM Server
- Local Client PC with PowerShell 3.0 or greater installed

## Features to be Tested
 - Server installation script, IISBuild.ps1
 - All parameters of the WebPing commandlet (including associated web pages index.html and upload.aspx)
 - Clear-History.ps1 commandlet (including associated web page ClearHistory.aspx)
 - Show-Results.ps1 commandlet

## Features not to be Tested
None

## Tests
### Test to Run
1. Download Files from GitHub
2. Run Server Setup Script
3. Run Server Setup Script with Errors
4. WebPing Duration 5 Seconds
5. WebPing Duration 1 Minute
6. WebPing Timeout 1 Second
7. WebPing Bad IP / Timeout Errors
8. WebPing Bad Test Page / Bad Page Data
9. WebPing Bad IP
10. WebPing all defaults
11. Review Results on Index.html
12. Show Results
13. Show Results with bad remote host
14. Clear History
15. Show Results with no XML data
16. Clear History with bad remote host

### Build Initial Environment
1. Clear GitHub, PowerShell, and XML files from Client PC
2. Clear test subscription
3. Build VNet
4. Build Gateway
5. Build ER Circuit
6. Link Gateway
7. Build Azure VM
8. RDP from local Client PC to validate initial setup

### Execute Tests
1. Download Files from GitHub

	**Execution Steps**
	1. Clear any old script files from local Client PC
	2. Navigate to https://github.com/tracsman/HybridTool/tree/master/PowerShell
	3. Download all files in the PowerShell directory to a directory on the local Client PC

	**Expected Results**
	
	1. Files from the PowerShell directory on GitHub are on the local PC.

2. Test Name: **Run Server Setup Script**

	**Execution Steps**
	
	1. Copy the contents of the BuildIIS.ps1 script from the ServerSide folder on GitHub to the clipboard of the local Client PC.
	2. Open the Azure Management Portal and identify the local IP of the Azure VM created in step 7 of the "Build Initial Environment" section, here after called the "Azure VM".
	2. From a command prompt on the local Client PC, run the command "mstsc".
	3. Enter the IP Address of the Azure VM.
	4. Logon using the Admin credential of the Azure VM.
	5. Create a text file on the Azure VM desktop called BuildIIS.ps1
	6. Paste in the contents of the BuildIIS.ps1 file copied in step 1.
	7. In the Azure VM open an elevated PowerShell window (ie Run as Administrator)
	8. At the PowerShell prompt run the script file created in step 6.

	**Expected Results**
	
	1. Script will run, with no error notifications.
	2. IIS will be installed (Look for a C:\inetpub directory).
	3. All ServerSide files will be resisdent in the c:\inetpub\wwwroot directory.
	4. On the Client PC, a web broswer can successfully hit http://AzureVM_IP (page should resolve with no data)

2. Test Name: **Run Server Setup Script with Errors**

	**Execution Steps**
	
	1. Log on to the Azure VM.
	2. Edit one of the file names in BuildIIS.ps1 (on the desktop) to a non-existant file.
	3. Open an elevated PowerShell prompt.
	4. Run the BuildIIS.ps1 script

	**Expected Results**
	
	1. Script will run, with one error message
	2. Bad file name should be mentioned in red with instructions to manually copy the file.

3. Test Name:  **WebPing Duration 5 Seconds**

	**Execution Steps**
	
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	
	1. Blah
	2. Blue
	3. Blee

4. Test Name:  **WebPing Duration 1 Minute**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

5. Test Name:  **WebPing Timeout 1 Second**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee


6. Test Name:  **WebPing Bad IP / Timeout Errors**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

7. Test Name:  **WebPing Bad Test Page / Bad Page Data**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

8. Test Name: **WebPing Bad IP**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

9. Test Name: **WebPing all defaults**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

10. Test Name: **Review Results on Index.html**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

11. Test Name: **Show Results**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

12. Test Name: **Show Results with bad remote host**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

13. Test Name: **Clear History**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

14. Test Name: **Show Results with no XML data**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

15. Test Name: **Clear History with bad remote host**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee


