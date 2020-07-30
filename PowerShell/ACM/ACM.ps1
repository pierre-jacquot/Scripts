<#
.SYNOPSIS
    Account Management Program (ACM) on AD
.DESCRIPTION
    Create User, Administrator, Service, Monitoring accounts or groups on AD
.NOTES
    File name : ACM.ps1
    Author : Pierre JACQUOT
    Date : 13/10/2015
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.yo.fr
    Reference : https://www.pierrejacquot.yo.fr/index.php/scripts/23-script-account-manager-acm
#>

Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d/%m/%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

[string]$Login = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[string]$Workfolder = Split-Path $MyInvocation.MyCommand.Path
[string]$Date = Get-Date -UFormat "%Y-%m-%d"
[string]$Time = Get-Date -UFormat "%R"
[string]$LogFile = $Workfolder + "\$Date-ACM.log"
[decimal]$Version = "1.0"
[string]$Domain = "lab.microsoft.com"

Write-Host "ACM - ACCOUNT MANAGEMENT PROGRAM :" -ForegroundColor Black -BackgroundColor Yellow
Try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Log -Output $LogFile -Message "ActiveDirectory module has been imported."
}
Catch {
    Write-Warning "The ActiveDirectory module failed to load. Install the module and try again."
    Write-Log -Output $LogFile -Message "The ActiveDirectory module failed to load. Install the module and try again."
    Pause
    Write-Host "`r"
    Exit
}

[bool]$Restart = $true

