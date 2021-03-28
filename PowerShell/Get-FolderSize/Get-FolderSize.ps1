<#
.SYNOPSIS
    Displays folders list with their size
.DESCRIPTION
    Displays and export folders list with their size
.NOTES
    File name : Get-FolderSize.ps1
    Author : Pierre JACQUOT
    Date : 19/07/2017
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/39-script-get-foldersize
#>

Clear-Host

$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$BasePath = "D:\Scripts"
[string]$CSVFile = $Workfolder + "\$Date-Folders-Export.csv"
[string]$ReportFile = $Workfolder + "\$Date-Folders-Report.html"
[array]$AllFolders = Get-Childitem -Path $BasePath -Directory -Force
[int]$FolderNumbers = $AllFolders.Count
[System.Collections.ArrayList]$FolderList = @()
[string]$Activity = "Trying to launch the export of [$FolderNumbers] folder(s)"
[int]$Step = 1
[string]$Title = "[$Date] - Folder(s) size report on : $Hostname"

Write-Host "Get-FolderSize :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the export of [$FolderNumbers] folder(s)." -ForegroundColor Cyan
Write-Host "`r"

If ($FolderNumbers -eq 0) {
    Write-Warning "There is no folder in $BasePath"
}
Else {
    ForEach ($Folder in $AllFolders) {
        [string]$Status = "Processing [$Step] of [$FolderNumbers] - $(([math]::Round((($Step)/$FolderNumbers*100),0)))% completed"
        [string]$CurrentOperation = "Calculating size on folder : $Folder"
        Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$FolderNumbers*100)
        $Step++

        [string]$FolderFullPath = $null
        $FolderObject = $null
        $FolderCreationTime = $null
        $FolderLastWriteTime = $null
        [string]$FolderSizeInMB = $null
        [string]$FolderSizeInGB = $null
        [string]$FolderBaseName = $null

        $FolderFullPath = $Folder.FullName
        $FolderBaseName = $Folder.BaseName
        $FolderCreationTime = $Folder.CreationTime
        $FolderLastWriteTime = $Folder.LastWriteTime
        [array]$FolderSize = Get-Childitem -Path $FolderFullPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
        $FolderSizeInMB = "{0:N3}" -f ($FolderSize.Sum / 1MB)
        $FolderSizeInGB = "{0:N3}" -f ($FolderSize.Sum / 1GB)

        $ParamList = [PSCustomObject]@{
            FolderName = $FolderBaseName
            "Size (Bytes)" = $FolderSize.Sum
            "Size (MB)" = $FolderSizeInMB
            "Size (GB)" = $FolderSizeInGB
            CreationTime = $FolderCreationTime
            LastWriteTime = $FolderLastWriteTime
        }
        $FolderList.Add($ParamList) | Out-Null
    }
}

[array]$FoldersList = $FolderList | Sort-Object "Size (Bytes)" -Descending
$FoldersList | Format-Table -AutoSize
$FoldersList | Export-Csv -Path $CSVFile -NoTypeInformation -Delimiter ";" -Encoding UTF8

[string]$TotalSizeInBytes = "{0:N3} Bytes" -f ((Get-ChildItem -Path $BasePath -Recurse -Force | Measure-Object -Property Length -Sum).Sum)
[string]$TotalSizeInMB = "{0:N3} MB" -f ((Get-ChildItem -Path $BasePath -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1MB)
[string]$TotalSizeInGB = "{0:N3} GB" -f ((Get-ChildItem -Path $BasePath -Recurse -Force | Measure-Object -Property Length -Sum).Sum / 1GB)

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

[string]$PreContent = "<h1>$Title</h1>
<h2>Number of folder(s) : <span class='PostContentBlue'>$FolderNumbers</span></h2>"
[string]$PostContent = "<p>Total size : <span class='PostContentBlue'><strong>$TotalSizeInBytes</strong></span> - <span class='PostContentBlue'><strong>$TotalSizeInMB</strong></span> - <span class='PostContentBlue'><strong>$TotalSizeInGB</strong></span> on <span class='PostContentBlue'><strong>$BasePath</strong></span></p>
<p id='PostContent'>Script launched from : <span class='PostContentBlue'>$Hostname</span><br/>
By : <span class='PostContentBlue'>$Login</span><br/>
Path : <span class='PostContentBlue'>$Workfolder</span><br/>
CSV file : <span class='PostContentBlue'>$(Split-Path $CSVFile -Leaf)</span><br/>
Report file : <span class='PostContentBlue'>$(Split-Path $ReportFile -Leaf)</span><br/>
Start time : <span class='PostContentBlue'>$StartTime</span><br/>
End time : <span class='PostContentBlue'>$EndTime</span><br/>
Duration : <span class='PostContentBlue'>$Duration</span> second(s)</p>"

[string]$Report = $FoldersList | ConvertTo-Html -As Table -CssUri ".\Style.css" -Title $Title -PreContent $PreContent -PostContent $PostContent
$Report | Out-File -FilePath $ReportFile -Encoding utf8

Write-Host "Total size : $TotalSizeInBytes - $TotalSizeInMB - $TotalSizeInGB on [$BasePath]" -ForegroundColor Cyan

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
