<#
.SYNOPSIS
    Ping multiple servers
.DESCRIPTION
    Check if servers are reachable with event logs creation and export results
.NOTES
    File name : Ping-Server.ps1
    Author : Pierre JACQUOT
    Date : 27/10/2015
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/22-script-ping-server
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
[string]$TXTFile = $Workfolder + "\Servers.txt"
[string]$CSVFile = $Workfolder + "\$Date-Servers-Export.csv"
[string]$ReportFile = $Workfolder + "\$Date-Servers-Report.html"
[string]$LogFileOK = $Workfolder + "\$Date-Ping-Server_Success.log"
[string]$LogFileKO = $Workfolder + "\$Date-Ping-Server_Warning.log"
[array]$Servers = Get-Content -Path ".\Servers.txt" -ErrorAction SilentlyContinue
[int]$LineNumbers = $Servers.Count
[System.Collections.ArrayList]$ServerList = @()
[string]$Activity = "Trying to ping [$LineNumbers] server(s)"
[int]$Step = 1
[string]$Title = "[$Date] - Ping server(s) report on : $Hostname"

Write-Host "Ping-Server :" -ForegroundColor Black -BackgroundColor Yellow
If ((Test-Path ".\Servers.txt") -eq $False) {
    Write-Warning "TXT file [Servers.txt] does not exist."
    Write-Log -Output $LogFileKO -Message "TXT file [Servers.txt] does not exist."
}
ElseIf ($LineNumbers -eq 0) {
    Write-Warning "TXT file [Servers.txt] is empty."
    Write-Log -Output $LogFileKO -Message "TXT file [Servers.txt] is empty."
}
Else {
    Write-Host "Launching the ping command on [$LineNumbers] server(s)." -ForegroundColor Cyan
    Write-Host "`r"
    ForEach ($Server in $Servers) {
        [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
        [string]$CurrentOperation = "Ping : $Server"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
        $Step++
        If (Test-Connection -ComputerName $Server -Count 2 -Quiet) {
            [string]$ServerStatus = "OK"
            Write-Host "$Server is alive and pinging." -ForegroundColor Green
            Write-Log -Output $LogFileOK -Message "$Server is alive and pinging."
        }
        Else {
            [string]$ServerStatus = "KO"
            Write-Warning "$Server seems dead not pinging."
            Write-Log -Output $LogFileKO -Message "$Server seems dead not pinging."
        }
        $ParamList = [PSCustomObject]@{
            "Hostname / IP" = $Server
            Status = $ServerStatus
        }
        $ServerList.Add($ParamList) | Out-Null
    }
}

$ServerList | Export-Csv -Path $CSVFile -NoTypeInformation -Delimiter ";" -Encoding UTF8

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

[string]$PreContent = "<h1>$Title</h1>
<h2>Number of server(s) : <span class='PostContentBlue'>$LineNumbers</span></h2>"
[string]$SuccessLogFile = "Success log file : <span class='PostContentBlue'>$(Split-Path $LogFileOK -Leaf)</span><br/>"
[string]$WarningLogFile = "Warning log file : <span class='PostContentBlue'>$(Split-Path $LogFileKO -Leaf)</span><br/>"
[string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
By : <span class='PostContentBlue'>$Login</span><br/>
Path : <span class='PostContentBlue'>$Workfolder</span><br/>
TXT file : <span class='PostContentBlue'>$(Split-Path $TXTFile -Leaf)</span><br/>
CSV file : <span class='PostContentBlue'>$(Split-Path $CSVFile -Leaf)</span><br/>
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

[string]$Report = $ServerList | ConvertTo-Html -As Table -CssUri ".\Style.css" -Title $Title -PreContent $PreContent -PostContent $PostContent
$Report = $Report -replace '<td>OK</td>','<td class="SuccessStatus">OK</td>'
$Report = $Report -replace '<td>KO</td>','<td class="CriticalStatus">KO</td>'
$Report | Out-File -FilePath $ReportFile -Encoding utf8

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "TXT file : " -NoNewline; Write-Host (Split-Path $TXTFile -Leaf) -ForegroundColor Red
Write-Host "CSV file : " -NoNewline; Write-Host (Split-Path $CSVFile -Leaf) -ForegroundColor Red
Write-Host "Report file : " -NoNewline; Write-Host (Split-Path $ReportFile -Leaf) -ForegroundColor Red
If ((Test-Path $LogFileOK) -eq $True) {
    Write-Host "Success log file : " -NoNewline; Write-Host (Split-Path $LogFileOK -Leaf) -ForegroundColor Red
}
If ((Test-Path $LogFileKO) -eq $True) {
    Write-Host "Warning log file : " -NoNewline; Write-Host (Split-Path $LogFileKO -Leaf) -ForegroundColor Red
}
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " second(s)"
Write-Host "`r"