While ($Restart) {
    [int]$Action = 0
    Clear-Host
    Write-Host "`r"
    Write-Host "###################################################################"
    Write-Host "######          [ ACM - ACCOUNT MANAGEMENT PROGRAM ]          #####"
    Write-Host "######   Version : $Version | Date : $Date | Heure : $Time   ######"
    Write-Host "###################################################################"
    Write-Host "`r"
    Write-Host "MENU :"
    Write-Host "`r"
    Write-Host "[1] - Créer un compte utilisateur."
    Write-Host "[2] - Créer un compte administrateur."
    Write-Host "[3] - Créer un compte de service."
    Write-Host "[4] - Créer un compte de monitoring."
    Write-Host "[5] - Désactiver un compte temporairement."
    Write-Host "[6] - Désactiver un compte et supprimer ses groupes d'appartenance."
    Write-Host "[7] - Réactiver un compte."
    Write-Host "[8] - Créer un groupe de sécurité."
    Write-Host "[9] - Quitter."
    Write-Host "`r"

    While ($Action -lt 1 -or $Action -gt 9) {
        Try {
            $Action = Read-Host "Choisir l'action à effectuer (1-9) "
        }
        Catch {
            [string]$ErrorMessage = $_.Exception.Message
            Write-Host "Saisir une action entre 1 et 9 uniquement !" -ForegroundColor Red
            Write-Host "`r"
        }
    }
    Switch ($Action) {
        1 {
            Write-Host "`r"
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "##########    [ AD - CREATION D'UN COMPTE UTILISATEUR ]    ##########" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "`r"

            [string]$AccountBusinessCategory = "User"

            Do {
                Do {
                    [string]$AccountGivenName = Read-Host "Saisir le prénom du compte "
                    If ($AccountGivenName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le prénom du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountGivenName -eq "")

                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                $AccountGivenName = (Get-Culture).TextInfo.ToTitleCase($AccountGivenName)
                [string]$AccountGivenNameMin = $AccountGivenName.ToLower().Trim()
                If ($AccountGivenName.Contains('-')) {
                    [string]$AccountBeginLogin = $AccountGivenNameMin -replace '(.).*-(.).*','$1$2'
                }
                Else {
                    $AccountBeginLogin = $AccountGivenNameMin.Substring(0,1)
                }

                Do {
                    [string]$AccountName = Read-Host "Saisir le nom du compte "
                    If ($AccountName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le nom du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountName -eq "")

                $AccountName = $AccountName.ToLower().Trim()
                $AccountName = (Get-Culture).TextInfo.ToTitleCase($AccountName)
                [string]$AccountNameMin = $AccountName.ToLower().Trim()
                [string]$AccountLogin = "$AccountBeginLogin.$AccountNameMin"

                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                    }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }

                [string]$AccountDisplayName = "$AccountGivenName $AccountName"
                [string]$AccountFullLogin = "$AccountBeginLogin.$AccountNameMin@$Domain"
            } While ($UserExist)

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (10 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPass = Read-Host "Saisir le mot de passe du compte " -AsSecureString
                $AccountPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccountPass))
                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{10,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{10,}$'))

            Write-Host "`r"
            Write-Host "Rappel des informations du compte utilisateur à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le prénom du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- Le nom du compte est : " -NoNewline; Write-Host $AccountName -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- Le login complet du compte est : " -NoNewline; Write-Host $AccountFullLogin -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- Le Display Name du compte est : " -NoNewline; Write-Host $AccountDisplayName -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la création du compte utilisateur ?"

            Do {
                [string]$AccountCreation = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountCreation = $AccountCreation.ToLower().Trim()
                If ($AccountCreation -eq "") {
                    $AccountCreation = "o"
                }
                If ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountCreation -or ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n"))

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                Try {
                    New-ADUser $AccountDisplayName -GivenName $AccountGivenName -Surname $AccountName -displayName $AccountDisplayName -SamAccountName $AccountLogin -UserPrincipalName $AccountFullLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                    Write-Host "`r"
                    Write-Host "Le compte utilisateur [$AccountDisplayName] a été créé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte utilisateur [$AccountDisplayName] a été créé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte utilisateur [$AccountDisplayName] n'a pas été créé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte utilisateur [$AccountDisplayName] n'a pas été créé." -ForegroundColor Red
            }
        }
        2 {
            Write-Host "`r"
            Write-Host "########################################################################" -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "##########    [ AD - CREATION D'UN COMPTE ADMINISTRATEUR ]    ##########" -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "########################################################################" -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "`r"

            [string]$AccountInitials = "ADM"
            [string]$AccountBusinessCategory = "Admin"

            Do {
                Do {
                    [string]$AccountGivenName = Read-Host "Saisir le prénom du compte "
                    If ($AccountGivenName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le prénom du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountGivenName -eq "")

                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                $AccountGivenName = (Get-Culture).TextInfo.ToTitleCase($AccountGivenName)
                [string]$AccountGivenNameMin = $AccountGivenName.ToLower().Trim()
                If ($AccountGivenName.Contains('-')) {
                    [string]$AccountBeginLogin = $AccountGivenNameMin -replace '(.).*-(.).*','$1$2'
                }
                Else {
                    $AccountBeginLogin = $AccountGivenNameMin.Substring(0,1)
                }

                Do {
                    $AccountName = Read-Host "Saisir le nom du compte "
                    If ($AccountName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le nom du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountName -eq "")

                $AccountName = $AccountName.ToLower().Trim()
                $AccountName = (Get-Culture).TextInfo.ToTitleCase($AccountName)
                [string]$AccountNameMin = $AccountName.ToLower().Trim()
                [string]$AccountLogin = "0$AccountBeginLogin.$AccountNameMin"

                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }

                [string]$AccountDisplayName = "$AccountInitials $AccountGivenName $AccountName"
                [string]$AccountFullLogin = "0$AccountBeginLogin.$AccountNameMin@$Domain"
            } While ($UserExist)

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (20 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPass = Read-Host "Saisir le mot de passe du compte " -AsSecureString
                $AccountPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccountPass))
                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{20,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{20,}$'))

            Write-Host "`r"
            Write-Host "Rappel des informations du compte administrateur à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le prénom du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- Le nom du compte est : " -NoNewline; Write-Host $AccountName -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- Le login complet du compte est : " -NoNewline; Write-Host $AccountFullLogin -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- Le Display Name du compte est : " -NoNewline; Write-Host $AccountDisplayName -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor DarkGray
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la création du compte administrateur ?"

            Do {
                [string]$AccountCreation = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountCreation = $AccountCreation.ToLower().Trim()
                If ($AccountCreation -eq "") {
                    $AccountCreation = "o"
                }
                If ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountCreation -or ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n"))

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                Try {
                    New-ADUser $AccountDisplayName -GivenName $AccountGivenName -Surname $AccountName -displayName $AccountDisplayName -SamAccountName $AccountLogin -UserPrincipalName $AccountFullLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory;initials=$AccountInitials}
                    Write-Host "`r"
                    Write-Host "Le compte administrateur [$AccountDisplayName] a été créé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte administrateur [$AccountDisplayName] a été créé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte administrateur [$AccountDisplayName] n'a pas été créé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte administrateur [$AccountDisplayName] n'a pas été créé." -ForegroundColor Red
            }
        }
        3 {
            Write-Host "`r"
            Write-Host "####################################################################" -ForegroundColor White -BackgroundColor Blue
            Write-Host "##########    [ AD - CREATION D'UN COMPTE DE SERVICE ]    ##########" -ForegroundColor White -BackgroundColor Blue
            Write-Host "####################################################################" -ForegroundColor White -BackgroundColor Blue
            Write-Host "`r"

            [string]$AccountBusinessCategory = "Service"

            Do {
                Do {
                    Write-Host "Entrer le login à l'aide de ce modèle : svc[i/d/r/p]_name" -ForegroundColor Cyan
                    [string]$AccountGivenName = Read-Host "Saisir le login du compte de service "
                    If ($AccountGivenName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le login du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountGivenName -eq "")
                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                [string]$AccountLogin = "$AccountGivenName@$Domain"
                If (!$AccountGivenName.StartsWith("svci_") -and !$AccountGivenName.StartsWith("svcd_") -and !$AccountGivenName.StartsWith("svcr_") -and !$AccountGivenName.StartsWith("svcp_")) {
                    Write-Host "`r"
                    Write-Warning "Le login doit obligatoirement commencer par svc[i/d/r/p]_"
                    Write-Host "`r"
                }
                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountGivenName }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountGivenName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (($UserExist) -or (!$AccountGivenName.StartsWith("svci_") -and !$AccountGivenName.StartsWith("svcd_") -and !$AccountGivenName.StartsWith("svcr_") -and !$AccountGivenName.StartsWith("svcp_")))

            Do {
                [string]$AccountDescription = Read-Host "Saisir la description du compte "
                If ($AccountDescription -eq "") {
                    Write-Host "`r"
                    Write-Host "La description du compte à créer ne peux pas être vide !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While ($AccountDescription -eq "")
            
            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (15 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPass = Read-Host "Saisir le mot de passe du compte " -AsSecureString
                $AccountPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccountPass))
                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$'))

            Write-Host "`r"
            Write-Host "Rappel des informations du compte de service à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor Blue
            Write-Host "- Le login complet du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Blue
            Write-Host "- La description du compte est : " -NoNewline; Write-Host $AccountDescription -ForegroundColor White -BackgroundColor Blue
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor Blue
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor Blue
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la création du compte de service ?"

            Do {
                [string]$AccountCreation = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountCreation = $AccountCreation.ToLower().Trim()
                If ($AccountCreation -eq "") {
                    $AccountCreation = "o"
                }
                If ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountCreation -or ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n"))

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                Try {
                    New-ADUser $AccountGivenName -GivenName $AccountGivenName -displayName $AccountGivenName -Description $AccountDescription -SamAccountName $AccountGivenName -UserPrincipalName $AccountLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                    Write-Host "`r"
                    Write-Host "Le compte de service [$AccountGivenName] a été créé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte de service [$AccountGivenName] a été créé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte de service [$AccountGivenName] n'a pas été créé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte de service [$AccountGivenName] n'a pas été créé." -ForegroundColor Red
            }
        }
        4 {
            Write-Host "`r"
            Write-Host "#######################################################################" -ForegroundColor White -BackgroundColor Red
            Write-Host "##########    [ AD - CREATION D'UN COMPTE DE MONITORING ]    ##########" -ForegroundColor White -BackgroundColor Red
            Write-Host "#######################################################################" -ForegroundColor White -BackgroundColor Red
            Write-Host "`r"

            [string]$AccountBusinessCategory = "Monitoring"

            Do {
                Do {
                    Write-Host "Entrer le login à l'aide de ce modèle : monitoring.name" -ForegroundColor Cyan
                    [string]$AccountGivenName = Read-Host "Saisir le login du compte de monitoring "
                    If ($AccountGivenName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le login du compte à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountGivenName -eq "")
                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                [string]$AccountLogin = "$AccountGivenName@$Domain"
                If (!$AccountGivenName.StartsWith("monitoring.")) {
                    Write-Host "`r"
                    Write-Warning "Le login doit obligatoirement commencer par monitoring."
                    Write-Host "`r"
                }
                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountGivenName }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountGivenName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (($UserExist) -or (!$AccountGivenName.StartsWith("monitoring.")))

            Do {
                [string]$AccountDescription = Read-Host "Saisir la description du compte "
                If ($AccountDescription -eq "") {
                    Write-Host "`r"
                    Write-Host "La description du compte à créer ne peux pas être vide !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While ($AccountDescription -eq "")

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (15 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPass = Read-Host "Saisir le mot de passe du compte " -AsSecureString
                $AccountPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AccountPass))
                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$'))

            Write-Host "`r"
            Write-Host "Rappel des informations du compte de monitoring à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor Red
            Write-Host "- Le login complet du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Red
            Write-Host "- La description du compte est : " -NoNewline; Write-Host $AccountDescription -ForegroundColor White -BackgroundColor Red
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor Red
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor Red
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la création du compte de monitoring ?"

            Do {
                [string]$AccountCreation = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountCreation = $AccountCreation.ToLower().Trim()
                If ($AccountCreation -eq "") {
                    $AccountCreation = "o"
                }
                If ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountCreation -or ($AccountCreation -ne "oui" -and $AccountCreation -ne "o" -and $AccountCreation -ne "non" -and $AccountCreation -ne "n"))

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                Try {
                    New-ADUser $AccountGivenName -GivenName $AccountGivenName -displayName $AccountGivenName -Description $AccountDescription -SamAccountName $AccountGivenName -UserPrincipalName $AccountLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                    Write-Host "`r"
                    Write-Host "Le compte de monitoring [$AccountGivenName] a été créé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte de monitoring [$AccountGivenName] a été créé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte de monitoring [$AccountGivenName] n'a pas été créé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte de monitoring [$AccountGivenName] n'a pas été créé." -ForegroundColor Red
            }
        }
        5 {
            Write-Host "`r"
            Write-Host "########################################################################" -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "##########    [ AD - DESACTIVER UN COMPTE TEMPORAIREMENT ]    ##########" -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "########################################################################" -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "`r"

            Do {
                Do {
                    [string]$AccountLogin = Read-Host "Saisir le login du compte à désactiver "
                    If ($AccountLogin -eq "") {
                        Write-Host "`r"
                        Write-Host "Le login du compte à désactiver ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                    $AccountLogin = $AccountLogin.ToLower().Trim()
                } While ($AccountLogin -eq "")
                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist.Enabled -eq $false) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] est déjà désactivé dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist -or $UserExist.Enabled -eq $false)

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à désactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "- Le login complet du compte à désactiver est : " -NoNewline; Write-Host "$AccountLogin@$Domain" -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la désactivation du compte ?"

            Do {
                [string]$AccountDisabled = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountDisabled = $AccountDisabled.ToLower().Trim()
                If ($AccountDisabled -eq "") {
                    $AccountDisabled = "o"
                }
                If ($AccountDisabled -ne "oui" -and $AccountDisabled -ne "o" -and $AccountDisabled -ne "non" -and $AccountDisabled -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountDisabled -or ($AccountDisabled -ne "oui" -and $AccountDisabled -ne "o" -and $AccountDisabled -ne "non" -and $AccountDisabled -ne "n"))

            If (($AccountDisabled -eq "oui") -or ($AccountDisabled -eq "o")) {
                Try {
                    Disable-ADAccount -Identity $AccountLogin
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] a été désactivé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte [$AccountLogin] a été désactivé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'a pas été désactivé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] n'a pas été désactivé." -ForegroundColor Red
            }
        }
        6 {
            Write-Host "`r"
            Write-Host "##################################################################################" -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "##########    [ AD - DESACTIVER UN COMPTE ET SUPPRIMER SES GROUPES ]    ##########" -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "##################################################################################" -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "`r"

            Do {
                Do {
                    [string]$AccountLogin = Read-Host "Saisir le login du compte à désactiver "
                    If ($AccountLogin -eq "") {
                        Write-Host "`r"
                        Write-Host "Le login du compte à désactiver ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($AccountLogin -eq "")
                $AccountLogin = $AccountLogin.ToLower().Trim()
                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist.Enabled -eq $false) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] est déjà désactivé dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist -or $UserExist.Enabled -eq $false)

            Try {
                [array]$UserToDelete = Get-ADUser $AccountLogin -Properties MemberOf
                $DistinguishedName = $UserToDelete.DistinguishedName
                $DeletedGroups = $UserToDelete.MemberOf
                [int]$DeletedGroupsNumber = $UserToDelete.MemberOf.Count
            }
            Catch {
                [string]$ErrorMessage = $_.Exception.Message
                Write-Host "`r"
                Write-Host $ErrorMessage -ForegroundColor Red
                Write-Host "`r"
            }

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à désactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "- Le login complet du compte à désactiver est : " -NoNewline; Write-Host "$AccountLogin@$Domain" -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la désactivation du compte et supprimer ses groupes d'appartenance ?"

            Do {
                [string]$AccountDisabled = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountDisabled = $AccountDisabled.ToLower().Trim()
                If ($AccountDisabled -eq "") {
                    $AccountDisabled = "o"
                }
                If ($AccountDisabled -ne "oui" -and $AccountDisabled -ne "o" -and $AccountDisabled -ne "non" -and $AccountDisabled -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountDisabled -or ($AccountDisabled -ne "oui" -and $AccountDisabled -ne "o" -and $AccountDisabled -ne "non" -and $AccountDisabled -ne "n"))

            If (($AccountDisabled -eq "oui") -or ($AccountDisabled -eq "o")) {
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] est membre de [$DeletedGroupsNumber] groupe(s)." -ForegroundColor Green
                Foreach ($Group in $DeletedGroups) {
                    Try {
                        Remove-ADGroupMember -Identity $Group -Members $DistinguishedName -Confirm:$false
                        Write-Host "Le compte [$AccountLogin] a été supprimé du groupe : $Group" -ForegroundColor Green
                        Write-Log -Output $LogFile -Message "Le compte [$AccountLogin] a été supprimé du groupe : $Group par : [$Login]."
                    }
                    Catch {
                        [string]$ErrorMessage = $_.Exception.Message
                        Write-Host "`r"
                        Write-Host $ErrorMessage -ForegroundColor Red
                        Write-Host "`r"
                    }
                }
                Try {
                    Disable-ADAccount -Identity $AccountLogin
                    Write-Host "Le compte [$AccountLogin] a été désactivé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte [$AccountLogin] a été désactivé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] n'a pas été désactivé." -ForegroundColor Red
            }
        }
        7 {
            Write-Host "`r"
            Write-Host "#########################################################" -ForegroundColor White -BackgroundColor Green
            Write-Host "##########    [ AD - REACTIVER UN COMPTE  ]    ##########" -ForegroundColor White -BackgroundColor Green
            Write-Host "#########################################################" -ForegroundColor White -BackgroundColor Green
            Write-Host "`r"

            Do {
                Do {
                    [string]$AccountLogin = Read-Host "Saisir le login du compte à réactiver "
                    If ($AccountLogin -eq "") {
                        Write-Host "`r"
                        Write-Host "Le login du compte à réactiver ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                    $AccountLogin = $AccountLogin.ToLower().Trim()
                } While ($AccountLogin -eq "")
                Try {
                    [array]$UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($UserExist.Enabled -eq $true) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] est déjà activé dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist -or $UserExist.Enabled -eq $true)

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à réactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à réactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Green
            Write-Host "- Le login complet du compte à réactiver est : " -NoNewline; Write-Host "$AccountLogin@$Domain" -ForegroundColor White -BackgroundColor Green
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la réactivation du compte ?"

            Do {
                [string]$AccountEnabled = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $AccountEnabled = $AccountEnabled.ToLower().Trim()
                If ($AccountEnabled -eq "") {
                    $AccountEnabled = "o"
                }
                If ($AccountEnabled -ne "oui" -and $AccountEnabled -ne "o" -and $AccountEnabled -ne "non" -and $AccountEnabled -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$AccountEnabled -or ($AccountEnabled -ne "oui" -and $AccountEnabled -ne "o" -and $AccountEnabled -ne "non" -and $AccountEnabled -ne "n"))

            If (($AccountEnabled -eq "oui") -or ($AccountEnabled -eq "o")) {
                Try {
                    Enable-ADAccount -Identity $AccountLogin
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] a été réactivé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le compte [$AccountLogin] a été réactivé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'a pas été réactivé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] n'a pas été réactivé." -ForegroundColor Red
            }
        }
        8 {
            Write-Host "`r"
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "##########    [ AD - CREATION D'UN GROUPE DE SECURITE ]    ##########" -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "`r"

            Do {
                Do {
                    [string]$GroupName = Read-Host "Saisir le nom du groupe à créer "
                    If ($GroupName -eq "") {
                        Write-Host "`r"
                        Write-Host "Le nom du groupe à créer ne peux pas être vide !" -ForegroundColor Red
                        Write-Host "`r"
                    }
                } While ($GroupName -eq "")
                Try {
                    [array]$GroupExist = Get-ADGroup -Filter { Name -eq $GroupName }
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                }
                If ($GroupExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le groupe [$GroupName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While ($GroupExist)

            Do {
                [string]$GroupDescription = Read-Host "Saisir la description du groupe "
                If ($GroupDescription -eq "") {
                    Write-Host "`r"
                    Write-Host "La description du groupe ne peux pas être vide !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While ($GroupDescription -eq "")

            Write-Host "`r"
            Write-Host "Rappel des informations du groupe à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le nom du groupe est : " -NoNewline; Write-Host $GroupName -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "- La description du groupe est : " -NoNewline; Write-Host $GroupDescription -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "`r"

            Write-Host "Confirmation :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "Voulez-vous valider la création du groupe ?"

            Do {
                [string]$GroupCreation = Read-Host '[O] Oui / [N] Non - (Défaut est "O") '
                $GroupCreation = $GroupCreation.ToLower().Trim()
                If ($GroupCreation -eq "") {
                    $GroupCreation = "o"
                }
                If ($GroupCreation -ne "oui" -and $GroupCreation -ne "o" -and $GroupCreation -ne "non" -and $GroupCreation -ne "n") {
                    Write-Host "Taper [O] Oui ou [N] Non" -ForegroundColor Red
                }
            } While (!$GroupCreation -or ($GroupCreation -ne "oui" -and $GroupCreation -ne "o" -and $GroupCreation -ne "non" -and $GroupCreation -ne "n"))

            If (($GroupCreation -eq "oui") -or ($GroupCreation -eq "o")) {
                Try {
                    New-ADGroup -Name $GroupName -GroupScope DomainLocal -Description $GroupDescription
                    Write-Host "`r"
                    Write-Host "Le groupe [$GroupName] a été créé." -ForegroundColor Green
                    Write-Log -Output $LogFile -Message "Le groupe [$GroupName] a été créé par : [$Login]."
                }
                Catch {
                    [string]$ErrorMessage = $_.Exception.Message
                    Write-Host "`r"
                    Write-Host $ErrorMessage -ForegroundColor Red
                    Write-Host "`r"
                    Write-Host "Le groupe [$GroupName] n'a pas été créé." -ForegroundColor Red
                }
            }
            Else {
                Write-Host "`r"
                Write-Host "Le groupe [$GroupName] n'a pas été créé." -ForegroundColor Red
            }
        }
    }

    If ($Action -eq 9) {
        Write-Host "`r"
        Write-Host "Merci d'avoir utilisé l'ACM !" -ForegroundColor Cyan
        Write-Host "`r"
        $Restart = $false
        }
        Else {
            Write-Host "`r"
            Read-Host "Appuyer sur Entrée pour retourner au menu principal "
        }
}
