<#
.SYNOPSIS
    Detailed computer/server config information.
.DESCRIPTION
    Export the detailed configuration of a computer/server.
.NOTES
    File name : Computer-Config.ps1
    Author : Pierre JACQUOT
    Date : 10/11/2015
    Version : 1.0
.LINK
    Website : http://pierro.jacquot.free.fr
    Reference : http://pierro.jacquot.free.fr/index.php/scripts/25-script-computer-config
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
$LogFile = $Workfolder + "\$Date-Computer-Config.log"

Write-Log -Output $LogFile -Message "Creation of the log file :"
Write-Log -Output $LogFile -Message "- Path : $Workfolder"
Write-Log -Output $LogFile -Message "- File name : $Date-Computer-Config.log"
Write-Log -Output $LogFile -Message "Export the detailed configuration with these informations :"
Write-Log -Output $LogFile -Message "###########################################"
Write-Log -Output $LogFile -Message "- #01 - [BIOS CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #02 - [COMPUTER CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #03 - [OS CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #04 - [CPU CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #05 - [RAM CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #06 - [HDD CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #07 - [REGIONAL & LANGUAGE CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #08 - [TIMEZONE CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #09 - [SHARE CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #10 - [NETWORK CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #11 - [PRINTER CONFIGURATION]"
Write-Log -Output $LogFile -Message "- #12 - [PROCESS LIST]"
Write-Log -Output $LogFile -Message "- #13 - [SERVICES LIST]"
Write-Log -Output $LogFile -Message "- #14 - [PROGRAMS LIST]"
Write-Log -Output $LogFile -Message "- #15 - [WINDOWS UPDATES LIST]"
Write-Log -Output $LogFile -Message "###########################################"
"`r" | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "Computer-Config :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the configuration export of the computer/server." -ForegroundColor Cyan
Write-Host "`r"

