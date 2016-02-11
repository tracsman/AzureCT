$Old = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'WindowsPowerShell\Modules\AzureCT\'
$New = "C:\Bin\Git\Repos\AzureCT\PowerShell\AzureCT"

Remove-Module AzureCT
If (Test-Path $Old) {Remove-Item $Old -Recurse}
Copy-Item $New -Destination $Old -Recurse
Install-Module AzureCT
Write-Host "Swap Complete" -ForegroundColor Green