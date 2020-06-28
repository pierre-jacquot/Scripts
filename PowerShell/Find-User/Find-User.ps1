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

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d/%m/%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$LogFileOK = $Workfolder + "\$Date-Users_OK.log"
[string]$LogFileKO = $Workfolder + "\$Date-Users_KO.log"
[array]$Logins = Get-Content -Path ".\Logins.txt" -ErrorAction SilentlyContinue
[int]$LineNumbers = $Logins.Count
[string]$Activity = "Trying to launch the research of [$LineNumbers] user(s) in AD"
[int]$Step = 1

Write-Host "Find-User :" -ForegroundColor Black -BackgroundColor Yellow
Try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "ActiveDirectory module has been imported." -ForegroundColor Green
    Write-Log -Output $LogFileOK -Message "ActiveDirectory module has been imported."
}
Catch {
    Write-Warning "The ActiveDirectory module failed to load. Install the module and try again."
    Write-Log -Output $LogFileKO -Message "The ActiveDirectory module failed to load. Install the module and try again."
    Pause
    Write-Host "`r"
    Exit
}

If ((Test-Path ".\Logins.txt") -eq $False) {
    Write-Warning "TXT file [Logins.txt] does not exist."
    Write-Log -Output $LogFileKO -Message "TXT file [Logins.txt] does not exist."
}
ElseIf ($LineNumbers -eq 0) {
    Write-Warning "TXT file [Logins.txt] is empty."
    Write-Log -Output $LogFileKO -Message "TXT file [Logins.txt] is empty."
}
Else {
    Write-Host "Launching the research of [$LineNumbers] user(s) in AD." -ForegroundColor Cyan
    Write-Host "`r"
    ForEach ($ADLogin in $Logins) {
        [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
        [string]$CurrentOperation = "Finding AD user : $ADLogin"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
        $Step++
        Start-Sleep -Seconds 1
        Try {
            $User = Get-ADUser -Filter { sAMAccountName -eq $ADLogin }
        }
        Catch {
            [string]$ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
            Write-Host "`r"
            Write-Log -Output $LogFileKO -Message $ErrorMessage
        }
        If ($User -eq $Null) {
            Write-Host "$ADLogin - User does not exist in AD." -ForegroundColor Red
            Write-Log -Output $LogFileKO -Message "$ADLogin - User does not exist in AD."
        }
        Else {
            Write-host "$ADLogin - User found in AD." -ForegroundColor Green
            Write-Log -Output $LogFileOK -Message "$ADLogin - User found in AD."
        }
    }
}

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
If ((Test-Path $LogFileOK) -eq $True) {
    Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFileOK -Leaf) -ForegroundColor Red
}
If ((Test-Path $LogFileKO) -eq $True) {
    Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFileKO -Leaf) -ForegroundColor Red
}
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
