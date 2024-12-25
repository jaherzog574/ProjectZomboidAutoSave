# In minutes.
$SaveInterval = 5

# Number of backups to keep (oldest ones are deleted afterwards.)
$BackupLimit = 15

# Locations backups will be from/to.
$BackupSrc = "$env:USERPROFILE\Zomboid\Saves"
$BackupDest = "$env:USERPROFILE\Zomboid\Saves\Backups"

Set-location -Path $BackupSrc
Import-Module Microsoft.PowerShell.Utility
$StartTime = (Get-Date).ToUniversalTime()
While (((Get-Process | Where-Object {$_.name -ieq 'ProjectZomboid64'}).count -ieq 1) -AND ((Get-Item -Path $BackupSrc).exists -ieq $True)) {
    Try{ 
        If ( [Int](((New-TimeSpan -Start $StartTime -End (Get-Date).ToUniversalTime()).TotalMinutes) % $SaveInterval) -ieq 0 ) {
            $CurrDateTime = (Get-Date -Format 'yyyy-MM-dd_hh-mm-ss')
            New-Item -Path $BackupDest -ItemType Directory -Force -ErrorAction Stop
            Write-Host "Creating a new backup..."  -ForegroundColor Cyan
            $ParentBackupFolder = (New-Item -Path "$($BackupDest)\$($CurrDateTime)" -ItemType Directory -Force -ErrorAction Stop).Parent.FullName
            Get-ChildItem -Path $BackupSrc -depth 1 | Where-Object {$_.FullName -inotlike "$ParentBackupFolder*" } | Copy-Item -Recurse -Force -Destination "$($BackupDest)\$($CurrDateTime)" -ErrorAction SilentlyContinue
            Write-Host "Created backup of saves at $($BackupDest)."  -ForegroundColor Green
            Start-Sleep -Seconds 60
            Continue

        } Else {
            $OldBackups = (Get-ChildItem -Path $BackupDest -depth 0 | Sort-Object CreationTimeUtc -Descending | Select-Object -Skip $BackupLimit)
            If (($OldBackups).count -ige 1) {
                $OldBackups | Remove-Item -Recurse -Force -ErrorAction Stop
                Write-Host "Deleted $(($OldBackups).count) old backup(s) in $($BackupDest)." -ForegroundColor Yellow
                Start-Sleep -Seconds 60
                Continue
            }
        }

    } Catch {
        $errorMessage = $Error[0] | Select-Object * | Out-String
        Write-Host "An error occured. The error message was: $errorMessage" -ForegroundColor Red
        Start-Sleep -Seconds 60
        Continue
    }
}

Write-Host "The Project Zomboid process appears to be no longer running (or the `"$BackupSrc`" location doesn`'t exist). Stopping automatic backups... Script will automatically close in 10 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 10
Exit 0

    
     
    