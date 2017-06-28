<#
.SYNOPSIS
    Retrieves snapshots on your vCenter
.DESCRIPTION
    Retrieves and send by e-mail all snapshots on your vCenter.
.NOTES
    File name : Get-Snapshots.ps1
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

$Snapshots = (Get-VM | Get-Snapshot | Sort-Object Created -Descending)
$SnapshotsNumber = $Snapshots.Count

$MailFrom = 'Username@mail.fr'
$MailTo = @('Username@mail.fr')
$MailSubject = '[VMware] - Snapshots daily report'
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
$MailBody += "<h1>VM snapshot(s) overview : $Date</h1>"
$MailBody += "<p style='font-weight:normal;font-size:13px;font-family:Arial;'>Number of snapshot(s) : <strong>$SnapshotsNumber</strong></p>"

#Prepare Table
$Table += '<table class="customTable">'
$Table += "<tr><th>VM</th><th>SizeGB</th><th>Created</th><th>Name</th><th>Description</th></tr>"
Foreach ($Snapshot in $Snapshots) {
    $Snap = "" | Select-Object VM, SizeGB, Created, Name, Description
	$SnapVM = ($Snapshot.VM).Name
    $SnapSizeGB = "{0:N2}" -f $Snapshot.SizeGB
	$SnapCreated = $Snapshot.Created
	$SnapName = $Snapshot.Name
    $SnapDescription = $Snapshot.Description

    $Table += "<tr><td>$SnapVM</td><td>$SnapSizeGB</td><td>$SnapCreated</td><td>$SnapName</td><td>$SnapDescription</td></tr>"
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
