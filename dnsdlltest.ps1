Param($ScriptFile = {
    $computer = $args[0]
    $key = "SYSTEM\CurrentControlSet\services\DNS\Parameters\"
    $value = "ServerLevelPluginDll"
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
    $regkey = $reg.opensubkey($key)
    $data = if ($regkey.getvalue($value)) { $true } Else { $false }
    [PSObject]@{
        Server = $computer
        Reg = $data
    }
}, 
    $MaxThreads = 100,
    $SleepTimer = 500,
    $MaxWaitAtEnd = 600,
    $OutputType = "Text")

$sw = [Diagnostics.Stopwatch]::StartNew()

$computers = Get-ADDomainController -filter *
Write-Host $computers.count "Domain Controllers detected"

"`nKilling existing jobs . . ."
Get-Job | Remove-Job -Force
"Done."
 
$i = 0
ForEach ($computer in $computers.hostname){
    While ($(Get-Job -state running).count -ge $MaxThreads){
        Write-Progress  -Activity "Getting service status" -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $computers.count * 100)
        Start-Sleep -Milliseconds $SleepTimer
    }
    $i++
    Start-Job -ScriptBlock $ScriptFile -ArgumentList $computer | Out-Null
    Write-Progress  -Activity "Getting service status" -Status "Starting Threads" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $computers.count * 100)
    
}
 
Write-Host "Waiting for jobs to complete, this may take a few minutes" -ForegroundColor Cyan

$yeet = Wait-Job * | Get-Job | Receive-Job
$bad = $yeet | where {$_.reg -eq $true }
if ( $bad ) {
    "IOC Spotted"
    $bad  | Export-CSV -Path "$home\desktop\dnsdll.csv" -NoTypeInformation
} Else {
    "Nothing found"
}
$sw.Stop()
Write-Host "Time elapsed" $sw.Elapsed.ToString()
