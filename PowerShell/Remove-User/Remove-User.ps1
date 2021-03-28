<#
.SYNOPSIS
    Remove AD users
.DESCRIPTION
    Remove multiple users in AD group(s)
.NOTES
    File name : Remove-User.ps1
    Author : Pierre JACQUOT
    Date : 16/05/2016
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/28-script-remove-user
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
[string]$CSVFile = $Workfolder + "\Remove-User.csv"
[string]$ReportFile = $Workfolder + "\$Date-UsersRemoval-Report.html"
[string]$LogFile = $Workfolder + "\$Date-Remove_User.log"

Write-Host "Remove-User :" -ForegroundColor Black -BackgroundColor Yellow
Try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "ActiveDirectory module has been imported." -ForegroundColor Green
    Write-Log -Output $LogFile -Message "ActiveDirectory module has been imported."
}
Catch {
    Write-Warning "The ActiveDirectory module failed to load. Install the module and try again."
    Write-Log -Output $LogFile -Message "The ActiveDirectory module failed to load. Install the module and try again."
    Pause
    Write-Host "`r"
    Exit
}
Try {
    [array]$Records = Import-Csv -Path ".\Remove-User.csv" -Delimiter ";" -Encoding UTF8
}
Catch {
    [string]$ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -ForegroundColor Red
    Write-Log -Output $LogFile -Message $ErrorMessage
}
$Records | Add-Member -Type NoteProperty -Name "Status" -Value "N/A"
[int]$LineNumbers = $Records.Count
[string]$Activity = "Trying to launch the deletion of [$LineNumbers] user(s) into AD group(s)"
[int]$Step = 1
[string]$Title = "[$Date] - AD user(s) removal report on : $Hostname"

If ((Test-Path ".\Remove-User.csv") -eq $True -and $LineNumbers -eq 0) {
    Write-Warning "CSV file [Remove-User.csv] is empty."
    Write-Log -Output $LogFile -Message "CSV file [Remove-User.csv] is empty."
}
ElseIf ($LineNumbers -ge 1) {
    Write-Host "Launching the deletion of [$LineNumbers] user(s) from an AD group." -ForegroundColor Cyan
    Write-Host "`r"
    ForEach ($Record in $Records) {
        [string]$LoginName = $Record.sAMAccountName
        [string]$GroupName = $Record.GroupName
        [string]$Status = "Processing [$Step] of [$LineNumbers] - $(([math]::Round((($Step)/$LineNumbers*100),0)))% completed"
        [string]$CurrentOperation = "Removing AD user : $LoginName into the group : $GroupName"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$LineNumbers*100)
        $Step++
        Start-Sleep -Seconds 1
        Try {
            $Record.Status = "OK"
            Remove-ADGroupMember -Identity $GroupName -Members $LoginName -Confirm:$false
            Write-Host "$LoginName has been removed of the group : $GroupName." -ForegroundColor Green
            Write-Log -Output $LogFile -Message "$LoginName has been removed of the group : $GroupName."
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
<h2>Number of AD user(s) : <span class='PostContentBlue'>$LineNumbers</span></h2>"
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
