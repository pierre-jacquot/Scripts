<#
.SYNOPSIS
    Zip files creation.
.DESCRIPTION
    Create multiple zip files on a shared folder.
.NOTES
    File name : Create-Zip.ps1
    Author : Pierre JACQUOT
    Date : 08/06/2017
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/34-script-create-zip
#>

Clear-Host

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

$StartTime = Get-Date
$Hostname = [Environment]::MachineName
$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = $Workfolder + "\$Date-Create-Zip.log"
$Records = Import-Csv -Path ".\Zip-Records.csv"
$LineNumbers = $Records.Count

Write-Host "Create-Zip :" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Launching the creation of [$LineNumbers] zip file(s)." -ForegroundColor Cyan
Write-Host "`r"

ForEach ($Record in $Records) {
    $User = $Record.User
    $SourceFolder = $Record.SourceFolder+"$User"
    $DestinationZip = $Record.DestinationZip+"$Date-Archive-$User.zip"
    Try {
        Add-Type -Assembly "System.IO.Compression.FileSystem"
        [IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $DestinationZip)
        Write-Host "The file $DestinationZip has been created" -ForegroundColor Green
        Write-Log -Output "$LogFile" -Message "The file $DestinationZip has been created"
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Log -Output "$LogFile" -Message "$ErrorMessage"
    }
}

$EndTime = Get-Date
$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $Login -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " minutes"
Write-Host "`r"
