$unfilteredLogName = "../input/syslog.log"
$filteredLogName = "../output/filteredSyslog.log"
$csvName = "../output/logs.csv"

Remove-Item -Force $filteredLogName -ErrorAction Ignore

Get-Content $unfilteredLogName | Select-String -Pattern "WAN1_(OFF|ON)" | Set-Content $filteredLogName -Force

$filteredLogLines = Get-Content $filteredLogName | Select-Object -Property @{Name = 'Date'; Expression = {[datetime]::ParseExact($_.Substring(0,19), "yyyy-MM-dd HH:mm:ss", $null)}}, @{Name = 'OnOff'; Expression = {$_.Substring($_.IndexOf("WAN1_") + 5,2)}} | Sort-Object Date -Descending

$deduped = @()
for ($i = 0; $i -lt $filteredLogLines.Length; $i++){
    $line = $filteredLogLines[$i]
    if ($i -eq 0){
        $deduped+= $line
        continue
    }
    
    $latestDedupedItem = $deduped[-1]
    if ($latestDedupedItem.OnOff -ne $line.OnOff){
        $deduped+= $line
    }
}

$deduped

$deduped | Export-Csv $csvName -NoTypeInformation -Force

