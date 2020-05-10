<#
.SYNOPSIS
    Displays folders list with their size
.DESCRIPTION
    Displays and exports folders list with their size
.NOTES
    File name : Get-FolderSize.ps1
    Author : Pierre JACQUOT
    Date : 19/07/2017
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/39-script-get-foldersize
#>

Clear-Host

$StartTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[string]$Hostname = [Environment]::MachineName
[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$BasePath = "C:\Users"
[string]$ExportFile = $Workfolder + "\$Date-Folders.csv"
[array]$AllFolders = Get-Childitem -Path $BasePath -Directory
[int]$FolderNumbers = $AllFolders.Count
[System.Collections.ArrayList]$FolderList = @()
[string]$Activity = "Trying to launch the export of [$FolderNumbers] folder(s)"
[int]$Step = 1

Write-Host "Get-FolderSize :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the export of [$FolderNumbers] folder(s)." -ForegroundColor Cyan

ForEach ($Folder in $AllFolders) {
    [string]$Status = "Processing [$Step] of [$FolderNumbers] - $(([math]::Round((($Step)/$FolderNumbers*100),0)))% completed"
    [string]$CurrentOperation = "Calculating size on folder : $Folder"
    Write-Progress -Activity $Activity -Status $Status -CurrentOperation $CurrentOperation -PercentComplete ($Step/$FolderNumbers*100)
    $Step++
    Start-Sleep -Seconds 1

    $FolderName = $null
    $FolderFullPath = $null
    $FolderCreationTime = $null
    $FolderLastWriteTime = $null
    $FolderSizeInMB = $null
    $FolderSizeInGB = $null
    $FolderProp = $null

    $FolderName = $Folder.Name
    $FolderFullPath = $Folder.FullName
    $FolderCreationTime = $Folder.CreationTime
    $FolderLastWriteTime = $Folder.LastWriteTime
    $FolderSizeInMB = "{0:N1}" -f ((Get-ChildItem -Path $FolderFullPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB)
    $FolderSizeInGB = "{0:N1}" -f ((Get-ChildItem -Path $FolderFullPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB)

    $FolderProp = @{FolderName = $FolderName}
    $FolderProp += @{CreationTime = $FolderCreationTime}
    $FolderProp += @{"Size (MB)" = $FolderSizeInMB}
    $FolderProp += @{"Size (GB)" = $FolderSizeInGB}
    $FolderProp += @{LastWriteTime = $FolderLastWriteTime}

    $FolderObject = New-Object psobject -Property $FolderProp

    $FolderList.Add($FolderObject) | Out-Null
}
$FolderList | Sort-Object "Size (GB)" -Descending | Select-Object FolderName, "Size (MB)", "Size (GB)", CreationTime, LastWriteTime | Format-Table -AutoSize
$FolderList | Sort-Object "Size (GB)" -Descending | Select-Object FolderName, "Size (MB)", "Size (GB)", CreationTime, LastWriteTime | Export-Csv -Path $ExportFile -NoTypeInformation -Delimiter ";" -Encoding UTF8

$TotalSizeInMB = "{0:N1} (MB)" -f ((Get-ChildItem -Path $BasePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB)
$TotalSizeInGB = "{0:N1} (GB)" -f ((Get-ChildItem -Path $BasePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB)

$EndTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
[decimal]$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalSeconds,2)

Write-Host "Total size : $TotalSizeInMB - $TotalSizeInGB on [$BasePath]" -ForegroundColor Cyan
Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Export file : " -NoNewline; Write-Host (Split-Path $ExportFile -Leaf) -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " seconds"
Write-Host "`r"
