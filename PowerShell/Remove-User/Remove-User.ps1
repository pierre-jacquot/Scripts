<#
.SYNOPSIS
    Remove AD users
.DESCRIPTION
    Remove multiple users of an AD group
.NOTES
    File name : Remove-User.ps1
    Author : Pierre JACQUOT
    Date : 16/05/2016
    Version : 1.0
.LINK
    Website : http://pierro.jacquot.free.fr
    Reference : http://pierro.jacquot.free.fr/index.php/scripts/28-script-remove-user
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
$LogFile = $Workfolder + "\$Date-Remove_User.log"
$Records = Import-Csv -Path ".\Remove-User.csv"
$LineNumbers = $Records.Count

Write-Host "Remove-User :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the deletion of [$LineNumbers] user(s) from an AD group." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Record in $Records) {
    $LoginName = $Record.sAMAccountName
    $GroupName = $Record.GroupName
    Try {
        Remove-ADGroupMember -Identity $GroupName -Members $LoginName -Confirm:$false
        Write-Host "$LoginName has been removed of the group : $GroupName" -ForegroundColor Green
        Write-Log -Output $LogFile -Message "$LoginName has been removed of the group : $GroupName"
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Log -Output "$LogFile" -Message "$ErrorMessage"
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
