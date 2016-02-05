# Azure Connectivity Toolkit (AzureCT) - Availability Tool

[Return to the README Page][HOME]

## PowerShell
The following screen shot shows the PowerShell command and results of a successful ten hour run of the Get-AzureNetworkAvailability script:

![0]

## Web Display Screen Shot
Upon completion of the script it opens a local browser and displays from the remote Azure VM a graph, summary data, and detail data of the most recent run. Past data sets are available in the drop down. The individual runs are truncated in the screen shot as there were 3,600 rows in the bottom table, one for each call to the web server.

![1]

<!--Image References-->
[0]: PowerShellTenHour.png "One Minute PowerShell Run"
[1]: DisplayTenHour.png "Web Server Display of Data Set"

<!--Link References-->
[HOME]: ../README.md