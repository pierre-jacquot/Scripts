<#
.SYNOPSIS
    Remove AD users
.DESCRIPTION
    Remove multiple users in AD group(s)
.NOTES
    File name : Remove-User.ps1
    Author : Pierre JACQUOT
    Date : 16/05/2016
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/28-script-remove-user
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
[string]$LogFile = $Workfolder + "\$Date-Remove_User.log"
[array]$Records = Import-Csv -Path ".\Remove-User.csv" -Delimiter "," -Encoding UTF8
[int]$LineNumbers = $Records.Count
[string]$Activity = "Trying to launch the deletion of [$LineNumbers] user(s) into AD group(s)"
[int]$Step = 1

Write-Host "Remove-User :" -ForegroundColor Black -BackgroundColor Yellow
Try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "ActiveDirectory module has been imported." -ForegroundColor Green
    Write-Log -Output $LogFile -Message "ActiveDirectory module has been imported"
}
Catch {
    Write-Warning "The ActiveDirectory module failed to load. Install the module and try again."
    Write-Log -Output "$LogFile" -Message "The ActiveDirectory module failed to load. Install the module and try again"
    Pause
    Write-Host "`r"
    Exit
}
Write-Host "Launching the deletion of [$LineNumbers] user(s) from an AD group." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Record in $Records) {
    [string]$LoginName = $Record.sAMAccountName
    [string]$GroupName = $Record.GroupName
    [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
    [string]$CurrentOperation = "Removing AD user : $LoginName into the group : $GroupName"
    Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
    $Step++
    Start-Sleep -Seconds 1
    Try {
        Remove-ADGroupMember -Identity $GroupName -Members $LoginName -Confirm:$false
        Write-Host "$LoginName has been removed of the group : $GroupName" -ForegroundColor Green
        Write-Log -Output $LogFile -Message "$LoginName has been removed of the group : $GroupName"
    }
    Catch {
        [string]$ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Log -Output "$LogFile" -Message "$ErrorMessage"
        Write-Host "`r"
        Exit
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
