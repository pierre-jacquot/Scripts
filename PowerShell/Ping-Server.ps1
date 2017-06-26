<#
.SYNOPSIS
	Ping multiple servers
.DESCRIPTION
	Check if servers are reachable with event logs creation
.NOTES
	File name : MCN.ps1
	Author : Pierre JACQUOT
	Date : 27/10/2015
	Version : 1.0
.LINK
	http://pierro.jacquot.free.fr
#>

cls

Function Write-Log([string]$Output, [string]$Message) {
	Write-Verbose $Message
	((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

$Stopwatch = [system.diagnostics.stopwatch]::startNew()
$Hostname = hostname
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFileOK = $Workfolder + "\$Date-MCN_Sucess.log"
$LogFileKO = $Workfolder + "\$Date-MCN_Warning.log"
$Servers = (Get-Content -Path ".\Servers.txt")
$LineNumbers = $Servers.Count

Write-Host "Ping-Server :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the ping command on [$LineNumbers] server(s)." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Server in $Servers) {
    If (Test-Connection -ComputerName $Server -Count 2 -Quiet) {
        write-Host "$Server is alive and Pinging " -ForegroundColor Green
        Write-Log -Output $LogFileOK -Message "$Server is alive and Pinging"
    }
    Else {
        Write-Warning "$Server seems dead not pinging"
        Write-Log -Output $LogFileKO -Message "$Server seems dead not pinging"
    }
}

$Stopwatch.stop()

Write-Host "`r"
Write-Host "Script launched from : " -nonewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "Path : " -nonewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Duration : " -nonewline; Write-Host $Stopwatch.Elapsed.Seconds -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
