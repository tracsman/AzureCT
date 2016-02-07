# Install-AzureCT Module
# To kick me off from a URL run the following:
# (new-object Net.WebClient).DownloadString("https://github.com/tracsman/AzureCT/raw/vnext/PowerShell/Install-AzureCT.ps1") | Invoke-Expression

function Install-AzureCT {

    $uri = 'https://github.com/tracsman/AzureCT/raw/vnext/PowerShell/AzureCT/'
    $FileName = @()
    $FileName += 'AzureCT.psd1'
    $FileName += 'AzureCT.psm1'
    $FileName += 'Public/Clear-AzureCTHistory.ps1'
    $FileName += 'Public/Get-AzureNetworkAvailability.ps1'
    $FileName += 'Public/Show-AzureCTResults.ps1'
   
    $Destination = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'WindowsPowerShell\Modules\'
    New-Item -Path ($Destination + "\AzureCT\") -ItemType Directory -Force | Out-Null
    New-Item -Path ($Destination + "\AzureCT\Public") -ItemType Directory -Force | Out-Null

    Write-Host

    ForEach ($File in $FileName) {
        $webClient = new-object System.Net.WebClient
        $webClient.DownloadFile( $uri + $File, $Destination + '\AzureCT\' + $File )
        Write-Host "Copied successfully:" $File 
    }

    $executionPolicy = (Get-ExecutionPolicy)
    $executionRestricted = ($executionPolicy -eq "Restricted")
    if ($executionRestricted) {
        Write-Warning "Your execution policy is $executionPolicy, this means you will not be able import or use any scripts including modules."
        Write-Warning "To fix this change your execution policy to something like RemoteSigned."
        Write-Host
        Write-Warning "     PS> Set-ExecutionPolicy RemoteSigned"
        Write-Host
        Write-Warning "For more information execute:"
        Write-Host
        Write-Warning "     PS> Get-Help about_execution_policies"
    }
    Else {
        # ensure AzureCT is imported from the location it was just installed to
        Import-Module -Name $Destination\AzureCT
    }
    Write-Host "AzureCT is installed and ready to use" -Foreground Green
    Write-Host
}

Install-AzureCT