Write-Host "#01 - [BIOS CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#01 - [BIOS CONFIGURATION]"
Get-WmiObject "Win32_Bios" | Format-List Manufacturer, @{Name='ReleaseDate';Expression={$_.ConverttoDateTime($_.ReleaseDate)}}, SMBIOSBIOSVersion, SerialNumber | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#02 - [COMPUTER CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#02 - [COMPUTER CONFIGURATION]"
Get-WmiObject "Win32_ComputerSystem" | Format-List Name, Manufacturer, Model, Domain, UserName | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#03 - [OS CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#03 - [OS CONFIGURATION]"
Get-WmiObject "Win32_OperatingSystem" | Format-List Manufacturer, Caption, CSDVersion, OSArchitecture, Version, BuildNumber, SystemDrive, WindowsDirectory, SystemDirectory, @{Name='InstallDate';Expression={$_.ConverttoDateTime($_.InstallDate)}}, @{Name='LastBootUpTime';Expression={$_.ConverttoDateTime($_.LastBootUpTime)}}, @{Name='LocalDateTime';Expression={$_.ConverttoDateTime($_.LocalDateTime)}} | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#04 - [CPU CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#04 - [CPU CONFIGURATION]"
Get-WmiObject "Win32_Processor" | Format-List Name, NumberOfCores, NumberOfLogicalProcessors | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_Processor" | Measure-Object -Property LoadPercentage -Average | Format-List @{Name="Used CPU (%)";Expression={$_.Average}}, @{Name="Free CPU (%)";Expression={"{0:N0}" -f ((100)-($_.Average))}} | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#05 - [RAM CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#05 - [RAM CONFIGURATION]"
Get-WmiObject "Win32_PhysicalMemory" | Format-List Manufacturer, Tag, DeviceLocator, Speed, SerialNumber, @{Name="Installed memory (Go)";Expression={$_.Capacity/1024/1024}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_OperatingSystem" | Format-List @{Name="Total Physical Memory (Go)";Expression={"{0:N2}" -f ($_.TotalVisibleMemorySize/1024/1024)}}, @{Name="Used Physical Memory (Go)";Expression={"{0:N2}" -f (($_.TotalVisibleMemorySize/1024/1024)-($_.FreePhysicalMemory/1024/1024))}}, @{Name="Free Physical Memory (Go)";Expression={"{0:N2}" -f ($_.FreePhysicalMemory/1024/1024)}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_OperatingSystem" | Format-List @{Name="Used Memory (%)"; Expression={"{0:N0}" -f (((($_.TotalVisibleMemorySize)-($_.FreePhysicalMemory))*100)/($_.TotalVisibleMemorySize))}}, @{Name = "Free Memory (%)";Expression={“{0:N0}” -f  ((($_.FreePhysicalMemory)/($_.TotalVisibleMemorySize))*100)}} | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#06 - [HDD CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#06 - [HDD CONFIGURATION]"
Get-WmiObject "Win32_LogicalDisk" -Filter "DriveType=3" | Format-List FileSystem, DeviceID, VolumeName, @{Name="Total Size (Go)";Expression={"{0:N2}" -f ($_.Size/1GB)}}, @{Name="Used Space (Go)";Expression={"{0:N2}" -f (($_.Size/1GB)-($_.FreeSpace/1GB))}}, @{Name="Free Space (Go)";Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_Volume" -Filter "DriveType=3" | Format-List Label, DriveLetter, @{Name="Capacity (Go)";Expression={“{0:N2}” -f ($_.Capacity/1024/1024/1024)}}, @{Name = "Used Space (Go)";Expression={“{0:N2}” -f  (($_.Capacity/1024/1024/1024)-($_.FreeSpace/1024/1024/1024))}}, @{Name="Free Space (Go)";Expression={“{0:N2}” -f ($_.FreeSpace/1024/1024/1024)}}, @{Name = "Used Space (%)";Expression={“{0:N0}” -f  (((($_.Capacity)-($_.FreeSpace))/($_.Capacity))*100)}}, @{Name = "Free Space (%)";Expression={“{0:N0}” -f  ((($_.FreeSpace)/($_.Capacity))*100)}} | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#07 - [REGIONAL & LANGUAGE CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#07 - [REGIONAL & LANGUAGE CONFIGURATION]"
Get-Culture | Format-List Parent, NativeName | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#08 - [TIMEZONE CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#08 - [TIMEZONE CONFIGURATION]"
Get-WmiObject "Win32_TimeZone" | Format-List DayLightName, Description | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#09 - [SHARE CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#09 - [SHARE CONFIGURATION]"
Get-WmiObject "Win32_Share" | Format-List Name, Path, Description | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#10 - [NETWORK CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#10 - [NETWORK CONFIGURATION]"
Get-WmiObject "Win32_NetworkAdapterConfiguration" -Filter "IPEnabled=True" | Format-List Description, DHCPServer, DNSDomain, DNSServerSearchOrder, IPAddress, DefaultIPGateway, IPSubnet, MACAddress | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#11 - [PRINTER CONFIGURATION] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#11 - [PRINTER CONFIGURATION]"
Get-WmiObject "Win32_Printer" -filter "Shared=True" | Select-Object Name, SystemName, ShareName, Comment, DriverName, PortName, Status, Shared, Published | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#12 - [PROCESS LIST] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#12 - [PROCESS LIST]"
Get-Process | Sort-Object CPU -Descending | Format-Table | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#13 - [SERVICES LIST] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#13 - [SERVICES LIST]"
Get-WmiObject "Win32_Service" | Sort-Object State, Name | Format-Table Name, ProcessId, StartMode, State, Status, Description | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#14 - [PROGRAMS LIST] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#14 - [PROGRAMS LIST]"
Get-WmiObject "Win32_Product" | Sort-Object InstallDate -Descending | Format-Table Name, Version, HelpLink, InstallDate, InstallLocation, Vendor | Out-File -FilePath $LogFile -Append -Force
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

Write-Host "#15 - [WINDOWS UPDATES LIST] has been exported" -ForegroundColor Green
Write-Log -Output $LogFile -Message "#15 - [WINDOWS UPDATES LIST]"
Get-HotFix | Sort-Object HotFixID | Format-Table Description, HotFixID, InstalledBy, InstalledOn | Out-File -FilePath $LogFile -Append -Force

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
