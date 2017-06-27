<#
.SYNOPSIS
	DNS records creation
.DESCRIPTION
	Create multiple DNS records with associated PTR
.NOTES
	File name : Add-DNS.ps1
	Author : Pierre JACQUOT
	Date : 07/05/2017
	Version : 1.0
.LINKS
	Website : http://pierro.jacquot.free.fr
    Reference : http://pierro.jacquot.free.fr/index.php/scripts/31-script-add-dns
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
$LogFile = $Workfolder + "\$Date-Add-DNS.log"
$Records = Import-Csv -Path ".\DNS-Records.csv"
$LineNumbers = $Records.Count

Write-Host "Add-DNS :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the creation of [$LineNumbers] DNS record(s)." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Record in $Records) {
    $RecordName = $Record.DNSName
    $RecordType = $Record.DNSType
    $RecordIP = $Record.DNSIP
    $RecordZone = $Record.DNSZone
    $RecordServer = $Record.DNSServer

    $cmdDelete = "DNSCmd $RecordServer /RecordDelete $RecordZone $RecordName $RecordType $RecordIP /f"
    Write-Host "Running the following command : $cmdDelete" -ForegroundColor Yellow
    Write-Log -Output $LogFile -Message "[$RecordName - $RecordType - $RecordIP - $RecordZone] has been deleted"
    Invoke-Expression $cmdDelete

    $cmdAdd = "DNSCmd $RecordServer /RecordAdd $RecordZone $RecordName /CreatePTR $RecordType $RecordIP"
    Write-Host "Running the following command : $cmdAdd" -ForegroundColor Green
    Write-Log -Output $LogFile -Message "[$RecordName - $RecordType - $RecordIP - $RecordZone] has been added"
    Invoke-Expression $cmdAdd
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
