param ([int]$i, [int]$totalTestCount)
$testName = "Single File Download (smallfile)"
Write-Host "$category test - $($i)/$($totalTestCount): $testName"

# SETUP PHASE
clearLockFiles
$resultArray = New-Object -TypeName 'System.Collections.ArrayList';
$data = @{
    "MyAction" = "copy"
    "MyPath"   = "outgoing"
    "MyFile"   = "$SmallFile"
}
$result = APICheck $data
writeTitle "Setup phase: START"

# SETUP TEST #1
writeDescription $result.description $result.result
$resultArray.Add($result.result) | Out-Null
# SETUP TEST #2
clearToFolder
$temp = $(checkToFolder)
writeDescription $temp.result $temp.status
$resultArray.Add($temp.status) | Out-Null
# SETUP TEST FINAL
$finalResult = checkResults $resultArray
writeTestResult "Setup phase" $finalResult ""


# DO PHASE
writeTitle "`n`tDo phase: START"
$resultArray = New-Object -TypeName 'System.Collections.ArrayList';
$job = runDrone $testName
$timeLimit = 100
$result = "fail"
for ($counter = 0; $counter -lt $timeLimit; $counter++) {
    Write-Progress -Id 1 -Activity "Running $($testName)" -Status "wait time: $counter`/$timeLimit" -PercentComplete $((($counter / $timeLimit) * 100))
    $temp = $(checkToFolder $SmallFileName)

    if ([string]$temp.status -eq "success") {
        $result = "success"
        $resultArray.Add($result) | Out-Null
        writeDescription "smallfile IS in toFolder" $result

        Write-Progress -Id 1 -Activity "Running $($testName)" -Completed

        Start-Sleep -Seconds 2
        $data = @{
            "MyAction" = "check"
            "MyPath"   = "outgoing"
            "MyFile"   = "$SmallFile"
        }
        $result = APICheck $data
        if ($result.result -eq "fail") {
            $resultArray.Add("success") | Out-Null
            writeDescription $result.description "success"
        }
        else {
            $resultArray.Add("fail") | Out-Null
            writeDescription $result.description "fail"
        }
        break
    }
    Start-Sleep -Seconds 1
}
writeTestResult "Do phase" $(checkResults $resultArray) ""
Remove-Job $job -Force