$unfilteredLogName = "../input/syslog.log"
$filteredLogName = "../output/filteredSyslog.log"
$dedupedCsv = "../output/logs.csv"

$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$outputCsv = "../output/outages_$timestamp.csv"

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

$deduped | Export-Csv $dedupedCsv -NoTypeInformation -Force

$output = @()
for ($i = 1; $i -lt $deduped.Length; $i++){
    $entry = $deduped[$i]

    if($entry.OnOff -eq 'ON'){
        # We only care about outages
        continue
    }

    $outageStartTime = $entry.Date

    $outageEndTime = $deduped[$i - 1].Date

    $outageLength = New-Timespan -Start $outageStartTime -End $outageEndTime

    $properties = @{
        OutageStart = $outageStartTime
        LengthInSeconds = $outageLength.TotalSeconds
    }
    $obj = New-Object psobject -Property $properties
    $output += $obj
}

foreach($item in $output | Sort-Object OutageStart){
    Write-Host "An outage began " $item.OutageStart " and lasted " $item.LengthInSeconds " seconds"
}

$output | Sort-Object OutageStart | Export-Csv $outputCsv -NoTypeInformation -Force
