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

Export-ModuleMember -Function Get-AzureNetworkAvailability
Export-ModuleMember -Function Get-IPTrace
Export-ModuleMember -Function Clear-AzureCTHistory
Export-ModuleMember -Function Show-AzureCTResults
Export-ModuleMember -Function Remove-AzureCT