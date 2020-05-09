<#
.SYNOPSIS
    Delete old log files.
.DESCRIPTION
    Delete all log files in a folder that haven't been modified in the last 30 days.
.NOTES
    File name : Purge-Folder.ps1
    Author : Pierre JACQUOT
    Date : 07/02/2018
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/43-script-purge-folder
#>

Clear-Host

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

[datetime]$StartTime = Get-Date
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$LogFile = $Workfolder + "\$Date-Purge-Folder.log"
[string]$SourceFolder = "D:\Scripts\Purge-Folder\Logs"
[array]$AllFiles = Get-ChildItem -Path $SourceFolder -Recurse
[array]$ConditionFiles = Get-ChildItem -Path $SourceFolder -Recurse | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddDays(-30)) -and ($_.Name -like "Test*") -and ($_.Extension -eq ".txt") }
[int]$FilesNumber = $AllFiles.Count
[int]$ConditionFilesNumber = $ConditionFiles.Count
[string]$Activity = "Trying to launch the deletion of [$ConditionFilesNumber] log file(s)"
[int]$Step = 1

cd $SourceFolder

Write-Host "Purge-Folder :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the deletion of [$ConditionFilesNumber] log file(s)." -ForegroundColor Cyan
Write-Host "`r"

If ($FilesNumber -eq 0) {
    Write-Warning "Source folder $SourceFolder is empty"
    Write-Log -Output "$LogFile" -Message "Source folder $SourceFolder is empty"
}
ElseIf ($ConditionFilesNumber -eq 0) {
    Write-Warning "Source folder $SourceFolder does not contain Test*.txt files older than 30 days"
    Write-Log -Output "$LogFile" -Message "Source folder $SourceFolder does not contain Test*.txt files older than 30 days"
}
Else {
    ForEach ($File in $ConditionFiles) {
        [string]$FileName = $File.Name
        $FileLastWriteTime = $File.LastWriteTime
        $FileName | Remove-Item
        [string]$Status = "Processing [$Step] of [$ConditionFilesNumber] - $(([math]::Round((($Step)/$ConditionFilesNumber*100),0)))% completed"
        [string]$CurrentOperation = "Removing log file :  $FileName - (Last modification : $FileLastWriteTime)"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$ConditionFilesNumber*100)
        $Step++
        Start-Sleep -Seconds 1
        Write-Host "The file $FileName has been removed - (Last modification : $FileLastWriteTime)" -ForegroundColor Green
        Write-Log -Output "$LogFile" -Message "The file $FileName has been removed - (Last modification : $FileLastWriteTime)"
    }
}

[datetime]$EndTime = Get-Date
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFile -Leaf) -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
