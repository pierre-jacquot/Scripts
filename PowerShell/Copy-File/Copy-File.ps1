<#
.SYNOPSIS
	Copy existing files
.DESCRIPTION
	Copy multiple files on a shared folder
.NOTES
	File name : Copy-File.ps1
	Author : Pierre JACQUOT
	Date : 13/06/2017
	Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/35-script-copy-file-v1-0
#>

Clear-Host
chcp 1252 | Out-Null

$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$Source = "D:\Scripts\Copy-File\Stockage"
[string]$Destination = "D:\Scripts\Copy-File\Archivage"
[string]$LogFile = $Workfolder + "\$Date-Copy-File.log"
[array]$Items = Get-ChildItem -Path $Source -Recurse
[int]$ItemsNumbers = $Items.Count

Write-Host "Copy-File :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the copy of [$ItemsNumbers] item(s)." -ForegroundColor Cyan

Robocopy $Source $Destination /MIR /V /TS /FP /ETA /LOG+:$LogFile /TEE

If ($LASTEXITCODE -eq 0) {
    Write-Host "`r"
    Write-Warning "No files were copied. No failure was encountered. No files were mismatched. The files already exist in the destination directory; therefore, the copy operation was skipped."
}
ElseIf ($LASTEXITCODE -gt 8) {
    Write-Host "`r"
    Write-Host "Error during processing copy." -ForegroundColor Red
}
Else {
    Write-Host "`r"
    Write-Host "All files were copied successfully." -ForegroundColor Green
}

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
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
