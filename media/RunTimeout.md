# Azure Connectivity Toolkit (AzureCT) - Availability Tool

[Return to the README Page][HOME]

## PowerShell
The following screen shot shows the PowerShell command and results of an unsuccessful one minute run of the Get-AzureNetworkAvailability script and then a successful one minute run:

![0]

In this example, I found the IP address for CNN.COM and used that instead of my Azure VM IP Address. The test timed out (the * (asterisk) symbol) each call. At the end there was a yellow warning, stating that the data could not be uploaded.

I then ran the script again, this time with the right IP address. At the successful conclusion of that run, both data sets were uploaded to the server as show in the next section.

## Web Display Screen Shot
Each call to the server failed as shown by the red points sitting on the X-axis. Note the Target IP in the summary section as this is the IP address used in the call that timed out.

![1]

<!--Image References-->
[0]: PowerShellTimeout.png "One Minute PowerShell Run"
[1]: DisplayTimeout.png "Web Server Display of Data Set"

<!--Link References-->
[HOME]: ../../../