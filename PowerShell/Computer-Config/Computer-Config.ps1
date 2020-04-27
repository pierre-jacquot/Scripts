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
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/25-script-computer-config
#>

Clear-Host

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

[datetime]$StartTime = Get-Date
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = $Workfolder + "\$Date-Computer-Config.log"
[string]$Activity = "Trying to launch the configuration export of the computer/server"
[int]$Step = 1
[int]$TotalStep = 15

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

[string]$BiosStep = "#01 - [BIOS CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $BiosStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $BiosStep
Get-WmiObject "Win32_Bios" | Format-Table Manufacturer, @{Name='ReleaseDate';Expression={$_.ConverttoDateTime($_.ReleaseDate)}}, SMBIOSBIOSVersion, SerialNumber | Out-File -FilePath $LogFile -Append -Force
Write-Host "$BiosStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$ComputerStep = "#02 - [COMPUTER CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ComputerStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $ComputerStep
Get-WmiObject "Win32_ComputerSystem" | Format-Table Name, Manufacturer, Model, Domain, UserName | Out-File -FilePath $LogFile -Append -Force
Write-Host "$ComputerStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$OSStep = "#03 - [OS CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $OSStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $OSStep
Get-WmiObject "Win32_OperatingSystem" | Format-List Manufacturer, Caption, CSDVersion, OSArchitecture, Version, BuildNumber, SystemDrive, WindowsDirectory, SystemDirectory, @{Name='InstallDate';Expression={$_.ConverttoDateTime($_.InstallDate)}}, @{Name='LastBootUpTime';Expression={$_.ConverttoDateTime($_.LastBootUpTime)}}, @{Name='LocalDateTime';Expression={$_.ConverttoDateTime($_.LocalDateTime)}} | Out-File -FilePath $LogFile -Append -Force
Write-Host "$OSStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$CPUStep = "#04 - [CPU CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CPUStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $CPUStep
Get-WmiObject "Win32_Processor" | Format-Table Name, NumberOfCores, NumberOfLogicalProcessors | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_Processor" | Measure-Object -Property LoadPercentage -Average | Format-Table @{Name="Used CPU (%)";Expression={$_.Average}}, @{Name="Free CPU (%)";Expression={"{0:N0}" -f ((100)-($_.Average))}} | Out-File -FilePath $LogFile -Append -Force
Write-Host "$CPUStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$RAMStep = "#05 - [RAM CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $RAMStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $RAMStep
Get-WmiObject "Win32_PhysicalMemory" | Format-Table Manufacturer, Tag, DeviceLocator, Speed, SerialNumber, @{Name="Installed memory (Go)";Expression={$_.Capacity/1024/1024}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_OperatingSystem" | Format-Table @{Name="Total Physical Memory (Go)";Expression={"{0:N2}" -f ($_.TotalVisibleMemorySize/1024/1024)}}, @{Name="Used Physical Memory (Go)";Expression={"{0:N2}" -f (($_.TotalVisibleMemorySize/1024/1024)-($_.FreePhysicalMemory/1024/1024))}}, @{Name="Free Physical Memory (Go)";Expression={"{0:N2}" -f ($_.FreePhysicalMemory/1024/1024)}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_OperatingSystem" | Format-Table @{Name="Used Memory (%)"; Expression={"{0:N0}" -f (((($_.TotalVisibleMemorySize)-($_.FreePhysicalMemory))*100)/($_.TotalVisibleMemorySize))}}, @{Name = "Free Memory (%)";Expression={“{0:N0}” -f  ((($_.FreePhysicalMemory)/($_.TotalVisibleMemorySize))*100)}} | Out-File -FilePath $LogFile -Append -Force
Write-Host "$RAMStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$HDDStep = "#06 - [HDD CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $HDDStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $HDDStep
Get-WmiObject "Win32_LogicalDisk" -Filter "DriveType=3" | Format-Table FileSystem, DeviceID, VolumeName, @{Name="Total Size (Go)";Expression={"{0:N2}" -f ($_.Size/1GB)}}, @{Name="Used Space (Go)";Expression={"{0:N2}" -f (($_.Size/1GB)-($_.FreeSpace/1GB))}}, @{Name="Free Space (Go)";Expression={"{0:N2}" -f ($_.FreeSpace/1GB)}} | Out-File -FilePath $LogFile -Append -Force
Get-WmiObject "Win32_Volume" -Filter "DriveType=3" | Format-Table Label, DriveLetter, @{Name="Capacity (Go)";Expression={“{0:N2}” -f ($_.Capacity/1024/1024/1024)}}, @{Name = "Used Space (Go)";Expression={“{0:N2}” -f  (($_.Capacity/1024/1024/1024)-($_.FreeSpace/1024/1024/1024))}}, @{Name="Free Space (Go)";Expression={“{0:N2}” -f ($_.FreeSpace/1024/1024/1024)}}, @{Name = "Used Space (%)";Expression={“{0:N0}” -f  (((($_.Capacity)-($_.FreeSpace))/($_.Capacity))*100)}}, @{Name = "Free Space (%)";Expression={“{0:N0}” -f  ((($_.FreeSpace)/($_.Capacity))*100)}} | Out-File -FilePath $LogFile -Append -Force
Write-Host "$HDDStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$LanguageStep = "#07 - [REGIONAL & LANGUAGE CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $LanguageStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $LanguageStep
Get-Culture | Format-Table Parent, NativeName | Out-File -FilePath $LogFile -Append -Force
Write-Host "$LanguageStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$TimeZoneStep = "#08 - [TIMEZONE CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $TimeZoneStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $TimeZoneStep
Get-WmiObject "Win32_TimeZone" | Format-Table DayLightName, Description | Out-File -FilePath $LogFile -Append -Force
Write-Host "$TimeZoneStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$ShareStep = "#09 - [SHARE CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ShareStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $ShareStep
Get-WmiObject "Win32_Share" | Format-Table Name, Path, Description | Out-File -FilePath $LogFile -Append -Force
Write-Host "$ShareStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$NetworkStep = "#10 - [NETWORK CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $NetworkStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $NetworkStep
Get-WmiObject "Win32_NetworkAdapterConfiguration" -Filter "IPEnabled=True" | Format-List Description, DHCPServer, DNSDomain, DNSServerSearchOrder, IPAddress, DefaultIPGateway, IPSubnet, MACAddress | Out-File -FilePath $LogFile -Append -Force
Write-Host "$NetworkStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$PrinterStep = "#11 - [PRINTER CONFIGURATION]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $PrinterStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $PrinterStep
Get-WmiObject "Win32_Printer" | Format-Table Name, SystemName, ShareName, DriverName, PortName, Status, Shared, Published | Out-File -FilePath $LogFile -Append -Force
Write-Host "$PrinterStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$ProcessStep = "#12 - [PROCESS LIST]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ProcessStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $ProcessStep
Get-Process | Sort-Object CPU -Descending | Format-Table | Out-File -FilePath $LogFile -Append -Force
Write-Host "$ProcessStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$ServicesStep = "#13 - [SERVICES LIST]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ServicesStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $ServicesStep
Get-WmiObject "Win32_Service" | Sort-Object State, Name | Format-Table Name, ProcessId, StartMode, State, Status, Description | Out-File -FilePath $LogFile -Append -Force
Write-Host "$ServicesStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$ProgramsStep = "#14 - [PROGRAMS LIST]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ProgramsStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $ProgramsStep
Get-WmiObject "Win32_Product" | Sort-Object InstallDate -Descending | Format-Table Name, Version, InstallDate, InstallLocation, Vendor | Out-File -FilePath $LogFile -Append -Force
Write-Host "$ProgramsStep has been exported" -ForegroundColor Green
"-------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append -Force
"`r" | Out-File -FilePath $LogFile -Append -Force

$Step++
[string]$UpdatesStep = "#15 - [WINDOWS UPDATES LIST]"
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $UpdatesStep -PercentComplete ($Step/$TotalStep*100)
Write-Log -Output $LogFile -Message $UpdatesStep
Get-HotFix | Sort-Object InstalledOn -Descending | Format-Table Description, HotFixID, InstalledBy, InstalledOn | Out-File -FilePath $LogFile -Append -Force
Write-Host "$UpdatesStep has been exported" -ForegroundColor Green

[datetime]$EndTime = Get-Date
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
