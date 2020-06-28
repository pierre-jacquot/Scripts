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
    ((Get-Date -UFormat "[%d/%m/%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$LogFile = $Workfolder + "\$Date-Computer-Config.log"
[string]$ExportFile = $Workfolder + "\$Date-Computer-Config.html"
[string]$BiosStep = "#01 - [BIOS INFORMATION]"
[string]$ComputerStep = "#02 - [COMPUTER INFORMATION]"
[string]$OSStep = "#03 - [OPERATING SYSTEM INFORMATION]"
[string]$CPUStep = "#04 - [PROCESSOR INFORMATION]"
[string]$CPUUsageStep = "#05 - [PROCESSOR USAGE]"
[string]$RAMStep = "#06 - [PHYSICAL MEMORY INFORMATION]"
[string]$RAMUsageStep = "#07 - [PHYSICAL MEMORY USAGE]"
[string]$HDDStep = "#08 - [DISK INFORMATION]"
[string]$LanguageStep = "#09 - [REGIONAL & LANGUAGE INFORMATION]"
[string]$TimeZoneStep = "#10 - [TIMEZONE INFORMATION]"
[string]$ShareStep = "#11 - [SHARE INFORMATION]"
[string]$NetworkStep = "#12 - [NETWORK INFORMATION]"
[string]$PrinterStep = "#13 - [PRINTER INFORMATION]"
[string]$ProcessStep = "#14 - [PROCESS INFORMATION]"
[string]$ServicesStep = "#15 - [SERVICES INFORMATION]"
[string]$ProgramsStep = "#16 - [PROGRAMS INFORMATION]"
[string]$Programs32Step = "#17 - [PROGRAMS INFORMATION IN HKLM:\SOFTWARE]"
[string]$Programs64Step = "#18 - [PROGRAMS INFORMATION IN HKLM:\SOFTWARE\Wow6432Node]"
[string]$UpdatesStep = "#19 - [WINDOWS UPDATES INFORMATION]"
[string]$RegKey1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
[string]$RegKey2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
[string]$Activity = "Trying to launch the configuration export of the computer/server"
[int]$Step = 1
[int]$TotalStep = 19
[string]$H1 = "<h1>[$Date] - Computer Information Report on : $Hostname</h1>"

Write-Host "Computer-Config :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the configuration export of the computer/server." -ForegroundColor Cyan
Write-Host "`r"

[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $BiosStep -PercentComplete ($Step/$TotalStep*100)
[string]$BiosInfoHTML = Get-CimInstance -ClassName Win32_BIOS | Select-Object Manufacturer, Name, ReleaseDate, SMBIOSBIOSVersion, SerialNumber | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$BiosStep :</h2>"
Write-Host "$BiosStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$BiosStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ComputerStep -PercentComplete ($Step/$TotalStep*100)
[string]$ComputerInfoHTML = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, Domain, PrimaryOwnerName | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$ComputerStep :</h2>"
Write-Host "$ComputerStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$ComputerStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $OSStep -PercentComplete ($Step/$TotalStep*100)
[string]$OSInfoHTML = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Manufacturer, Caption, CSDVersion, OSArchitecture, Version, BuildNumber, SystemDrive, WindowsDirectory, SystemDirectory, InstallDate, LastBootUpTime, LocalDateTime | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$OSStep :</h2>"
Write-Host "$OSStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$OSStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CPUStep -PercentComplete ($Step/$TotalStep*100)
[string]$CPUInfoHTML1 = Get-CimInstance -ClassName Win32_Processor | Select-Object Manufacturer, Name, Caption, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$CPUStep :</h2>"
Write-Host "$CPUStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$CPUStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CPUUsageStep -PercentComplete ($Step/$TotalStep*100)
[string]$CPUInfoHTML2 = Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object @{Name="Used CPU (%)";Expression={$_.Average}}, @{Name="Free CPU (%)";Expression={"{0:N0}" -f ((100)-($_.Average))}} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$CPUUsageStep :</h2>"
Write-Host "$CPUUsageStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$CPUUsageStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $RAMStep -PercentComplete ($Step/$TotalStep*100)
[array]$RAMInfo1 = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object Tag, DeviceLocator, PartNumber, SerialNumber, @{Name="Installed memory (Go)";Expression={$_.Capacity/1024/1024}}
[int]$RAMNumbers = $RAMInfo1.Count
[string]$RAMInfoHTML1 = $RAMInfo1 | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$RAMStep :</h2><ul><li>Number of memory card(s) : <span class='PostContentBlue'><strong>$RAMNumbers</strong></span></li></ul>"
Write-Host "$RAMStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$RAMStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $RAMUsageStep -PercentComplete ($Step/$TotalStep*100)
[array]$RAMInfo2 = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object @{Name="Total Physical Memory (Go)";Expression={"{0:N2}" -f ($_.TotalVisibleMemorySize/1024/1024)}}, @{Name="Used Physical Memory (Go)";Expression={"{0:N2}" -f (($_.TotalVisibleMemorySize/1024/1024)-($_.FreePhysicalMemory/1024/1024))}}, @{Name="Free Physical Memory (Go)";Expression={"{0:N2}" -f ($_.FreePhysicalMemory/1024/1024)}}, @{Name="Used Memory (%)"; Expression={"{0:N0}" -f (((($_.TotalVisibleMemorySize)-($_.FreePhysicalMemory))*100)/($_.TotalVisibleMemorySize))}}, @{Name = "Free Memory (%)";Expression={“{0:N0}” -f ((($_.FreePhysicalMemory)/($_.TotalVisibleMemorySize))*100)}}
[string]$RAMInfoHTML2 = $RAMInfo2 | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$RAMUsageStep :</h2>"
ForEach ($Result in $RAMInfo2) {
    [int]$ResultFreeMemory = $Result."Free Memory (%)"
    If ($ResultFreeMemory -le 9) {
        $RAMInfoHTML2 = $RAMInfoHTML2 -replace "<td>$ResultFreeMemory</td>","<td class='CriticalStatus'>$ResultFreeMemory</td>"
    }
    If ($ResultFreeMemory -le 19 -and $ResultFreeMemory -ge 10) {
        $RAMInfoHTML2 = $RAMInfoHTML2 -replace "<td>$ResultFreeMemory</td>","<td class='WarningStatus'>$ResultFreeMemory</td>"
    }
}
Write-Host "$RAMUsageStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$RAMUsageStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $HDDStep -PercentComplete ($Step/$TotalStep*100)
[array]$DiskInfo = Get-CimInstance -ClassName Win32_Volume -Filter "DriveType=3" | Sort-Object DriveLetter | Select-Object FileSystem ,Label, DriveLetter, @{Name="Capacity (Go)";Expression={“{0:N2}” -f ($_.Capacity/1024/1024/1024)}}, @{Name = "Used Space (Go)";Expression={“{0:N2}” -f (($_.Capacity/1024/1024/1024)-($_.FreeSpace/1024/1024/1024))}}, @{Name="Free Space (Go)";Expression={“{0:N2}” -f ($_.FreeSpace/1024/1024/1024)}}, @{Name = "Used Space (%)";Expression={“{0:N0}” -f (((($_.Capacity)-($_.FreeSpace))/($_.Capacity))*100)}}, @{Name = "Free Space (%)";Expression={“{0:N0}” -f ((($_.FreeSpace)/($_.Capacity))*100)}}
[int]$DiskNumbers = $DiskInfo.Count
[string]$DiskInfoHTML = $DiskInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$HDDStep :</h2><ul><li>Number of drive(s) : <span class='PostContentBlue'><strong>$DiskNumbers</strong></span></li></ul>"
ForEach ($Result in $DiskInfo) {
    [int]$ResultFreeSpace = $Result."Free Space (%)"
    If ($ResultFreeSpace -le 9) {
        $DiskInfoHTML = $DiskInfoHTML -replace "<td>$ResultFreeSpace</td>","<td class='CriticalStatus'>$ResultFreeSpace</td>"
    }
    If ($ResultFreeSpace -le 19 -and $ResultFreeSpace -ge 10) {
        $DiskInfoHTML = $DiskInfoHTML -replace "<td>$ResultFreeSpace</td>","<td class='WarningStatus'>$ResultFreeSpace</td>"
    }
}
Write-Host "$HDDStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$HDDStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $LanguageStep -PercentComplete ($Step/$TotalStep*100)
[string]$LanguageInfoHTML = Get-Culture | Select-Object LCID, KeyboardLayoutId, Name, NativeName | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$LanguageStep :</h2>"
Write-Host "$LanguageStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$LanguageStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $TimeZoneStep -PercentComplete ($Step/$TotalStep*100)
[string]$TimeZoneInfoHTML = Get-CimInstance -ClassName Win32_TimeZone | Select-Object DayLightName, Caption | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$TimeZoneStep :</h2>"
Write-Host "$TimeZoneStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$TimeZoneStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ShareStep -PercentComplete ($Step/$TotalStep*100)
[array]$ShareInfo = Get-CimInstance -ClassName Win32_Share | Select-Object Name, Path, Description
[int]$ShareNumbers = $ShareInfo.Count
[string]$ShareInfoHTML = $ShareInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$ShareStep :</h2><ul><li>Number of share(s) : <span class='PostContentBlue'><strong>$ShareNumbers</strong></span></li></ul>"
Write-Host "$ShareStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$ShareStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $NetworkStep -PercentComplete ($Step/$TotalStep*100)
[array]$NetworkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" | Select-Object Description, DHCPServer, DNSDomain, @{Name='DNSServerSearchOrder';Expression={($_.DNSServerSearchOrder -like '*.*.*.*') -join ','}}, @{Name='IPv4';Expression={($_.IPAddress -like '*.*.*.*') -join ','}}, @{Name='Gateway';Expression={($_.DefaultIPGateway -like '*.*.*.*') -join ','}}, @{Name='Mask';Expression={($_.IPSubnet -like '*.*.*.*') -join ','}}, MACAddress
[int]$NetworkNumbers = $NetworkInfo.Count
[string]$NetworkInfoHTML = $NetworkInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$NetworkStep :</h2><ul><li>Number of network adapter(s) with IP enabled : <span class='PostContentBlue'><strong>$NetworkNumbers</strong></span></li></ul>"
Write-Host "$NetworkStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$NetworkStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $PrinterStep -PercentComplete ($Step/$TotalStep*100)
[array]$PrinterInfo = Get-CimInstance -ClassName Win32_Printer | Select-Object Name, SystemName, ShareName, DriverName, PortName, Status, Shared, Published
[int]$PrinterNumbers = $PrinterInfo.Count
[string]$PrinterInfoHTML = $PrinterInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$PrinterStep :</h2><ul><li>Number of printer(s) : <span class='PostContentBlue'><strong>$PrinterNumbers</strong></span></li></ul>"
Write-Host "$PrinterStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$PrinterStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ProcessStep -PercentComplete ($Step/$TotalStep*100)
[array]$ProcessInfo = Get-Process | Sort-Object CPU -Descending | Select-Object Handles, CPU, ID, SI, ProcessName, StartTime
[int]$ProcessNumbers = $ProcessInfo.Count
[string]$ProcessInfoHTML = $ProcessInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$ProcessStep :</h2><ul><li>Number of processes : <span class='PostContentBlue'><strong>$ProcessNumbers</strong></span></li></ul>"
Write-Host "$ProcessStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$ProcessStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ServicesStep -PercentComplete ($Step/$TotalStep*100)
[array]$ServicesInfo = Get-CimInstance -ClassName Win32_Service | Sort-Object State, Name | Select-Object Name, DisplayName, ProcessId, StartMode, State
[int]$ServicesNumbers = $ServicesInfo.Count
[array]$ServicesRunningInfo = $ServicesInfo | Where-Object {$_.State -eq "Running"}
[int]$ServicesRunningNumbers = $ServicesRunningInfo.Count
[int]$ServicesStoppedNumbers = $ServicesNumbers - $ServicesRunningNumbers
[string]$ServicesInfoHTML = $ServicesInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$ServicesStep :</h2><ul><li>Total number of services : <span class='PostContentBlue'><strong>$ServicesNumbers</strong></span></li><li>Number of running services : <span class='PostContentBlue'><strong>$ServicesRunningNumbers</strong></span></li><li>Number of stopped services : <span class='PostContentBlue'><strong>$ServicesStoppedNumbers</strong></span></li></ul>"
$ServicesInfoHTML = $ServicesInfoHTML -replace '<td>Running</td>','<td class="SuccessStatus">Running</td>'
$ServicesInfoHTML = $ServicesInfoHTML -replace '<td>Stopped</td>','<td class="CriticalStatus">Stopped</td>'
Write-Host "$ServicesStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$ServicesStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $ProgramsStep -PercentComplete ($Step/$TotalStep*100)
[array]$ProgramsInfo = Get-CimInstance -ClassName Win32_Product | Sort-Object InstallDate -Descending | Select-Object Name, Version, @{Name="InstallDate"; Expression={([datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)).toshortdatestring()}}, InstallLocation, Vendor
[int]$ProgramsNumbers = $ProgramsInfo.Count
[string]$ProgramsInfoHTML = $ProgramsInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$ProgramsStep :</h2><ul><li>Number of programs : <span class='PostContentBlue'><strong>$ProgramsNumbers</strong></span></li></ul>"
Write-Host "$ProgramsStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$ProgramsStep has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $Programs32Step -PercentComplete ($Step/$TotalStep*100)
[array]$Programs32Info = Get-ItemProperty $RegKey1 | Where-Object {$_.DisplayName} | Sort-Object -Property InstallDate -Descending | Select-Object DisplayName, DisplayVersion, @{Name="InstallDate"; Expression={([datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)).toshortdatestring()}}, InstallLocation, Publisher
[int]$Programs32Numbers = $Programs32Info.Count
[string]$Programs32InfoHTML = $Programs32Info | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$Programs32Step :</h2><ul><li>Number of programs (32 bits) : <span class='PostContentBlue'><strong>$Programs32Numbers</strong></span></li></ul>"
Write-Host "$Programs32Step has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$Programs32Step has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $Programs64Step -PercentComplete ($Step/$TotalStep*100)
[array]$Programs64Info = Get-ItemProperty $RegKey2 | Where-Object {$_.DisplayName} | Sort-Object -Property InstallDate -Descending | Select-Object DisplayName, DisplayVersion, @{Name="InstallDate"; Expression={([datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)).toshortdatestring()}}, InstallLocation, Publisher
[int]$Programs64Numbers = $Programs64Info.Count
[string]$Programs64InfoHTML = $Programs64Info | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$Programs64Step :</h2><ul><li>Number of programs (64 bits) : <span class='PostContentBlue'><strong>$Programs64Numbers</strong></span></li></ul>"
Write-Host "$Programs64Step has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$Programs64Step has been exported."

$Step++
[string]$Status = "Processing [$Step] of [$TotalStep] - $(([math]::Round((($Step)/$TotalStep*100),0)))% completed"
Write-Progress -Activity $Activity -Status $Status -CurrentOperation $UpdatesStep -PercentComplete ($Step/$TotalStep*100)
[array]$UpdatesInfo = Get-CimInstance -ClassName Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object Description, HotFixID, InstalledBy, @{Name="InstallDate"; Expression={$_.InstalledOn.toshortdatestring()}}
[int]$UpdatesNumbers = $UpdatesInfo.Count
[string]$UpdatesInfoHTML = $UpdatesInfo | ConvertTo-Html -As Table -Fragment -PreContent "<h2>$UpdatesStep :</h2><ul><li>Number of Windows update(s) : <span class='PostContentBlue'><strong>$UpdatesNumbers</strong></span></li></ul>"
Write-Host "$UpdatesStep has been exported." -ForegroundColor Green
Write-Log -Output $LogFile -Message "$UpdatesStep has been exported."
"`r" | Out-File -FilePath $LogFile -Append -Force

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

[string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>By : <span class='PostContentBlue'>$Login</span><br/>Path : <span class='PostContentBlue'>$Workfolder</span><br/>Log file : <span class='PostContentBlue'>$(Split-Path $LogFile -Leaf)</span><br/>Export file : <span class='PostContentBlue'>$(Split-Path $ExportFile -Leaf)</span><br/>Start time : <span class='PostContentBlue'>$StartTime</span><br/>End time : <span class='PostContentBlue'>$EndTime</span><br/>Duration : <span class='PostContentBlue'>$Duration</span> seconds</p>"
[string]$Report = ConvertTo-Html -Body "$H1 $BiosInfoHTML $ComputerInfoHTML $OSInfoHTML $CPUInfoHTML1 $CPUInfoHTML2 $RAMInfoHTML1 $RAMInfoHTML2 $DiskInfoHTML $LanguageInfoHTML $TimeZoneInfoHTML $ShareInfoHTML $NetworkInfoHTML $PrinterInfoHTML $ProcessInfoHTML $ServicesInfoHTML $ProgramsInfoHTML $Programs32InfoHTML $Programs64InfoHTML $UpdatesInfoHTML" -CssUri ".\Style.css" -Title "[$Date] - Computer Information Report on : $Hostname" -PostContent $PostContent
$Report | Out-File -FilePath $ExportFile -Encoding utf8

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFile -Leaf) -ForegroundColor Red
Write-Host "Export file : " -NoNewline; Write-Host (Split-Path $ExportFile -Leaf) -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
