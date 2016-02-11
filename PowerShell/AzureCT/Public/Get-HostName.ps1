
function Get-HostName {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage='Enter IP Address')]
        [ipaddress] $HostIP)
    Try {
        Return [System.Net.Dns]::GetHostEntry($HostIP).HostName
    }
    Catch {
        Return ''
    }
}