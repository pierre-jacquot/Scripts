<#
.SYNOPSIS
    Retrieves alerts on your vCenter
.DESCRIPTION
    Retrieves and send by e-mail all alerts on your vCenter.
.NOTES
    File name : Get-Alerts.ps1
    Author : Pierre JACQUOT
    Date : 30/05/2016
    Version : 1.0
#>

Clear-Host

$StartTime = (Get-Date)
$Date = Get-Date -UFormat "%Y-%m-%d"
$Hostname = [Environment]::MachineName
$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$vCenter = "vCenterServerName"

#Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server $vCenter

$rootFolder = Get-Folder -NoRecursion
$Alerts = ($rootFolder.ExtensionData.TriggeredAlarmState) | Sort-Object Time -Descending
$AlertsNumber = $Alerts.Count

$MailFrom = 'Username@mail.fr'
$MailTo = @('Username@mail.fr')
$MailSubject = '[VMware] - Alerts daily report'
$MailSmtp = 'SMTPServerName'

$MailBody = '<html>'
$MailBody += '<head>'
$MailBody += '<style type="text/css">'
$MailBody += 'h1 { font-size:14px; font-family:Arial; font-weight:bold; text-decoration: underline;}'
$MailBody += '.customTable { border:1px solid #000000; text-align:center; }'
$MailBody += '.customTable table{ border-collapse:collapse; border-spacing: 0; margin:0px; padding:0px; }'
$MailBody += '.customTable th{ background-color:#d3e5d4; font-size:14px; font-family:Arial; font-weight:bold; }'
$MailBody += '.customTable td{ vertical-align:middle; font-size:13px; font-family:Arial; font-weight:normal; }'
$MailBody += '</style>'
$MailBody += '</head>'

$MailBody += '<body>'
$MailBody += "<h1>vCenter alert(s) overview : $Date</h1>"
$MailBody += "<p style='font-weight:normal;font-size:13px;font-family:Arial;'>Number of alert(s) : <strong>$AlertsNumber</strong></p>"

#Prepare Table
$Table += '<table class="customTable">'
$Table += "<tr><th>Time</th><th>EntityType</th><th>Entity</th><th>Alarm</th><th>Status</th><th>Acknowledged</th><th>AckBy</th><th>AckTime</th></tr>"
Foreach ($Alert in $Alerts) {
    $Alarm = "" | Select-Object VC, EntityType, Alarm, Entity, Status, Time, Acknowledged, AckBy, AckTime
	$AlarmVC = $vCenter
	$AlarmAlarm = (Get-View $Alert.Alarm).Info.Name
	$Entity = Get-View $Alert.Entity
	$AlarmEntity = (Get-View $Alert.Entity).Name
	$AlarmEntityType = (Get-View $Alert.Entity).GetType().Name
    $AlarmStatus = $Alert.OverallStatus
        If ($AlarmStatus -eq "red" ) {
	        $AlarmStatus = "Alert"
        }
        Else {
            $AlarmStatus = "Warning"
        }
	$AlarmTime = $Alert.Time
    $AlarmAcknowledged = $Alert.Acknowledged
        If ($AlarmAcknowledged -eq "True" ) {
	        $AlarmAcknowledged = "Yes"
        }
        Else {
            $AlarmAcknowledged = "No"
        }
	$AlarmAckBy = $Alert.AcknowledgedByUser
	$AlarmAckTime = $Alert.AcknowledgedTime

    $Table += "<tr><td>$AlarmTime</td><td>$AlarmEntityType</td><td>$AlarmEntity</td><td>$AlarmAlarm</td><td>$AlarmStatus</td><td>$AlarmAcknowledged</td><td>$AlarmAckBy</td><td>$AlarmAckTime</td></tr>"
}

$Table += "</table><br>"

$EndTime = (Get-Date)
$Duration = ($EndTime-$StartTime).totalseconds

$Info = "<p style='font-weight:normal;font-style:italic;color:#000000;font-size:9px;text-align:left;font-family:arial, helvetica, sans-serif;line-height:1;'>Script launched from $Hostname in $Workfolder<br/>By : $Login<br/>Duration : $Duration seconds</p>"

$MailBody += $Table
$MailBody += $Info
$MailBody += '</body>'

Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -SmtpServer $MailSmtp -BodyAsHtml -Encoding UTF8

Disconnect-VIServer -Server $vCenter -Confirm:$false
