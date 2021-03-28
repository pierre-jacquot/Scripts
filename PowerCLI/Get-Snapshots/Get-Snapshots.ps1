<#
.SYNOPSIS
    Retrieves VM snapshots on your VMware vCenter Server.
.DESCRIPTION
    Retrieves and send by e-mail all VM snapshots on your VMware vCenter Server.
.NOTES
    File name : Get-Snapshots.ps1
    Author : Pierre JACQUOT
    Date : 30/05/2016
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/40-script-get-snapshots
#>

Clear-Host

# List of variables
$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$CSVFile = $Workfolder + "\$Date-Snapshots-Export.csv"
[string]$ReportFile = $Workfolder + "\$Date-Snapshots-Report.html"
[string]$vCenter = "vCenterServerName"

Write-Host "Get-Snapshots :" -ForegroundColor Black -BackgroundColor Yellow

# Trying to connect to the VMware vCenter Server
Try {
	$Connexion = Connect-VIServer -Server $vCenter
    Write-Host "Connected on the VMware vCenter Server : $Connexion" -ForegroundColor Green
}
Catch {
	Write-Host "[ERROR] : Unable to connect on the VMware vCenter Server" -ForegroundColor Red
	Exit
}

# Retrieves and count VM snapshot(s) on the VMware vCenter Server
[array]$Snapshots = Get-VM | Get-Snapshot | Select-Object Created, VM, @{Name="SizeGB";Expression={"{0:N2}" -f $_.SizeGB}}, Name, Description | Sort-Object SizeGB
[int]$SnapshotsNumber = $Snapshots.Count

If ($SnapshotsNumber -ge 1) {
    # Send-MailMessage parameters
    [string]$MailFrom = "vCenter[at]mail.fr"
    [string]$MailTo = @('UserName[at]mail.fr')
    [string]$MailCc = @('UserName[at]mail.fr')
    [string]$MailSubject = "[$Date] - [VMware] - Snapshot(s) daily report on : $vCenter"
    [string]$MailSMTPServer = "SMTPServerName"

    [string]$Style="<title>$MailSubject</title>
    <style>
        h1 { font-family: Arial; color: #e68a00; font-size: 28px; }
        h2 { font-family: Arial; color: #000000; font-size: 16px; }
        table { border-collapse: collapse; }
        td, th { border: 1px solid #000000; }
        td { font-size: 13px; font-family: Arial; }
        th { background-color: #d3e5d4; font-size: 14px; font-family: Arial; font-weight: bold; text-align: left; }
        tr:nth-child(even) { background-color: #f0f0f2; }
        tr:hover { background-color: #ddd; }
        .CriticalStatus { background-color: #ff0000; font-weight: bold; color: #ffffff; }
        .WarningStatus { background-color: #ffa500; font-weight: bold; color: #ffffff; }
        #PostContent { font-family: Arial; font-size: 11px; font-style: italic; }
        span.PostContentBlue { color: #000099; }
    </style>"

    $Snapshots | Format-Table -AutoSize
    $Snapshots | Export-Csv -Path $CSVFile -NoTypeInformation -Delimiter ";" -Encoding UTF8
    
    $EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    [decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

    [string]$PreContent = "<h1>$MailSubject</h1>
    <h2>Number of snapshot(s) : <span class='PostContentBlue'>$SnapshotsNumber</span></h2>"
    [string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
    By : <span class='PostContentBlue'>$Login</span><br/>
    Path : <span class='PostContentBlue'>$Workfolder</span><br/>
    CSV file : <span class='PostContentBlue'>$(Split-Path $CSVFile -Leaf)</span><br/>
    Report file : <span class='PostContentBlue'>$(Split-Path $ReportFile -Leaf)</span><br/>
    Start time : <span class='PostContentBlue'>$StartTime</span><br/>
    End time : <span class='PostContentBlue'>$EndTime</span><br/>
    Duration : <span class='PostContentBlue'>$Duration</span> second(s)</p>"

    [string]$Report = $Snapshots | ConvertTo-Html -As Table -Head $Style -PreContent $PreContent -PostContent $PostContent
    $Report | Out-File -FilePath $ReportFile -Encoding utf8
    Write-Host "[VMware] - Snapshot(s) report has been created : $ReportFile" -ForegroundColor Green

    Try {
        Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $Report -Priority High -Attachments $ReportFile -SmtpServer $MailSMTPServer -BodyAsHtml -Encoding UTF8
        Write-Host "VM snapshot(s) report with attached file : $(Split-Path $ReportFile -Leaf) has been sent by e-mail" -ForegroundColor Green
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
