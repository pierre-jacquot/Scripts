Set-Location -Path "D:\"
New-Item alias:np -Value "C:\Windows\System32\notepad.exe"
New-Item alias:np++ -Value "C:\Program Files (x86)\Notepad++\notepad++.exe"
Clear-Host

Function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal $Identity
    $Principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

Function Prompt {
    $Hostname = [Environment]::MachineName
    $Username = [Environment]::UserName
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
