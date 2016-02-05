# Azure Connectivity Toolkit (AzureCT) - Availability Tool

[Return to the README Page][HOME]

## PowerShell
The following screen shot shows the PowerShell command and results of a five minute run of the Get-AzureNetworkAvailability script with two types of errors:

![0]

 - The **!** (exclamation point) represents successful calls to the Azure VM
 - The **\*** (asterisk) represents invalid data returned by the server (ie the server responded with an error or unexpected data)
 - The **.** (period) represents a call timeout.

## Web Display Screen Shot
Upon completion of the script it opens a local browser and displays from the remote Azure VM a graph, summary data, and detail data of the most recent run. 

The first "bad data" returned took 1,728ms (I changed the web page on the server, the long latency delay was the IIS server loading the new page), the next 5 calls were of normal latency as the server was responding as normal, but not with the response expected.

The next set of error data points were timeouts, these are seen as the five red points sitting on the X-Axis of the graph. In this case, I turned off the IIS server on the Azure VM and the PowerShell script was longer receiving any response to the web call, thus a timeout condition occurred. Timeout data points do not count for Min, Max, or Median data points, as these calls were not successful.

The specific error reason can be seen in the detailed table at the bottom of the page.

![1]
![2]

<!--Image References-->
[0]: PowerShellErrors.png "One Minute PowerShell Run"
[1]: DisplayErrors1.png "Web Server Display of Data Set"
[2]: DisplayErrors2.png "Web Server Display of Data Set"

<!--Link References-->
[HOME]: ../README.md