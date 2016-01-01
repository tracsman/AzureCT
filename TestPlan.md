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
2. Setup Azure Server
3. WebPing Duration 5 Seconds
4. WebPing Duration 1 Minute
5. WebPing Timeout 1 Second
6. WebPing Bad IP / Timeout Errors
7. WebPing Bad Test Page / Bad Page Data
8. WebPing Bad IP
9. WebPing all defaults
10. Review Results on Index.html
11. Show Results
12. Show Results with bad remote host
13. Clear History
14. Show Results with no XML data
15. Clear History with bad remote host

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
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

2. Test Name: **Setup Azure Server**

	**Execution Steps**
	1. Blah
	2. Bloo
	3. Blee

	**Expected Results**
	1. Blah
	2. Blue
	3. Blee

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


