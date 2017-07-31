<#
.SYNOPSIS
    Copy existing files.
.DESCRIPTION
    Copy multiple files on a shared folder.
.NOTES
    File name : Copy-File.ps1
    Author : Pierre JACQUOT
    Date : 13/06/2017
    Version : 1.0
.LINK
    Website : http://pierro.jacquot.free.fr
    Reference : http://pierro.jacquot.free.fr/index.php/scripts/35-script-copy-file
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
$Source = "D:\Scripts\Copy-File\Stockage"
$Destination = "D:\Scripts\Copy-File\Archivage"
$LogFile = $Workfolder + "\$Date-Copy-File.log"
$Items = @(Get-ChildItem -Path $Source)
$ItemsNumbers = $Items.Count

Write-Host "Copy-File :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the copy of [$ItemsNumbers] item(s)." -ForegroundColor Cyan
Write-Host "`r"

Robocopy $Source $Destination /MIR /V /TS /FP /ETA /LOG+:$LogFile /TEE

If ($LASTEXITCODE -eq 0) {
    Write-Host "`r"
    Write-Warning "No files were copied. No failure was encountered. No files were mismatched. The files already exist in the destination directory; therefore, the copy operation was skipped."
}
ElseIf ($LASTEXITCODE -gt 8) {
    Write-Host "`r"
    Write-Host "ERROR during processing copy." -ForegroundColor Red
}
Else {
    Write-Host "`r"
    Write-Host "All files were copied successfully." -ForegroundColor Green
}

$EndTime = Get-Date
$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " minutes"
Write-Host "`r"
