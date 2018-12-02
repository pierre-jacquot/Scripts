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

$StartTime = Get-Date
$Hostname = [Environment]::MachineName
$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = $Workfolder + "\$Date-Purge-Folder.log"
$SourceFolder = "D:\Scripts\Purge-Folder\Logs"
$AllFiles = Get-ChildItem -Path $SourceFolder -Recurse | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddDays(-30)) -and ($_.Name -like "Test*") -and ($_.Extension -eq ".txt") }
$FilesNumber = $AllFiles.Count

cd $SourceFolder

Write-Host "Purge-Folder :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the deletion of [$FilesNumber] log file(s)." -ForegroundColor Cyan
Write-Host "`r"

If ($FilesNumber -eq 0) {
    Write-Host "No file has been removed" -ForegroundColor Green
    Write-Log -Output "$LogFile" -Message "No file has been removed"
}
Else {
    ForEach ($File in $AllFiles) {
        $FileName = $File.Name
        $FileLastWriteTime = $File.LastWriteTime
        $FileName | Remove-Item
        Write-Host "Last modification : $FileLastWriteTime - The file $FileName has been removed" -ForegroundColor Green
        Write-Log -Output "$LogFile" -Message "Last modification : $FileLastWriteTime - The file $FileName has been removed"
    }
}

$EndTime = Get-Date
$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
