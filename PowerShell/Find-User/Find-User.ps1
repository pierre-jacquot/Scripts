<#
.SYNOPSIS
    Find AD users.
.DESCRIPTION
    Check if users exist in AD.
.NOTES
    File name : Find-User.ps1
    Author : Pierre JACQUOT
    Date : 14/05/2016
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/26-script-find-user
#>

Clear-Host
Import-Module ActiveDirectory

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

$StartTime = Get-Date
$Hostname = [Environment]::MachineName
$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFileOK = $Workfolder + "\$Date-Users_OK.log"
$LogFileKO = $Workfolder + "\$Date-Users_KO.log"
$Logins = (Get-Content -Path ".\Logins.txt")
$LineNumbers = $Logins.Count

Write-Host "Find-User :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the research of [$LineNumbers] user(s) in AD." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($ADLogin in $Logins) {
    $User = Get-ADUser -Filter { sAMAccountName -eq $ADLogin }
    If ($User -eq $Null) {
        Write-Host "$ADLogin - User does not exist in AD" -ForegroundColor Red
        Write-Log -Output $LogFileKO -Message "$ADLogin - User does not exist in AD"
    }
    Else {
        Write-host "$ADLogin - User found in AD" -ForegroundColor Green
        Write-Log -Output $LogFileOK -Message "$ADLogin - User found in AD"
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
