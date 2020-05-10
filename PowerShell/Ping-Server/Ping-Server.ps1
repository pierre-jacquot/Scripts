<#
.SYNOPSIS
    Ping multiple servers
.DESCRIPTION
    Check if servers are reachable with event logs creation
.NOTES
    File name : Ping-Server.ps1
    Author : Pierre JACQUOT
    Date : 27/10/2015
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/22-script-ping-server
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
[string]$LogFileOK = $Workfolder + "\$Date-Ping-Server_Success.log"
[string]$LogFileKO = $Workfolder + "\$Date-Ping-Server_Warning.log"
[array]$Servers = Get-Content -Path ".\Servers.txt"
[int]$LineNumbers = $Servers.Count
[string]$Activity = "Trying to ping [$LineNumbers] server(s)"
[int]$Step = 1

Write-Host "Ping-Server :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the ping command on [$LineNumbers] server(s)." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Server in $Servers) {
    [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
    [string]$CurrentOperation = "Ping : $Server"
    Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
    $Step++
    If (Test-Connection -ComputerName $Server -Count 2 -Quiet) {
        Write-Host "$Server is alive and Pinging " -ForegroundColor Green
        Write-Log -Output $LogFileOK -Message "$Server is alive and Pinging"
    }
    Else {
        Write-Warning "$Server seems dead not pinging"
        Write-Log -Output $LogFileKO -Message "$Server seems dead not pinging"
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
