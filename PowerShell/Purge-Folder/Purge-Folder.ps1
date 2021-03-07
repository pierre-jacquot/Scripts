<#
.SYNOPSIS
    Delete old log files
.DESCRIPTION
    Delete all log files in a folder that haven't been modified in the last 30 days and export results
.NOTES
    File name : Purge-Folder.ps1
    Author : Pierre JACQUOT
    Date : 07/02/2018
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/43-script-purge-folder
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
[string]$CSVFile = $Workfolder + "\$Date-FilesRemoval-Export.csv"
[string]$ReportFile = $Workfolder + "\$Date-FilesRemoval-Report.html"
[string]$LogFile = $Workfolder + "\$Date-Purge-Folder.log"
[string]$SourceFolder = "D:\Scripts\Purge-Folder\Logs"
[array]$AllFiles = Get-ChildItem -Path $SourceFolder -Recurse
[array]$ConditionFiles = $AllFiles | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddDays(-30)) -and ($_.Name -like "Test*") -and ($_.Extension -eq ".txt") }
$ConditionFiles | Add-Member -Type NoteProperty -Name "Status" -Value "N/A"
[int]$FilesNumber = $AllFiles.Count
[int]$ConditionFilesNumber = $ConditionFiles.Count
[string]$Activity = "Trying to launch the deletion of [$ConditionFilesNumber] log file(s)"
[int]$Step = 1
[string]$Title = "[$Date] - File(s) removal report on : $Hostname"

Write-Host "Purge-Folder :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the deletion of [$ConditionFilesNumber] log file(s)." -ForegroundColor Cyan
Write-Host "`r"

If ($FilesNumber -eq 0) {
    Write-Warning "Source folder $SourceFolder is empty."
    Write-Log -Output $LogFile -Message "Source folder $SourceFolder is empty."
}
ElseIf ($ConditionFilesNumber -eq 0) {
    Write-Warning "Source folder $SourceFolder does not contain Test*.txt files older than 30 days."
    Write-Log -Output $LogFile -Message "Source folder $SourceFolder does not contain Test*.txt files older than 30 days."
}
Else {
    ForEach ($File in $ConditionFiles) {
        [string]$FileName = $File.Name
        $FileLastWriteTime = $File.LastWriteTime
        [string]$Status = "Processing [$Step] of [$ConditionFilesNumber] - $(([math]::Round((($Step)/$ConditionFilesNumber*100),0)))% completed"
        [string]$CurrentOperation = "Removing log file :  $FileName - LastWriteTime : $FileLastWriteTime"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$ConditionFilesNumber*100)
        $Step++
        Start-Sleep -Seconds 1
        Try {
            $File.Status = "OK"
            Remove-Item $File.FullName
            Write-Host "$FileName has been removed - LastWriteTime : $FileLastWriteTime." -ForegroundColor Green
            Write-Log -Output $LogFile -Message "$FileName has been removed - LastWriteTime : $FileLastWriteTime."
        }
        Catch {
            $File.Status = "KO"
            [string]$ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage -ForegroundColor Red
            Write-Log -Output $LogFile -Message $ErrorMessage
        }
    }
}

[array]$FileList = $ConditionFiles  | Select-Object FullName, @{Name="Length (Ko)";Expression={"{0:N2}" -f ($_.Length/1024)}}, Extension, CreationTime, LastWriteTime, Status
$FileList | Export-Csv -Path $CSVFile -NoTypeInformation -Delimiter ";" -Encoding UTF8
$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)
[string]$PreContent = "<h1>$Title</h1>
<h2>Number of file(s) : <span class='PostContentBlue'>$ConditionFilesNumber</span></h2>"
[string]$PostContent = "<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
By : <span class='PostContentBlue'>$Login</span><br/>
Path : <span class='PostContentBlue'>$Workfolder</span><br/>
CSV file : <span class='PostContentBlue'>$(Split-Path $CSVFile -Leaf)</span><br/>
Report file : <span class='PostContentBlue'>$(Split-Path $ReportFile -Leaf)</span><br/>
Log file : <span class='PostContentBlue'>$(Split-Path $LogFile -Leaf)</span><br/>
Start time : <span class='PostContentBlue'>$StartTime</span><br/>
End time : <span class='PostContentBlue'>$EndTime</span><br/>
Duration : <span class='PostContentBlue'>$Duration</span> second(s)</p>"
[string]$Report = $FileList | ConvertTo-Html -As Table -CssUri ".\Style.css" -Title $Title -PreContent $PreContent -PostContent $PostContent
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
