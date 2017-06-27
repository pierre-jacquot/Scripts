<#
.SYNOPSIS
    Add AD users
.DESCRIPTION
    Add multiple users in an AD group
.NOTES
    File name : Add-User.ps1
    Author : Pierre JACQUOT
    Date : 16/05/2016
    Version : 1.0
.LINK
    Website : http://pierro.jacquot.free.fr
    Reference : http://pierro.jacquot.free.fr/index.php/scripts/27-script-add-user
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
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = $Workfolder + "\$Date-Add-User.log"
$Records = Import-Csv -Path ".\Add-User.csv"
$LineNumbers = $Records.Count

Write-Host "Add-User :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the addition of [$LineNumbers] user(s) into an AD group." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Record in $Records) {
    $LoginName = $Record.sAMAccountName
    $GroupName = $Record.GroupName
    Try {
        Add-ADGroupMember -Identity $GroupName -Member $LoginName
        Write-Host "$LoginName has been added into the group : $GroupName" -ForegroundColor Green
        Write-Log -Output $LogFile -Message "$LoginName has been added into the group : $GroupName"
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Log -Output "$LogFile" -Message "$ErrorMessage"
    }
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
