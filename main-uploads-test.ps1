$APIURL = "10.11.0.24/austin/API/index.php"
$category = "Uploads"
$i = 1
$SmallFile = "smallfile"
$SmallFileName = "smallfile.txt"
$BigFile = "bigfile"
$BigFileName = "Bigfile.zip"
$FolderSeparator = "\"
$FromFolder = "C:\Users\Austin\Desktop\Bash\B2BEconnectPS\fromFolder"
$ToFolder = "C:\Users\Austin\Desktop\Bash\B2BEconnectPS\toFolder"
$MoveToFolder = "C:\Users\Austin\Desktop\Bash\B2BEconnectPS\moveToFolder"
$DroneDir = "C:\Users\Austin\Desktop\Bash\B2BEconnectPS"
$DroneFile = "$($DroneDir)$($FolderSeparator)drone.ps1"
$CurDir = $(pwd)


function clearLockFiles {
    Remove-Item "$($DroneDir)$($FolderSeparator)*.lock"

}
function clearFromFolder {
    Remove-Item "$($FromFolder)$($FolderSeparator)*"
}
function clearToFolder {
    Remove-Item "$($ToFolder)$($FolderSeparator)*"
}
function clearMoveToFolder {
    Remove-Item "$($MoveToFolder)$($FolderSeparator)*"
}

function checkFromFolder {
    param ([string]$for)
    $result = "" 
    $status = "fail"

    if ($for -eq "") {
        if (Test-Path -Path "$($FromFolder)$($FolderSeparator)*") {
            $result = "fromFolder is NOT empty"
            $status = "fail"
        }
        else {
            $result = "fromFolder IS empty"
            $status = "success"
        }

    }
    else {
        if (Test-Path -Path "$($FromFolder)$($FolderSeparator)$($for)") {
            $result = "$($for) IS in fromFolder"
            $status = "success"
        }
        else {
            $result = "$($for) is NOT in fromFolder"
            $status = "fail"
        }
    }
    return @{
        "status" = $status
        "result" = $result
    }
}
function checkToFolder {
    param ([string]$for)
    $result = "" 
    $status = "fail"

    if ($for -eq "") {
        if (Test-Path -Path "$($ToFolder)$($FolderSeparator)*") {
            $result = "toFolder is NOT empty"
            $status = "fail"
        }
        else {
            $result = "toFolder IS empty"
            $status = "success"
        }

    }
    else {
        if (Test-Path -Path "$($ToFolder)$($FolderSeparator)$($for)") {
            $result = "$($for) IS in toFolder"
            $status = "success"
        }
        else {
            $result = "$($for) is NOT in toFolder"
            $status = "fail"
        }
    }
    return @{
        "status" = $status
        "result" = $result
    }
}
function checkMoveToFolder {
    param ([string]$for)
    $result = "" 
    $status = "fail"

    if ($for -eq "") {
        if (Test-Path -Path "$($MoveToFolder)$($FolderSeparator)*") {
            $result = "moveToFolder is NOT empty"
            $status = "fail"
        }
        else {
            $result = "moveToFolder IS empty"
            $status = "success"
        }

    }
    else {
        if (Test-Path -Path "$($MoveToFolder)$($FolderSeparator)$($for)") {
            $result = "$($for) IS in moveToFolder"
            $status = "success"
        }
        else {
            $result = "$($for) is NOT in moveToFolder"
            $status = "fail"
        }
    }
    return @{
        "status" = $status
        "result" = $result
    }
}
function runDrone {

    param([string]$name)

    $job = Start-Job -ScriptBlock { param($DroneFile) & $DroneFile } -Name $name -WorkingDirectory $DroneDir -ArgumentList $DroneFile

    return $job
}

function writeDescription {
    param ([string]$description, [string]$status)

    if ($status -ne "") {
        if ($status -eq "success") {
            # Write-Host "`t`t-> $description" -NoNewline
            # Write-Host "`t#" -ForegroundColor Green 
            Write-Host "`t`t#" -ForegroundColor Green -NoNewline
            Write-Host " -> $description"
        }
        else {
            # Write-Host "`t`t-> $description" -NoNewline
            # Write-Host "`t#" -ForegroundColor Red
            Write-Host "`t`t#" -ForegroundColor Red -NoNewline
            Write-Host " -> $description"
        }

    }
    else {
        Write-Host "`t`t-> $description"

    }
}

function writeTitle { 
    param([string]$title) 
    Write-Host "`t$($title)"
}

function writeTestResult {
    param([string]$testName, [string]$result, [string]$description) 
    if ($result -eq "success") {
        Write-Host "`t$($testName): " -NoNewline
        if ($description -ne "") {
            Write-Host "`t$($result)" -ForegroundColor Green -NoNewline
            Write-Host "`t->$($description)`n"
        }
        else {
            Write-Host "`t$($result)" -ForegroundColor Green
        }
    }
    else {
        Write-Host "`t$($testName): " -NoNewline
        if ($description -ne "") {
            Write-Host "`t$($result)" -ForegroundColor Red -NoNewline
            Write-Host "`t->$($description)"
        }
        else {
            Write-Host "`t$($result)" -ForegroundColor Red

        }
    }

}

function APICheck {
    param ($data) 

    $JSONresult = Invoke-WebRequest -Method "Get" -Uri $APIURL -Body $data 
    $result = ConvertFrom-Json -InputObject $JSONresult.content

    return $result

}

function checkResults {
    param($resultsArray)
    $result = "fail"

    if (!$($resultsArray.Contains("fail"))) {
        $result = "success"
    }
    return $result
}


Clear-Host
# DOWNLOAD TESTS
$i = 1
$count = 2

./downloads-single-smallfile.ps1 $i $count
Write-Output ""
$i++
./downloads-single-bigfile.ps1 $i $count
Write-Output ""
$i++
./downloads-multifile.ps1 $i $count