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

Try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
Catch {
    Write-Warning "The ActiveDirectory module failed to load. Install the module and try again."
    Write-Host "`r"
    Exit
}

$Restart = $true

While ($Restart) {
    $Action = 0
    Clear-Host
    Write-Host "`r"
    Write-Host "################################################################"
    Write-Host "##########    [ ACM - ACCOUNT MANAGEMENT PROGRAM ]    ##########"
    Write-Host "################################################################"
    Write-Host "`r"
    Write-Host "`MENU :"
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
    Write-Host "################################################################"
    Write-Host "`r"

    While ($Action -lt 1 -or $Action -gt 9) {
        [int]$Action = Read-Host "Choisir l'action à effectuer (1-9) "
    }
    Switch ($Action) {
        1 {
            Write-Host "`r"
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "##########    [ AD - CREATION D'UN COMPTE UTILISATEUR ]    ##########" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "#####################################################################" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "`r"

            Do {
                $AccountGivenName = Read-Host "Saisir le prénom du compte "
                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                $AccountGivenName = (Get-Culture).TextInfo.ToTitleCase($AccountGivenName)

                $AccountGivenNameMin = $AccountGivenName.ToLower().Trim()

                $AccountName = Read-Host "Saisir le nom du compte "
                $AccountName = $AccountName.ToLower().Trim()
                $AccountName = (Get-Culture).TextInfo.ToTitleCase($AccountName)

                $AccountNameMin = $AccountName.ToLower().Trim()

                If ($AccountGivenName.Contains('-')) {
                    $AccountBeginLogin = $AccountGivenNameMin -replace '(.).*-(.).*','$1$2'
                }
                Else {
                    $AccountBeginLogin = $AccountGivenNameMin.Substring(0,1)
                }

                $AccountLogin = $AccountBeginLogin+"."+$AccountNameMin

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }

                $AccountBusinessCategory = "user"
                $AccountDomain = "lab.microsoft.com"
                $AccountDisplayName = $AccountGivenName+" "+$AccountName
                $AccountFullLogin = $AccountBeginLogin+"."+$AccountNameMin+"@"+$AccountDomain
            } While ($UserExist)

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (10 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPassword = Read-Host "Saisir le mot de passe du compte "

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

            $AccountCreation = Read-Host "Valider la création du compte utilisateur (oui ou non) "
            $AccountCreation = $AccountCreation.ToLower().Trim()

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                New-ADUser $AccountDisplayName -GivenName $AccountGivenName -Surname $AccountName -displayName $AccountDisplayName -SamAccountName $AccountLogin -UserPrincipalName $AccountFullLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                Write-Host "`r"
                Write-Host "Le compte utilisateur [$AccountDisplayName] a été créé." -ForegroundColor Green
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

            Do {
                $AccountGivenName = Read-Host "Saisir le prénom du compte "
                $AccountGivenName = $AccountGivenName.ToLower().Trim()
                $AccountGivenName = (Get-Culture).TextInfo.ToTitleCase($AccountGivenName)

                $AccountGivenNameMin = $AccountGivenName.ToLower().Trim()

                $AccountName = Read-Host "Saisir le nom du compte "
                $AccountName = $AccountName.ToLower().Trim()
                $AccountName = (Get-Culture).TextInfo.ToTitleCase($AccountName)

                $AccountNameMin = $AccountName.ToLower().Trim()

                If ($AccountGivenName.Contains('-')) {
                    $AccountBeginLogin = $AccountGivenNameMin -replace '(.).*-(.).*','$1$2'
                }
                Else {
                    $AccountBeginLogin = $AccountGivenNameMin.Substring(0,1)
                }

                $AccountLogin = "0"+$AccountBeginLogin+"."+$AccountNameMin

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }

                $AccountInitials = "ADM"
                $AccountBusinessCategory = "admin"
                $AccountDomain = "lab.microsoft.com"
                $AccountDisplayName = $AccountInitials+" "+$AccountGivenName+" "+$AccountName
                $AccountFullLogin = "0"+$AccountBeginLogin+"."+$AccountNameMin+"@"+$AccountDomain
            } While ($UserExist)

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (20 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPassword = Read-Host "Saisir le mot de passe du compte "

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

            $AccountCreation = Read-Host "Valider la création du compte administrateur (oui ou non) "
            $AccountCreation = $AccountCreation.ToLower().Trim()

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                New-ADUser $AccountDisplayName -GivenName $AccountGivenName -Surname $AccountName -displayName $AccountDisplayName -SamAccountName $AccountLogin -UserPrincipalName $AccountFullLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory;initials=$AccountInitials}
                Write-Host "`r"
                Write-Host "Le compte administrateur [$AccountDisplayName] a été créé." -ForegroundColor Green
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

            Do {
                Write-Host "Entrer le login à l'aide de ce modèle : svc[i/d/r/p]_name." -ForegroundColor Cyan

                $AccountGivenName = Read-Host "Saisir le login du compte de service "
                $AccountGivenName = $AccountGivenName.ToLower().Trim()

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountGivenName }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountGivenName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
                If (!$AccountGivenName.StartsWith("svci_") -and !$AccountGivenName.StartsWith("svcd_") -and !$AccountGivenName.StartsWith("svcr_") -and !$AccountGivenName.StartsWith("svcp_")) {
                    Write-Host "`r"
                    Write-Warning "Le login doit obligatoirement commencer par svc[i/d/r/p]_"
                    Write-Host "`r"
                }
            } While (($UserExist) -or (!$AccountGivenName.StartsWith("svci_") -and !$AccountGivenName.StartsWith("svcd_") -and !$AccountGivenName.StartsWith("svcr_") -and !$AccountGivenName.StartsWith("svcp_")))

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (15 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPassword = Read-Host "Saisir le mot de passe du compte "

                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$'))

            Write-Host "`r"
            $AccountDescription = Read-Host "Saisir la description du compte "
            $AccountBusinessCategory = "service"
            $AccountDomain = "lab.microsoft.com"
            $AccountLogin = $AccountGivenName+"@"+$AccountDomain

            Write-Host "`r"
            Write-Host "Rappel des informations du compte de service à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le nom du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor Blue
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Blue
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor Blue
            Write-Host "- La description du compte est : " -NoNewline; Write-Host $AccountDescription -ForegroundColor White -BackgroundColor Blue
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor Blue
            Write-Host "`r"

            $AccountCreation = Read-Host "Valider la création du compte de service (oui ou non) "
            $AccountCreation = $AccountCreation.ToLower().Trim()

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                New-ADUser $AccountGivenName -GivenName $AccountGivenName -displayName $AccountGivenName -Description $AccountDescription -SamAccountName $AccountGivenName -UserPrincipalName $AccountLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                Write-Host "`r"
                Write-Host "Le compte de service [$AccountGivenName] a été créé." -ForegroundColor Green
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

            Do {
                Write-Host "Entrer le login à l'aide de ce modèle : monitoring.name." -ForegroundColor Cyan

                $AccountGivenName = Read-Host "Saisir le login du compte de monitoring "
                $AccountGivenName = $AccountGivenName.ToLower().Trim()

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountGivenName }
                If ($UserExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountGivenName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
                If (!$AccountGivenName.StartsWith("monitoring.")) {
                    Write-Host "`r"
                    Write-Warning "Le login doit obligatoirement commencer par monitoring."
                    Write-Host "`r"
                }
            } While (($UserExist) -or (!$AccountGivenName.StartsWith("monitoring.")))

            Do {
                Write-Host "`r"
                Write-Host "Le mot de passe doit respecter les exigences de complexité (15 caractères)." -ForegroundColor Cyan
                Write-Host "(Majuscules, minuscules, chiffres et caractères spéciaux)." -ForegroundColor Cyan

                $AccountPassword = Read-Host "Saisir le mot de passe du compte "

                If (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$')) {
                    Write-Host "`r"
                    Write-Warning "Le mot de passe doit respecter les exigences de complexité."
                }
            } While (!($AccountPassword -match '^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{15,}$'))

            Write-Host "`r"
            $AccountDescription = Read-Host "Saisir la description du compte "                
            $AccountBusinessCategory = "monitoring"
            $AccountDomain = "lab.microsoft.com"
            $AccountLogin = $AccountGivenName+"@"+$AccountDomain

            Write-Host "`r"
            Write-Host "Rappel des informations du compte de monitoring à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le nom du compte est : " -NoNewline; Write-Host $AccountGivenName -ForegroundColor White -BackgroundColor Red
            Write-Host "- Le login du compte est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Red
            Write-Host "- Le mot de passe du compte est : " -NoNewline; Write-Host $AccountPassword -ForegroundColor White -BackgroundColor Red
            Write-Host "- La description du compte est : " -NoNewline; Write-Host $AccountDescription -ForegroundColor White -BackgroundColor Red
            Write-Host "- La Business Category du compte est : " -NoNewline; Write-Host $AccountBusinessCategory -ForegroundColor White -BackgroundColor Red
            Write-Host "`r"

            $AccountCreation = Read-Host "Valider la création du compte de monitoring (oui ou non) "
            $AccountCreation = $AccountCreation.ToLower().Trim()

            If (($AccountCreation -eq "oui") -or ($AccountCreation -eq "o")) {
                New-ADUser $AccountGivenName -GivenName $AccountGivenName -displayName $AccountGivenName -Description $AccountDescription -SamAccountName $AccountGivenName -UserPrincipalName $AccountLogin -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true -OtherAttributes @{businessCategory=$AccountBusinessCategory}
                Write-Host "`r"
                Write-Host "Le compte de monitoring [$AccountGivenName] a été créé." -ForegroundColor Green
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
                $AccountLogin = Read-Host "Saisir le login du compte à désactiver "
                $AccountLogin = $AccountLogin.ToLower().Trim()
                $AccountDomain = "lab.microsoft.com"

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist)

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à désactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "- Le login complet du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin"@"$AccountDomain -ForegroundColor White -BackgroundColor DarkRed
            Write-Host "`r"

            $AccountDisabled = Read-Host "Valider la désactivation du compte (oui ou non) "
            $AccountDisabled = $AccountDisabled.ToLower().Trim()

            If (($AccountDisabled -eq "oui") -or ($AccountDisabled -eq "o")) {
                Disable-ADAccount -Identity $AccountLogin
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] a été désactivé." -ForegroundColor Green
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
                $AccountLogin = Read-Host "Saisir le login du compte à désactiver "
                $AccountLogin = $AccountLogin.ToLower().Trim()
                $AccountDomain = "lab.microsoft.com"
      
                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist)

            $UserToDelete = Get-ADUser $AccountLogin -properties MemberOf
            $DistinguishedName = $UserToDelete.DistinguishedName
            $DeletedGroups = $UserToDelete.MemberOf

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à désactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "- Le login complet du compte à désactiver est : " -NoNewline; Write-Host $AccountLogin"@"$AccountDomain -ForegroundColor White -BackgroundColor DarkMagenta
            Write-Host "`r"

            $AccountDisabled = Read-Host "Valider la désactivation du compte (oui ou non) "
            $AccountDisabled = $AccountDisabled.ToLower().Trim()

            If (($AccountDisabled -eq "oui") -or ($AccountDisabled -eq "o")) {
                Foreach ($group in $DeletedGroups) {
                    Remove-ADGroupMember -Identity $group -Members $DistinguishedName -Confirm:$false
                }
                Disable-ADAccount -Identity $AccountLogin
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] a été supprimé de" $UserToDelete.MemberOf.Count "groupe(s)." -foreground Green
                Write-Host "`r"
                Write-Host "Groupe(s) supprimé(s) :"$UserToDelete.MemberOf"" -foreground Green
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] a été désactivé." -ForegroundColor Green
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
                $AccountLogin = Read-Host "Saisir le login du compte à réactiver "
                $AccountLogin = $AccountLogin.ToLower().Trim()
                $AccountDomain = "lab.microsoft.com"

                $UserExist = Get-ADUser -Filter { sAMAccountName -eq $AccountLogin }
                If ($UserExist -eq $null) {
                    Write-Host "`r"
                    Write-Host "Le compte [$AccountLogin] n'existe pas dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While (!$UserExist)

            Write-Host "`r"
            Write-Host "Rappel des informations du compte à réactiver :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le login du compte à réactiver est : " -NoNewline; Write-Host $AccountLogin -ForegroundColor White -BackgroundColor Green
            Write-Host "- Le login complet du compte à réactiver est : " -NoNewline; Write-Host $AccountLogin"@"$AccountDomain -ForegroundColor White -BackgroundColor Green
            Write-Host "`r"

            $AccountEnabled = Read-Host "Valider la réactivation du compte (oui ou non) "
            $AccountEnabled = $AccountEnabled.ToLower().Trim()

            If (($AccountEnabled -eq "oui") -or ($AccountEnabled -eq "o")) {
                Enable-ADAccount -Identity $AccountLogin
                Write-Host "`r"
                Write-Host "Le compte [$AccountLogin] a été réactivé." -ForegroundColor Green
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
                $GroupName = Read-Host "Saisir le nom du groupe à créer "

                $GroupExist = Get-ADGroup -Filter { Name -eq $GroupName }
                If ($GroupExist -ne $null) {
                    Write-Host "`r"
                    Write-Host "Le groupe [$GroupName] existe déjà dans l'AD !" -ForegroundColor Red
                    Write-Host "`r"
                }
            } While ($GroupExist)

            $GroupDescription = Read-Host "Saisir la description du groupe "

            Write-Host "`r"
            Write-Host "Rappel des informations du groupe à créer :" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host "- Le nom du groupe est : " -NoNewline; Write-Host $GroupName -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "- La description du groupe est : " -NoNewline; Write-Host $GroupDescription -ForegroundColor White -BackgroundColor DarkCyan
            Write-Host "`r"

            $GroupCreation = Read-Host "Valider la création du groupe (oui ou non) "
            $GroupCreation = $GroupCreation.ToLower().Trim()

            If (($GroupCreation -eq "oui") -or ($GroupCreation -eq "o")) {
                New-ADGroup -Name $GroupName -GroupScope DomainLocal -Description $GroupDescription
                Write-Host "`r"
                Write-Host "Le groupe [$GroupName] a été créé." -ForegroundColor Green
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
