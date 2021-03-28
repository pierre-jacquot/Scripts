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
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/26-script-find-user
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
[string]$TXTFile = $Workfolder + "\Logins.txt"
[string]$ReportFile = $Workfolder + "\$Date-Users-Report.html"
[string]$LogFileOK = $Workfolder + "\$Date-Users_OK.log"
[string]$LogFileKO = $Workfolder + "\$Date-Users_KO.log"
[array]$Logins = Get-Content -Path ".\Logins.txt" -ErrorAction SilentlyContinue
[int]$LineNumbers = $Logins.Count
[System.Collections.ArrayList]$UserList = @()
[string]$Activity = "Trying to launch the research of [$LineNumbers] user(s) in AD"
[int]$Step = 1
[string]$Title = "[$Date] - AD user(s) report on : $Hostname"

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
            [string]$UserExist = "KO"
            Write-Host "$ADLogin - User does not exist in AD." -ForegroundColor Red
            Write-Log -Output $LogFileKO -Message "$ADLogin - User does not exist in AD."
        }
        Else {
            $UserExist = "OK"
            Write-host "$ADLogin - User found in AD." -ForegroundColor Green
            Write-Log -Output $LogFileOK -Message "$ADLogin - User found in AD."
        }
        $ParamList = [PSCustomObject]@{
            sAMAccountName = $ADLogin
            Status = $UserExist
        }
        $UserList.Add($ParamList) | Out-Null
    }
}

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

[string]$PreContent = "<h1>$Title</h1>
<h2>Number of AD user(s) : <span class='PostContentBlue'>$LineNumbers</span></h2>"
[string]$SuccessLogFile = "Success log file : <span class='PostContentBlue'>$(Split-Path $LogFileOK -Leaf)</span><br/>"
[string]$WarningLogFile = "Warning log file : <span class='PostContentBlue'>$(Split-Path $LogFileKO -Leaf)</span><br/>"
[string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
By : <span class='PostContentBlue'>$Login</span><br/>
Path : <span class='PostContentBlue'>$Workfolder</span><br/>
TXT file : <span class='PostContentBlue'>$(Split-Path $TXTFile -Leaf)</span><br/>
Report file : <span class='PostContentBlue'>$(Split-Path $ReportFile -Leaf)</span><br/>
$(If ((Test-Path $LogFileOK) -eq $True) { 
    $SuccessLogFile
})
$(If ((Test-Path $LogFileKO) -eq $True) { 
    $WarningLogFile
})
Start time : <span class='PostContentBlue'>$StartTime</span><br/>
End time : <span class='PostContentBlue'>$EndTime</span><br/>
Duration : <span class='PostContentBlue'>$Duration</span> second(s)</p>"

[string]$Report = $UserList | ConvertTo-Html -As Table -CssUri ".\Style.css" -Title $Title -PreContent $PreContent -PostContent $PostContent
$Report = $Report -replace '<td>OK</td>','<td class="SuccessStatus">OK</td>'
$Report = $Report -replace '<td>KO</td>','<td class="CriticalStatus">KO</td>'
$Report | Out-File -FilePath $ReportFile -Encoding utf8

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "TXT file : " -NoNewline; Write-Host (Split-Path $TXTFile -Leaf) -ForegroundColor Red
Write-Host "Report file : " -NoNewline; Write-Host (Split-Path $ReportFile -Leaf) -ForegroundColor Red
If ((Test-Path $LogFileOK) -eq $True) {
    Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFileOK -Leaf) -ForegroundColor Red
}
If ((Test-Path $LogFileKO) -eq $True) {
    Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFileKO -Leaf) -ForegroundColor Red
}
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " second(s)"
Write-Host "`r"
