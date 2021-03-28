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
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/31-script-add-dns-v1-0
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
[string]$CSVFile = $Workfolder + "\DNS-Records.csv"
[string]$ReportFile = $Workfolder + "\$Date-DNSRecords-Report.html"
[string]$LogFile = $Workfolder + "\$Date-Add-DNS.log"
Write-Host "Add-DNS :" -ForegroundColor Black -BackgroundColor Yellow
Try {
    [array]$Records = Import-Csv -Path ".\DNS-Records.csv" -Delimiter ";" -Encoding UTF8
}
Catch {
    [string]$ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
    Write-Log -Output $LogFile -Message $ErrorMessage
}
$Records | Add-Member -Type NoteProperty -Name "Status" -Value "N/A"
[int]$LineNumbers = $Records.Count
[string]$Activity = "Trying to launch the creation of [$LineNumbers] DNS record(s)"
[int]$Step = 1
[string]$Title = "[$Date] - DNS record(s) creation report on : $Hostname"

If ((Test-Path ".\DNS-Records.csv") -eq $True -and $LineNumbers -eq 0) {
    Write-Warning "CSV file [DNS-Records.csv] is empty."
    Write-Log -Output $LogFile -Message "CSV file [DNS-Records.csv] is empty."
}
ElseIf ($LineNumbers -ge 1) {
    Write-Host "Launching the creation of [$LineNumbers] DNS record(s)." -ForegroundColor Cyan
    Write-Host "`r"
    ForEach ($Record in $Records) {
        [string]$RecordName = $Record.DNSName
        [string]$RecordType = $Record.DNSType
        [string]$RecordIP = $Record.DNSIP
        [string]$RecordZone = $Record.DNSZone
        [string]$RecordServer = $Record.DNSServer
        [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
        [string]$CurrentOperation = "Adding DNS record : Name $RecordName - Type : $RecordType - IP : $RecordIP - Zone : $RecordZone - DNS Server : $RecordServer"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
        $Step++
        Start-Sleep -Seconds 1
        Try {
            $Record.Status = "OK"
            [string]$cmdDelete = "DNSCmd $RecordServer /RecordDelete $RecordZone $RecordName $RecordType $RecordIP /f"
            Write-Host "[DELETE] - Running this command : $cmdDelete" -ForegroundColor Yellow
            Invoke-Expression $cmdDelete | Out-Null
            Write-Host "`t[$RecordName - $RecordType - $RecordIP - $RecordZone] has been deleted." -ForegroundColor Green
            Write-Log -Output $LogFile -Message "[$RecordName - $RecordType - $RecordIP - $RecordZone] has been deleted."
            Write-Host "`r"

            [string]$cmdAdd = "DNSCmd $RecordServer /RecordAdd $RecordZone $RecordName /CreatePTR $RecordType $RecordIP"
            Invoke-Expression $cmdAdd | Out-Null
            Write-Host "[ADD] - Running this command : $cmdAdd" -ForegroundColor Cyan
            Write-Host "`t[$RecordName - $RecordType - $RecordIP - $RecordZone] has been added." -ForegroundColor Green
            Write-Log -Output $LogFile -Message "[$RecordName - $RecordType - $RecordIP - $RecordZone] has been added."
            Write-Host "`r"
        }
        Catch {
            $Record.Status = "KO"
            [string]$ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
            Write-Log -Output $LogFile -Message $ErrorMessage
            Write-Host "`r"
        }
    }
}

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)
[string]$PreContent = "<h1>$Title</h1>
<h2>Number of DNS record(s) : <span class='PostContentBlue'>$LineNumbers</span></h2>"
[string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
By : <span class='PostContentBlue'>$Login</span><br/>
Path : <span class='PostContentBlue'>$Workfolder</span><br/>
CSV file : <span class='PostContentBlue'>$(Split-Path $CSVFile -Leaf)</span><br/>
Report file : <span class='PostContentBlue'>$(Split-Path $ReportFile -Leaf)</span><br/>
Log file : <span class='PostContentBlue'>$(Split-Path $LogFile -Leaf)</span><br/>
Start time : <span class='PostContentBlue'>$StartTime</span><br/>
End time : <span class='PostContentBlue'>$EndTime</span><br/>
Duration : <span class='PostContentBlue'>$Duration</span> second(s)</p>"
[string]$Report = $Records | ConvertTo-Html -As Table -CssUri ".\Style.css" -Title $Title -PreContent $PreContent -PostContent $PostContent
$Report = $Report -replace '<td>OK</td>','<td class="SuccessStatus">OK</td>'
$Report = $Report -replace '<td>KO</td>','<td class="CriticalStatus">KO</td>'
$Report | Out-File -FilePath $ReportFile -Encoding utf8

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "CSV file : " -NoNewline; Write-Host (Split-Path $CSVFile -Leaf) -ForegroundColor Red
Write-Host "Report file : " -NoNewline; Write-Host (Split-Path $ReportFile -Leaf) -ForegroundColor Red
Write-Host "Log file : " -NoNewline; Write-Host (Split-Path $LogFile -Leaf) -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " second(s)"
Write-Host "`r"
