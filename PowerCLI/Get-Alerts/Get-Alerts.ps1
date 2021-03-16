<#
.SYNOPSIS
    Retrieves alerts on your VMware vCenter Server.
.DESCRIPTION
    Retrieves and send by e-mail all alerts on your VMware vCenter Server.
.NOTES
    File name : Get-Alerts.ps1
    Author : Pierre JACQUOT
    Date : 30/05/2016
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/41-script-get-alerts
#>

Clear-Host

# List of variables
$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$CSVFile = ".\$Date-Alerts-Export.csv"
[string]$ReportFile = ".\$Date-Alerts-Report.html"
[string]$vCenter = "vCenterServerName"
[string]$Table = $Null
[System.Collections.ArrayList]$AlertList = @()

Write-Host "Get-Alerts :" -ForegroundColor Black -BackgroundColor Yellow

# Trying to connect to the VMware vCenter Server
Try {
	$Connexion = Connect-VIServer -Server $vCenter
    Write-Host "Connected on the VMware vCenter Server : $Connexion" -ForegroundColor Green
}
Catch {
	Write-Host "[ERROR] : Unable to connect on the VMware vCenter Server" -ForegroundColor Red
	Exit
}

# Retrieves and count alert(s) on the VMware vCenter Server
$rootFolder = Get-Folder -NoRecursion
$Alerts = ($rootFolder.ExtensionData.TriggeredAlarmState) | Sort-Object Time -Descending | Select-Object *
[int]$AlertsNumber = $Alerts.Count

If ($AlertsNumber -ge 1) {
    # Send-MailMessage parameters
    [string]$MailFrom = "vCenter[at]mail.fr"
    [string]$MailTo = @('UserName[at]mail.fr')
    [string]$MailCc = @('UserName[at]mail.fr')
    [string]$MailSubject = "[$Date] - [VMware] - Alert(s) daily report on : $vCenter"
    [string]$MailSMTPServer = "SMTPServerName"

    [string]$MailBody = '<html>'
    $MailBody += '<head>'
    $MailBody += "<title>$MailSubject</title>"
    $MailBody += '<style type="text/css">'
    $MailBody += 'h1 { font-family: Arial; color: #e68a00; font-size: 28px; }'
    $MailBody += 'h2 { font-family: Arial; color: #000000; font-size: 16px; }'
    $MailBody += '.customTable { border: 1px solid #000000; }'
    $MailBody += '.customTable table { border-collapse: collapse; border-spacing: 0; margin: 0px; padding: 0px; }'
    $MailBody += '.customTable th { background-color: #d3e5d4; font-size: 14px; font-family: Arial; font-weight: bold; }'
    $MailBody += '.customTable td { font-size: 13px; font-family: Arial; }'
    $MailBody += '.customTable tr:nth-child(even) { background-color: #f0f0f2; }'
    $MailBody += '.customTable tr:hover { background-color: #ddd; }'
    $MailBody += '.CriticalStatus { background-color: #ff0000; font-weight: bold; color: #ffffff; }'
    $MailBody += '.WarningStatus { background-color: #ffa500; font-weight: bold; color: #ffffff; }'
    $MailBody += '#PostInfo { font-family: Arial; font-size: 11px; font-style: italic; }'
    $MailBody += 'span.Info { color: #000099; }'
    $MailBody += '</style>'
    $MailBody += '</head>'

    $MailBody += '<body>'
    $MailBody += "<h1>$MailSubject</h1>"
    $MailBody += "<h2>Number of alert(s) : <span class='Info'>$AlertsNumber</span></h2>"

    # Prepare Table
    $Table += '<table class="customTable">'
    $Table += "<tr><th>Time</th><th>EntityType</th><th>Entity</th><th>Alarm</th><th>Acknowledged</th><th>AckBy</th><th>AckTime</th><th>Status</th></tr>"

    Foreach ($Alert in $Alerts) {
        [string]$AlarmAlarm = (Get-View $Alert.Alarm).Info.Name
        [string]$AlarmEntity = (Get-View $Alert.Entity).Name
        [string]$AlarmEntityType = (Get-View $Alert.Entity).GetType().Name
        $AlarmTime = $Alert.Time
        [string]$AlarmAcknowledged = $Alert.Acknowledged
        If ($AlarmAcknowledged -eq "True" ) {
            $AlarmAcknowledged = "Yes"
        }
        Else {
            $AlarmAcknowledged = "No"
        }
        [string]$AlarmAckBy = $Alert.AcknowledgedByUser
        $AlarmAckTime = $Alert.AcknowledgedTime
        [string]$AlarmStatus = $Alert.OverallStatus
        If ($AlarmStatus -eq "red" ) {
            $AlarmStatus = "Alert"
        }
        Else {
            $AlarmStatus = "Warning"
        }

        $Table += "<tr><td>$AlarmTime</td><td>$AlarmEntityType</td><td>$AlarmEntity</td><td>$AlarmAlarm</td><td>$AlarmAcknowledged</td><td>$AlarmAckBy</td><td>$AlarmAckTime</td><td>$AlarmStatus</td></tr>"

        $ServerObject = [PSCustomObject]@{
            Time = $AlarmTime
            EntityTime = $AlarmEntityType
            Entity = $AlarmEntity
            Alarm = $AlarmAlarm
            Acknowledged = $AlarmAcknowledged
            AckBy = $AlarmAckBy
            AckTime = $AlarmAckTime
            Status = $AlarmStatus
        }
        $AlertList.Add($ServerObject) | Out-Null
    }

    $Table += "</table>"

    $AlertList | Export-Csv -Path $CSVFile -NoTypeInformation -Delimiter ";" -Encoding UTF8
    $EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    [decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

    [string]$Info = "<p id='PostInfo'>Script launched from : <span class='Info'>$Hostname</span><br/>
    By : <span class='Info'>$Login</span><br/>
    Path : <span class='Info'>$Workfolder</span><br/>
    CSV file : <span class='Info'>$(Split-Path $CSVFile -Leaf)</span><br/>
    Report file : <span class='Info'>$(Split-Path $ReportFile -Leaf)</span><br/>
    Start time : <span class='Info'>$StartTime</span><br/>
    End time : <span class='Info'>$EndTime</span><br/>
    Duration : <span class='Info'>$Duration</span> second(s)</p>"

    $MailBody += $Table
    $MailBody += $Info
    $MailBody += '</body>'
    $MailBody += '</html>'

    $MailBody = $MailBody -replace '<td>Warning</td>','<td class="WarningStatus">Warning</td>'
    $MailBody = $MailBody -replace '<td>Alert</td>','<td class="CriticalStatus">Alert</td>'
    $MailBody | Out-File -FilePath $ReportFile

    $AlertList | Format-Table
    
    Try {
        Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $MailBody -Priority High -Attachments $ReportFile -SmtpServer $MailSMTPServer -BodyAsHtml -Encoding UTF8
        Write-Host "VMware alerts(s) report with attached file : $(Split-Path $ReportFile -Leaf) has been sent by e-mail" -ForegroundColor Green
    }
    Catch {
        [string]$ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage -ForegroundColor Red
    }
    Disconnect-VIServer -Server $vCenter -Confirm:$false
}
Else {
    Disconnect-VIServer -Server $vCenter -Confirm:$false
}

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "CSV file : " -NoNewline; Write-Host (Split-Path $CSVFile -Leaf) -ForegroundColor Red
Write-Host "Report file : " -NoNewline; Write-Host (Split-Path $ReportFile -Leaf) -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " second(s)"
Write-Host "`r"
