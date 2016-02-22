#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

$ModuleManifest = Test-ModuleManifest -path $PSScriptRoot\AzureCT.psd1
$script:XMLSchemaVersion = ([string]$ModuleManifest.Version.Major) + "." + ([string]$ModuleManifest.Version.Minor)

Export-ModuleMember -Function Get-AzureNetworkAvailability
Export-ModuleMember -Function Get-IPTrace
Export-ModuleMember -Function Clear-AzureCTHistory
Export-ModuleMember -Function Show-AzureCTResults
Export-ModuleMember -Function Remove-AzureCT
Export-ModuleMember -Function Get-Test