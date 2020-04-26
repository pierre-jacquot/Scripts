<#
.SYNOPSIS
    Customize your PowerShell Profile.
.DESCRIPTION
    Customizing your PowerShell Profile in order to automatically load scripts when you start the PowerShell console.
.NOTES
    File name : Microsoft.PowerShell_profile.ps1
    Author : Pierre JACQUOT
    Date : 28/10/2018
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/44-configurer-son-profile-sous-windows-powershell-ise
#>

Set-Location -Path "D:\"
New-Item alias:np -Value "C:\Windows\System32\notepad.exe"
New-Item alias:np++ -Value "C:\Program Files\Notepad++\notepad++.exe"
Clear-Host

Function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal $Identity
    $Principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Function Prompt {
    [string]$Hostname = [Environment]::MachineName
    [string]$Username = [Environment]::UserName
    $Host.UI.RawUI.WindowTitle = "Windows PowerShell > Hostname : $Hostname > Username : $Username"
    Write-Host "I " -NoNewline
    Write-Host "$([char]9829) " -ForegroundColor Red -NoNewline
    Write-Host "PS " -NoNewline
    Write-Host "> " -ForegroundColor Yellow -NoNewline
    Write-Host (Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") -ForegroundColor Cyan -NoNewline
    Write-Host "> " -ForegroundColor Yellow -NoNewline
    Write-Host (Split-Path $PWD -Leaf) -ForegroundColor Green -NoNewline
    If (Test-Administrator -eq $True) {
        $Host.UI.RawUI.WindowTitle = "[Administrateur] - Windows PowerShell > Hostname : $Hostname > Username : $Username"
        Write-Host " >" -ForegroundColor Yellow -NoNewline
        Write-Host " [ADMIN]" -ForegroundColor Red -NoNewline
    }
    Write-Host " >_" -ForegroundColor Yellow -NoNewline
    return " "
}
